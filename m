Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 324A16B0078
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 21:41:45 -0400 (EDT)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Received: from eu_spt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0L8C009CASOVMO60@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 07 Sep 2010 02:41:19 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L8C004E8SOUBP@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 07 Sep 2010 02:41:19 +0100 (BST)
Date: Tue, 07 Sep 2010 03:40:46 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [RFCv5 0/9] CMA + VCMM integration
In-reply-to: <20100906210905.GB5863@kroah.com>
Message-id: <op.vim2x8i87p4s8u@localhost>
Content-transfer-encoding: Quoted-Printable
References: <cover.1283749231.git.mina86@mina86.com>
 <20100906210905.GB5863@kroah.com>
Sender: owner-linux-mm@kvack.org
To: Greg KH <greg@kroah.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Hans Verkuil <hverkuil@xs4all.nl>, Jonathan Corbet <corbet@lwn.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Pawel Osciak <p.osciak@samsung.com>, Peter Zijlstra <peterz@infradead.org>, Russell King <linux@arm.linux.org.uk>, Zach Pfeffer <zpfeffer@codeaurora.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 06 Sep 2010 23:09:05 +0200, Greg KH <greg@kroah.com> wrote:

> On Mon, Sep 06, 2010 at 08:33:50AM +0200, Michal Nazarewicz wrote:
>> Hello everyone,
>>
>> This patchset introduces a draft of a redesign of Zach Pfeffer's
>> VCMM.
>
> What is a VCMM?

Virtual Contiguous Memory Manager.  The version posted by Zach can
be found at: <http://article.gmane.org/gmane.linux.kernel.mm/50090>.
It is an API for managing IO MMU and IO MMU mappings.

> What is a CMA?

Contiguous Memory Manager.  The v4 version can be found at
<http://marc.info/?l=3Dlinux-mm&m=3D128229799415817&w=3D2>.  It is an AP=
I for
allocating large, physically contiguous blocks of memory.

I haven't expected that anyone who haven't already participated in the
discussion about CMA and VCMM will get interested by this patchset
so I was a bit vague in the cover letter.  Sorry about that.

>> Not all of the functionality of the original VCMM has been
>> ported into this patchset.  This is mostly meant as RFC.  Moreover,
>> the code for VCMM implementation in this RFC has not been tested.

> If you haven't even tested it, why should we review it?

Ignore the code then and look just at the documentation, please.
I wanted to post what I have to receive comments about the general
idea and not necessarily the code itself.  Code is just a mean to show
how I see the implementation of the idea described in the documentation.=

Because of all that, I marked the patchset as a RFC rather than a PATCH.=


-- =

Best regards,                                        _     _
| Humble Liege of Serenely Enlightened Majesty of  o' \,=3D./ `o
| Computer Science,  Micha=C5=82 "mina86" Nazarewicz       (o o)
+----[mina86*mina86.com]---[mina86*jabber.org]----ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
