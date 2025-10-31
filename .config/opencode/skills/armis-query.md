Markdown

```
# Skill: ArmisQuery

## Description

This skill allows the LLM to query the Armis Asset Intelligence Platform using the **Armis Standard Query (ASQ)** language. It takes a single string argument, `asq_query`, which must be a syntactically correct ASQ query.

The LLM's role is to translate a user's natural language request into this precise ASQ string to search the organization's asset inventory, vulnerability database, and activity logs.
```

<br/>

## Arguments

<br/>
| **Parameter** | **Type** | **Required** | **Description** |
| --- | --- | --- | --- |
| `asq_query` | `string` | Yes | The query string, formatted in Armis Standard Query (ASQ) language. |

<br/>

## Output

<br/>

Returns a list of JSON objects (dictionaries) that match the query.

*   **Success:** Returns a list of results. If no matches are found, returns an empty list `[]`.
    
*   **Failure:** Raises an error if the `asq_query` syntax is invalid.
    

* * *

<br/>

## Armis Standard Query (ASQ) Language Guide

<br/>

This is the complete guide for constructing valid `asq_query` strings.

<br/>

### 1. Core Concepts

<br/>

*   **Filter-Based:** ASQ works by combining filters (e.g., `os:"Windows 10"`).
    
*   **Implicit** `AND`**:** Multiple filters are joined by `AND` by default. `os:"Windows" category:"Server"` finds devices that are _both_ Windows _and_ a Server.
    
*   **Default Target:** If no `in:` prefix is used, ASQ defaults to searching devices (`in:devices`).
    

<br/>

### 2. Syntax and Operators

<br/>
| **Operator** | **Function** | **Example** |
| --- | --- | --- |
| **(implicit)** | Logical `AND`. | `os:"Windows 10" category:"Workstation"` |
| `OR` | Logical `OR`. Must be uppercase. | `manufacturer:"HP" OR manufacturer:"Dell"` |
| `NOT` or `!` | Logical `NOT`. | `NOT category:"Printer"` |
| `( )` | **Grouping**. Essential for `OR` logic. | `os:"Windows" AND (tag:"Server" OR category:"Server")` |
| `"` | **Exact Match**. Required for values with spaces. | `os:"Windows Server 2019"` |
| `*` | **Wildcard**. Used for "contains" or partial matches. | `softwareName:"Chrome*"` |
| `>`, `<`, `>=`, `<=` | **Numerical Comparison**. | `vulnerabilityCount:>10` |

<br/>

### 3. Query Targets (The `in:` Operator)

<br/>

You must specify the data set you are querying.

| **Target** | **Description** | **Example** |
| --- | --- | --- |
| `in:devices` | **(Default)** Searches the asset inventory. | `in:devices category:"Firewall"` |
| `in:vulnerabilities` | Searches the vulnerability database (CVEs, etc.). | `in:vulnerabilities severity:"Critical"` |
| `in:activities` | Searches device activity logs (connections, logins). | `in:activities activityType:"Login Failure"` |

<br/>

### 4. Common Query Fields

<br/>

Use these fields to build your queries.

<br/>

#### **Device Identification**

<br/>

*   `os`: (e.g., `"Windows 10"`, `"Android 13"`)
    
*   `osFamily`: (e.g., `"Windows"`, `"Linux"`, `"Android"`)
    
*   `category`: (e.g., `"Workstation"`, `"Server"`, `"Printer"`, `"Firewall"`)
    
*   `type`: (e.g., `"Laptop"`, `"Smart TV"`, `"Virtual Machine"`)
    
*   `manufacturer`: (e.g., `"Dell"`, `"Palo Alto Networks"`, `"Apple"`)
    
*   `ipAddress`: (e.g., `"192.168.1.10/24"`, `"10.0.0.1"`)
    
*   `macAddress`: (e.g., `"00:1A:2B:3C:4D:5E"`)
    
*   `hostname`: (e.g., `"FIN-LTP-001"`)
    
*   `tag`: (e.g., `"Datacenter"`, `"Guest-WiFi"`)
    

<br/>

#### **Risk & Vulnerability**

<br/>

*   `riskLevel`: (e.g., `"Critical"`, `"High"`, `"Medium"`, `"Low"`)
    
*   `vulnerabilityCount`: (e.g., `vulnerabilityCount:>10`)
    
*   `vulnerabilitySeverity`: (e.g., `"Critical"`, `"High"`)
    
*   `cve`: (e.g., `"CVE-2023-1234"`)
    

<br/>

#### **Security Posture**

<br/>

*   `isManaged`: (e.g., `isManaged:true`, `isManaged:false`)
    
*   `isEncrypted`: (e.g., `isEncrypted:false`)
    
*   `softwareName`: (e.g., `softwareName:"CrowdStrike Falcon*"`)
    
*   `softwareVersion`: (e.g., `softwareName:"Chrome*" AND softwareVersion:"118.*"`)
    

<br/>

#### **Time & Activity**

<br/>

*   `lastSeen`: Use with time functions.
    
    *   `lastSeen:newerThan(n, "unit")` (e.g., `newerThan(48, "hours")`)
        
    *   `lastSeen:olderThan(n, "unit")` (e.g., `olderThan(30, "days")`)
        
*   `activityType`: (e.g., `"Login Success"`, `"RDP Connection"`)
    

* * *

<br/>

## Strict Rules for LLM

<br/>

1.  **Always Quote Spaces:** Any value with a space MUST be enclosed in double quotes (e.g., `os:"Windows 11"`).
    
2.  **Case Sensitivity:** Operators (`OR`, `NOT`) MUST be **UPPERCASE**. Field names (`osFamily`) and values (`"Windows"`) are case-sensitive.
    
3.  **Group** `OR` **Statements:** Always use parentheses `( )` to group `OR` statements to ensure correct logic.
    
    *   **Wrong:** `os:"Windows" AND category:"Server" OR category:"Workstation"`
        
    *   **Right:** `os:"Windows" AND (category:"Server" OR category:"Workstation")`
        
4.  **Use Correct Target:** Use `in:devices` (or no prefix) for assets, `in:vulnerabilities` for CVEs, and `in:activities` for logs.
    

* * *

<br/>

## Comprehensive Examples

<br/><br/>

### Example 1: Simple Device Search

<br/>

*   **User Request:** "Find all devices running Windows 11."
    
*   **LLM Thought:** User wants "devices". The filter is `os`. The value "Windows 11" has a space and must be quoted. The default `in:devices` is fine.
    
*   **Tool Call:** `ArmisQuery(asq_query='os:"Windows 11"')`
    

<br/>

### Example 2: Complex `OR` and `AND` Logic

<br/>

*   **User Request:** "Show me all firewalls from either Palo Alto Networks or Checkpoint."
    
*   **LLM Thought:** User wants "devices". The `category` is "Firewall". There is an `OR` condition on `manufacturer`. I must group the `OR` statement in parentheses. "Palo Alto Networks" needs quotes.
    
*   **Tool Call:** `ArmisQuery(asq_query='category:"Firewall" AND (manufacturer:"Palo Alto Networks" OR manufacturer:"Checkpoint")')`
    

<br/>

### Example 3: `NOT` Operator and Boolean

<br/>

*   **User Request:** "I need a list of all unmanaged servers that have a critical risk level."
    
*   **LLM Thought:** User wants "devices". There are three `AND` conditions:
    
    1.  "unmanaged" -> `isManaged:false`
        
    2.  "servers" -> `category:"Server"`
        
    3.  "critical risk" -> `riskLevel:"Critical"`
        
*   **Tool Call:** `ArmisQuery(asq_query='isManaged:false AND category:"Server" AND riskLevel:"Critical"')`
    

<br/>

### Example 4: Software Search with Wildcard

<br/>

*   **User Request:** "Find every machine that has any version of CrowdStrike Falcon installed."
    
*   **LLM Thought:** User wants "devices" ("machines"). I need to check `softwareName`. Since "any version" is requested, a wildcard `*` is appropriate. "CrowdStrike Falcon" needs quotes.
    
*   **Tool Call:** `ArmisQuery(asq_query='softwareName:"CrowdStrike Falcon*"')`
    

<br/>

### Example 5: Time-Based Query

<br/>

*   **User Request:** "Show me all assets that haven't been online in 30 days."
    
*   **LLM Thought:** User wants "devices" ("assets"). The filter is `lastSeen`. The logic "haven't been online in 30 days" means their `lastSeen` timestamp is _older than_ 30 days.
    
*   **Tool Call:** `ArmisQuery(asq_query='lastSeen:olderThan(30, "days")')`
    

<br/>

### Example 6: Numerical Comparison

<br/>

*   **User Request:** "List all workstations with more than 10 vulnerabilities."
    
*   **LLM Thought:** User wants "devices". The `category` is "Workstation". The filter is `vulnerabilityCount` using the `>` operator.
    
*   **Tool Call:** `ArmisQuery(asq_query='category:"Workstation" AND vulnerabilityCount:>10')`
    

<br/>

### Example 7: Non-Device Target (Vulnerabilities)

<br/>

*   **User Request:** "List all critical vulnerabilities that are known to be exploitable."
    
*   **LLM Thought:** User is asking for "vulnerabilities," not devices. I MUST use the `in:vulnerabilities` target. The conditions are `severity:"Critical"` and `exploitable:true`.
    
*   **Tool Call:** `ArmisQuery(asq_query='in:vulnerabilities severity:"Critical" AND exploitable:true')`
    

<br/>

### Example 8: Complex Combination

<br/>

*   **User Request:** "I need all Windows Servers in the 'Datacenter' tag that have at least one critical vulnerability and were seen in the last 2 days."
    
*   **LLM Thought:** User wants "devices".
    
    1.  `osFamily:"Windows"`
        
    2.  `category:"Server"`
        
    3.  `tag:"Datacenter"`
        
    4.  "at least one critical vulnerability" -> `vulnerabilitySeverity:"Critical"`
        
    5.  "seen in the last 2 days" -> `lastSeen:newerThan(2, "days")`
        
*   **Tool Call:** `ArmisQuery(asq_query='osFamily:"Windows" AND category:"Server" AND tag:"Datacenter" AND vulnerabilitySeverity:"Critical" AND lastSeen:newerThan(2, "days")')`
    

<br/>
