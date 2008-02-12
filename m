Date: Tue, 12 Feb 2008 10:06:23 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 9941] New: Zone "Normal" missing in /proc/zoneinfo
Message-Id: <20080212100623.4fd6cf85.akpm@linux-foundation.org>
In-Reply-To: <bug-9941-27@http.bugzilla.kernel.org/>
References: <bug-9941-27@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: bart.vanassche@gmail.com
Cc: bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Feb 2008 02:39:40 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9941
> 
>            Summary: Zone "Normal" missing in /proc/zoneinfo
>            Product: Memory Management
>            Version: 2.5
>      KernelVersion: 2.6.24.2
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: akpm@osdl.org
>         ReportedBy: bart.vanassche@gmail.com
> 
> 
> Latest working kernel version: 2.6.24
> Earliest failing kernel version: 2.6.24.2
> Distribution: Ubuntu 7.10 server
> Hardware Environment: Intel S5000PAL
> Software Environment:
> Problem Description:
> 
> There is only information about the zones "DMA" and "DMA32" in /proc/zoneinfo,
> not about zone "Normal".
> 
> Steps to reproduce:
> 
> Run the following command in a shell:
> $ grep zone /proc/zoneinfo
> 
> Output with 2.6.24:
> Node 0, zone      DMA
> Node 0, zone    DMA32
> Node 0, zone   Normal
> 
> Output with 2.6.24.2:
> Node 0, zone      DMA
> Node 0, zone    DMA32
> 

hm, I don't think that was expected.   Please send the full kernel boot log
(the dmesg -s 1000000 output).  Please send it via emailed reply-to-all, not
via the bugzilla web interface, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
