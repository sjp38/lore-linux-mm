Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 09EA56B008A
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 09:42:58 -0500 (EST)
Received: by bwz16 with SMTP id 16so8000075bwz.14
        for <linux-mm@kvack.org>; Thu, 23 Dec 2010 06:42:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101223141608.GM3636@n2100.arm.linux.org.uk>
References: <cover.1292443200.git.m.nazarewicz@samsung.com>
	<AANLkTim8_=0+-zM5z4j0gBaw3PF3zgpXQNetEn-CfUGb@mail.gmail.com>
	<20101223100642.GD3636@n2100.arm.linux.org.uk>
	<00ea01cba290$4d67f500$e837df00$%szyprowski@samsung.com>
	<20101223121917.GG3636@n2100.arm.linux.org.uk>
	<4D135004.3070904@samsung.com>
	<20101223134838.GK3636@n2100.arm.linux.org.uk>
	<4D1356D7.2000008@samsung.com>
	<20101223141608.GM3636@n2100.arm.linux.org.uk>
Date: Thu, 23 Dec 2010 16:42:57 +0200
Message-ID: <AANLkTinzsOom5awOr6Y8e7PKRbCWYQOqEbdw9is6HroR@mail.gmail.com>
Subject: Re: [PATCHv8 00/12] Contiguous Memory Allocator
From: Felipe Contreras <felipe.contreras@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Tomasz Fujak <t.fujak@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Daniel Walker <dwalker@codeaurora.org>, Kyungmin Park <kmpark@infradead.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Andrew Morton <akpm@linux-foundation.org>, linux-media@vger.kernel.org, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, Ankita Garg <ankita@in.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 23, 2010 at 4:16 PM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Thu, Dec 23, 2010 at 03:04:07PM +0100, Tomasz Fujak wrote:
>> In other words, should we take your response as yet another NAK?
>> Or would you try harder and at least point us to some direction that
>> would not doom the effort from the very beginning.
>
> What the fsck do you think I've been doing? =C2=A0This is NOT THE FIRST t=
ime
> I've raised this issue. =C2=A0I gave up raising it after the first couple
> of attempts because I wasn't being listened to.
>
> You say about _me_ not being very helpful. =C2=A0How about the CMA propon=
ents
> start taking the issue I've raised seriously, and try to work out how
> to solve it? =C2=A0And how about blaming them for the months of wasted ti=
me
> on this issue _because_ _they_ have chosen to ignore it?

I've also raised the issue for ARM. However, I don't see what is the
big problem.

A generic solution (that I think I already proposed) would be to
reserve a chunk of memory for the CMA that can be removed from the
normally mapped kernel memory through memblock at boot time. The size
of this memory region would be configurable through kconfig. Then, the
CMA would have a "dma" flag or something, and take chunks out of it
until there's no more, and then return errors. That would work for
ARM.

Cheers.

--=20
Felipe Contreras

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
