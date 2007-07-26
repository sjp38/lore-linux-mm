Date: Thu, 26 Jul 2007 10:57:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8814] New: PCI numa_node not set correctly
Message-Id: <20070726105731.f7dc2cae.akpm@linux-foundation.org>
In-Reply-To: <bug-8814-10286@http.bugzilla.kernel.org/>
References: <bug-8814-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: "bugme-daemon@kernel-bugs.osdl.org" <bugme-daemon@bugzilla.kernel.org>, joachim.deguara@amd.com, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, 26 Jul 2007 05:13:12 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8814
> 
>            Summary: PCI numa_node not set correctly
>            Product: Platform Specific/Hardware
>            Version: 2.5
>      KernelVersion: 2.6.22-rc7-git4-ak-070710
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: x86-64
>         AssignedTo: ak@suse.de
>         ReportedBy: joachim.deguara@amd.com
> 
> 
> Most recent kernel where this bug did not occur:
> Distribution: SLES10 with -ak kernel
> Hardware Environment: Tyan 4985
> Software Environment: 
> Problem Description:
> 
> This hardware is a 4 socket Opteron with the normal I/O Hub hanging off of node
> 0 but also with a PCIe bridge and Networking attached to node 1.  Looking
> through the code, the node of the pci device gets exported to sysfs and set by
> k8-bus.c.  However looking at the value of numa_node for all devices in sysfs
> returned 0.
> 
> Steps to reproduce:
> find /sys -name 'numa_node'|xargs cat
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
