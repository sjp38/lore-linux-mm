Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A2F956B0078
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 21:59:35 -0400 (EDT)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Received: from eu_spt2 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0L8C00JNXTJ77H20@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 07 Sep 2010 02:59:32 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L8C005B7TJ6HA@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 07 Sep 2010 02:59:31 +0100 (BST)
Date: Tue, 07 Sep 2010 03:58:50 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [RFCv5 8/9] mm: vcm: Sample driver added
In-reply-to: <20100906211054.GC5863@kroah.com>
Message-id: <op.vim3scj57p4s8u@localhost>
Content-transfer-encoding: Quoted-Printable
References: <cover.1283749231.git.mina86@mina86.com>
 <262a5a5019c1f1a44d5793f7e69776e56f27af06.1283749231.git.mina86@mina86.com>
 <20100906211054.GC5863@kroah.com>
Sender: owner-linux-mm@kvack.org
To: Greg KH <greg@kroah.com>
Cc: Hans Verkuil <hverkuil@xs4all.nl>, Peter Zijlstra <peterz@infradead.org>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mel@csn.ul.ie>, Pawel Osciak <p.osciak@samsung.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Minchan Kim <minchan.kim@gmail.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 06 Sep 2010 23:10:54 +0200, Greg KH <greg@kroah.com> wrote:

> On Mon, Sep 06, 2010 at 08:33:58AM +0200, Michal Nazarewicz wrote:
>> --- /dev/null
>> +++ b/include/linux/vcm-sample.h
>
> Don't put "sample" code in include/linux/ please.  That's just
> cluttering up the place, don't you think?  Especially as no one else
> needs the file there...

Absolutely true.  My plan is to put a real driver in place of the sample=

driver and post it with v6.  For now I just wanted to put a piece of cod=
e
that will look like a driver for presentation purposes.  Sorry for the
confusion.

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
