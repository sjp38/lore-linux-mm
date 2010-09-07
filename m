Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 074576B004A
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 01:32:22 -0400 (EDT)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Received: from eu_spt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0L8D00FZI3DWU270@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 07 Sep 2010 06:32:20 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L8D0079G3DVY8@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 07 Sep 2010 06:32:20 +0100 (BST)
Date: Tue, 07 Sep 2010 07:31:30 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [RFCv5 3/9] mm: cma: Added SysFS support
In-reply-to: <20100906210747.GA5863@kroah.com>
Message-id: <op.vindmsj07p4s8u@localhost>
Content-transfer-encoding: Quoted-Printable
References: <cover.1283749231.git.mina86@mina86.com>
 <9771a9c07874a642bb587f4c0ebf886d720332b6.1283749231.git.mina86@mina86.com>
 <20100906210747.GA5863@kroah.com>
Sender: owner-linux-mm@kvack.org
To: Greg KH <greg@kroah.com>
Cc: Hans Verkuil <hverkuil@xs4all.nl>, Peter Zijlstra <peterz@infradead.org>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mel@csn.ul.ie>, Pawel Osciak <p.osciak@samsung.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Minchan Kim <minchan.kim@gmail.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello Greg,

Thanks for reviewing the sysfs part.  Actually, I was never really sure
if I shouldn't rather put this code to debugfs and you got me convinced
that I should.  Sysfs somehow looked more appealing from kernel's API
point of view -- things seem to be more organised in sysfs than in
debugfs.  It seems I'll have to port it to debugfs after all

Nonetheless, a few responses to your comments:

> On Mon, Sep 06, 2010 at 08:33:53AM +0200, Michal Nazarewicz wrote:
>> +		The "allocators" file list all registered allocators.
>> +		Allocators with no name are listed as a single minus
>> +		sign.

On Mon, 06 Sep 2010 23:07:47 +0200, Greg KH <greg@kroah.com> wrote:
> So this returns more than one value?

Aren't thing like cpufreq governors listed in a single sysfs file?
I remember there was such a file somewhere.  Has that been made
deprecated? I cannot seem to find any information on that.

>> +		The "regions" directory list all reserved regions.
>
> Same here?

regions is actually a directory with subdirectories for each
region. ;)

>> +static ssize_t cma_sysfs_region_name_show(struct cma_region *reg, ch=
ar *page)
>> +{
>> +	return reg->name ? snprintf(page, PAGE_SIZE, "%s\n", reg->name) : 0=
;
>> +}

> Is a name field ever really going to be bigger than a page?

I prefer being on the safe side -- I have no idea what user will provide=

as region name so I assume as little as possible.  For numeric values yo=
u
are right that snprintf() is a bit paranoid, still I see no good reason
why not to use it.

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
