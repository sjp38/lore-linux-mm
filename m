Date: Tue, 12 Feb 2008 23:45:22 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 9941] New: Zone "Normal" missing in /proc/zoneinfo
Message-Id: <20080212234522.24bed8c1.akpm@linux-foundation.org>
In-Reply-To: <e2e108260802122339j3b861e74vf7b72a34747dcade@mail.gmail.com>
References: <bug-9941-27@http.bugzilla.kernel.org/>
	<20080212100623.4fd6cf85.akpm@linux-foundation.org>
	<e2e108260802122339j3b861e74vf7b72a34747dcade@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bart Van Assche <bart.vanassche@gmail.com>
Cc: bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 13 Feb 2008 08:39:30 +0100 "Bart Van Assche" <bart.vanassche@gmail.com> wrote:

> On Feb 12, 2008 7:06 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> >
> > On Tue, 12 Feb 2008 02:39:40 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:
> >
> > > http://bugzilla.kernel.org/show_bug.cgi?id=9941
> > >
> > >            Summary: Zone "Normal" missing in /proc/zoneinfo
> > >            Product: Memory Management
> > >            Version: 2.5
> > >      KernelVersion: 2.6.24.2
> > >           Platform: All
> > >         OS/Version: Linux
> > >               Tree: Mainline
> > >             Status: NEW
> > >           Severity: normal
> > >           Priority: P1
> > >          Component: Other
> > >         AssignedTo: akpm@osdl.org
> > >         ReportedBy: bart.vanassche@gmail.com
> > >
> > >
> > > Latest working kernel version: 2.6.24
> > > Earliest failing kernel version: 2.6.24.2
> > > Distribution: Ubuntu 7.10 server
> > > Hardware Environment: Intel S5000PAL
> > > Software Environment:
> > > Problem Description:
> > >
> > > There is only information about the zones "DMA" and "DMA32" in /proc/zoneinfo,
> > > not about zone "Normal".
> > >
> > > Steps to reproduce:
> > >
> > > Run the following command in a shell:
> > > $ grep zone /proc/zoneinfo
> > >
> > > Output with 2.6.24:
> > > Node 0, zone      DMA
> > > Node 0, zone    DMA32
> > > Node 0, zone   Normal
> > >
> > > Output with 2.6.24.2:
> > > Node 0, zone      DMA
> > > Node 0, zone    DMA32
> > >
> >
> > hm, I don't think that was expected.   Please send the full kernel boot log
> > (the dmesg -s 1000000 output).  Please send it via emailed reply-to-all, not
> > via the bugzilla web interface, thanks.
> 
> This is the output of dmesg -s 1000000:
> 
> Linux version 2.6.24.2-dbg (root@INF012) (gcc version 4.1.3 20070929
> (prerelease) (Ubuntu 4.1.2-16ubuntu2)) #1 SMP Tue Feb 12 08:19:21 CET
> 2008
> Command line: root=UUID=4604bcf5-93b6-46ba-9d80-f2f89a844a78 ro quiet splash
> BIOS-provided physical RAM map:
>  BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
>  BIOS-e820: 000000000009fc00 - 0000000000100000 (reserved)
>  BIOS-e820: 0000000000100000 - 000000007e2d9000 (usable)
>  BIOS-e820: 000000007e2d9000 - 000000007e39b000 (ACPI NVS)
>  BIOS-e820: 000000007e39b000 - 000000007fa32000 (usable)
>  BIOS-e820: 000000007fa32000 - 000000007fa9a000 (reserved)
>  BIOS-e820: 000000007fa9a000 - 000000007facc000 (usable)
>  BIOS-e820: 000000007facc000 - 000000007fb1a000 (ACPI NVS)
>  BIOS-e820: 000000007fb1a000 - 000000007fb26000 (usable)
>  BIOS-e820: 000000007fb26000 - 000000007fb3a000 (ACPI data)
>  BIOS-e820: 000000007fb3a000 - 000000007fc00000 (usable)
>  BIOS-e820: 000000007fc00000 - 0000000080000000 (reserved)
>  BIOS-e820: 00000000a0000000 - 00000000b0000000 (reserved)
>  BIOS-e820: 00000000ffe00000 - 00000000ffe0c000 (reserved)
> Entering add_active_range(0, 0, 159) 0 entries of 256 used
> Entering add_active_range(0, 256, 516825) 1 entries of 256 used
> Entering add_active_range(0, 517019, 522802) 2 entries of 256 used
> Entering add_active_range(0, 522906, 522956) 3 entries of 256 used
> Entering add_active_range(0, 523034, 523046) 4 entries of 256 used
> Entering add_active_range(0, 523066, 523264) 5 entries of 256 used
> end_pfn_map = 1048076
> DMI 2.5 present.
> Entering add_active_range(0, 0, 159) 0 entries of 256 used
> Entering add_active_range(0, 256, 516825) 1 entries of 256 used
> Entering add_active_range(0, 517019, 522802) 2 entries of 256 used
> Entering add_active_range(0, 522906, 522956) 3 entries of 256 used
> Entering add_active_range(0, 523034, 523046) 4 entries of 256 used
> Entering add_active_range(0, 523066, 523264) 5 entries of 256 used
> Zone PFN ranges:
>   DMA             0 ->     4096
>   DMA32        4096 ->  1048576
>   Normal    1048576 ->  1048576
> Movable zone start PFN for each node
> early_node_map[6] active PFN ranges
>     0:        0 ->      159
>     0:      256 ->   516825
>     0:   517019 ->   522802
>     0:   522906 ->   522956
>     0:   523034 ->   523046
>     0:   523066 ->   523264
> On node 0 totalpages: 522771
>   DMA zone: 96 pages used for memmap
>   DMA zone: 2170 pages reserved
>   DMA zone: 1733 pages, LIFO batch:0
>   DMA32 zone: 12168 pages used for memmap
>   DMA32 zone: 506604 pages, LIFO batch:31
>   Normal zone: 0 pages used for memmap
>   Movable zone: 0 pages used for memmap

OK, that machine really has no ZONE_NORMAL.  I didn't know we do that.

Mel, is this, uh, normal?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
