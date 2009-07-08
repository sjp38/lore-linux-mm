Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 631F06B004D
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 10:14:19 -0400 (EDT)
Received: from coyote.coyote.den ([72.65.71.44]) by vms173017.mailsrvcs.net
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008; 32bit))
 with ESMTPA id <0KMG004PUVYJ4P40@vms173017.mailsrvcs.net> for
 linux-mm@kvack.org; Wed, 08 Jul 2009 09:23:08 -0500 (CDT)
From: Gene Heskett <gene.heskett@verizon.net>
Subject: Re: OOM killer in 2.6.31-rc2
Date: Wed, 08 Jul 2009 10:22:50 -0400
References: <200907061056.00229.gene.heskett@verizon.net>
 <20090708051515.GA17156@localhost> <20090708075501.GA1122@localhost>
In-reply-to: <20090708075501.GA1122@localhost>
MIME-version: 1.0
Content-type: Text/Plain; charset=iso-8859-1
Content-transfer-encoding: quoted-printable
Content-disposition: inline
Message-id: <200907081022.52758.gene.heskett@verizon.net>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@gmail.com>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Minchan Kim <minchan.kim@gmail.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>, David Howells <dhowells@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wednesday 08 July 2009, Wu Fengguang wrote:
>On Wed, Jul 08, 2009 at 01:15:15PM +0800, Wu Fengguang wrote:

>> I guess you can only use 3G ram because there is a big memory hole.
>> Your HighMem zone spanned 951810 pages, 813013 of which is present.
>> So it's not quite accurate for the OOM message "951810 pages HighMem"
>> to report the spanned pages.
>>
>> Your Normal zone has 221994 present pages, while the OOM message shows
>> "slab:206505", which indicates that the OOM is caused by too much
>> slab pages(they cannot be allocated from HighMem zone).
>>
>> I guess your near 800MB slab cache is somehow under scanned.
>
>Gene, can you run .31 with this patch? When OOM happens, it will tell
>us whether the majority slab pages are reclaimable. Another way to
>find things out is to run `slabtop` when your system is moderately loaded.

Yes, as of 9:55am this patch is running, and I have a session of slabtop (a=
nd=20
although it is old, it is a new one to me, so I'm not sure what a normal=20
report should look like) running.

This is also without the HIGH_MEM64G, so I only have about 3.5G of ram=20
showing.

There is one line early in the dmesg that needs clarified:

[    0.000000] TOM2: 0000000120000000 aka 4608M

that is more memory than is in the machine unless its somehow counting the =
DDR=20
ram on the video card, and IIRC that is only 256megs in any event.  Swap is=
=20
not mounted by that point, much later.

Also from this dmesg:
[    0.000000] On node 0 totalpages: 917103
[    0.000000] free_area_init_node: node 0, pgdat c13f5400, node_mem_map=20
c14bf200
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3951 pages, LIFO batch:0
[    0.000000]   Normal zone: 1744 pages used for memmap
[    0.000000]   Normal zone: 221486 pages, LIFO batch:31
[    0.000000]   HighMem zone: 5390 pages used for memmap
[    0.000000]   HighMem zone: 684500 pages, LIFO batch:31
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
is this correct?

=46rom slabtop right now:
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Active / Total Objects (% used)    : 321146 / 349617 (91.9%)
Active / Total Slabs (% used)      : 22464 / 22483 (99.9%)
Active / Total Caches (% used)     : 101 / 163 (62.0%)
Active / Total Size (% used)       : 81250.57K / 85788.52K (94.7%)
Minimum / Average / Maximum Object : 0.01K / 0.24K / 4096.00K
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Humm, that is running in an x terminal, I'll start one on tty2 also.
I might have a better chance of seeing it after x dies.

=46WIW, 2.6.30.1, also built w/o that 64G flag, and with the newest bios, a=
lso=20
ran all night, which surprised me.  I half expected to wake up to a dead=20
machine.  I have every time I installed that bios before...

Now we wait...  Thanks, Fengguang

[...]

=2D-=20
Cheers, Gene
"There are four boxes to be used in defense of liberty:
 soap, ballot, jury, and ammo. Please use in that order."
=2DEd Howdershelt (Author)
The NRA is offering FREE Associate memberships to anyone who wants them.
<https://www.nrahq.org/nrabonus/accept-membership.asp>

"I'd love to go out with you, but the last time I went out, I never came=20
back."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
