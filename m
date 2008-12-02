Date: Mon, 1 Dec 2008 18:14:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 12134] New: can't shmat() 1GB hugepage segment from second
 process more than one time
Message-Id: <20081201181459.49d8fcca.akpm@linux-foundation.org>
In-Reply-To: <bug-12134-27@http.bugzilla.kernel.org/>
References: <bug-12134-27@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: bugme-daemon@bugzilla.kernel.org, starlight@binnacle.cx, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>, David Gibson <david@gibson.dropbear.id.au>
List-ID: <linux-mm.kvack.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon,  1 Dec 2008 18:01:39 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12134
> 
>            Summary: can't shmat() 1GB hugepage segment from second process
>                     more than one time
>            Product: Memory Management
>            Version: 2.5
>      KernelVersion: 2.26.27.7
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Other
>         AssignedTo: akpm@osdl.org
>         ReportedBy: starlight@binnacle.cx
> 
> 
> Latest working kernel version: don't know
> Earliest failing kernel version: don't know
> Distribution: kernel.org
> Hardware Environment: HP DL160 G5 w/ dual E5430's & 16GB PC2-5300 FB-DIMMs
> Software Environment: F9
> Problem Description:
> 
> can't shmat() 1GB hugepage segment from second process more than one time
> 
> Steps to reproduce:
> 
> create 1GB or more hugepage shmget/shmat segment
> attached at explicit virtual address 0x4_00000000
> 
> run another program that attaches segment
> 
> run it again, fails
> 
> eventually get attached 'dmesg' output
> 
> works fine under RHEL 4.6
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
