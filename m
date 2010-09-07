Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 41FEF6B004A
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 02:56:04 -0400 (EDT)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Received: from eu_spt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0L8D009XM79BYL80@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 07 Sep 2010 07:56:00 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L8D00ESL79BSK@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 07 Sep 2010 07:55:59 +0100 (BST)
Date: Tue, 07 Sep 2010 08:55:12 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [RFCv5 3/9] mm: cma: Added SysFS support
In-reply-to: <20100907060818.GA2609@kroah.com>
Message-id: <op.vinhiabu7p4s8u@localhost>
Content-transfer-encoding: Quoted-Printable
References: <cover.1283749231.git.mina86@mina86.com>
 <9771a9c07874a642bb587f4c0ebf886d720332b6.1283749231.git.mina86@mina86.com>
 <20100906210747.GA5863@kroah.com> <op.vindmsj07p4s8u@localhost>
 <20100907060818.GA2609@kroah.com>
Sender: owner-linux-mm@kvack.org
To: Greg KH <greg@kroah.com>
Cc: linux-arm-kernel@lists.infradead.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Peter Zijlstra <peterz@infradead.org>, Pawel Osciak <p.osciak@samsung.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, Hans Verkuil <hverkuil@xs4all.nl>, Mel Gorman <mel@csn.ul.ie>, Kyungmin Park <kyungmin.park@samsung.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-media@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>
List-ID: <linux-mm.kvack.org>

> On Tue, Sep 07, 2010 at 07:31:30AM +0200, Micha?? Nazarewicz wrote:
>> Thanks for reviewing the sysfs part.  Actually, I was never really su=
re
>> if I shouldn't rather put this code to debugfs and you got me convinc=
ed
>> that I should.  Sysfs somehow looked more appealing from kernel's API=

>> point of view -- things seem to be more organised in sysfs than in
>> debugfs.  It seems I'll have to port it to debugfs after all

On Tue, 07 Sep 2010 08:08:18 +0200, Greg KH <greg@kroah.com> wrote:
> Yes, debugfs looks like a much better place for this.

I'll fix that in v6 then.

>>>> +static ssize_t cma_sysfs_region_name_show(struct cma_region *reg, =
char *page)
>>>> +{
>>>> +	return reg->name ? snprintf(page, PAGE_SIZE, "%s\n", reg->name) :=
 0;
>>>> +}

>>> Is a name field ever really going to be bigger than a page?

>> For numeric values you are right that snprintf() is a bit paranoid,
>> still I see no good reason why not to use it.

> Same goes for no good reason to use it :)

I somehow prefer to always use "safe" versions of the string manipulatio=
n
functions -- it's better to use it everywhere then to forget it in one
place.  Call to sprintf() is translated to vsnprintf() anyway so there's=

no performance gain.

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
