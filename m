Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3E1AD6B01F3
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 01:15:58 -0400 (EDT)
Received: by pwi2 with SMTP id 2so1534522pwi.14
        for <linux-mm@kvack.org>; Thu, 01 Apr 2010 22:15:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100402140406.d3d7f18e.kamezawa.hiroyu@jp.fujitsu.com>
References: <i2i5f4a33681003312105m4cd42e9ayfe35cc0988c401b6@mail.gmail.com>
	 <g2g5f4a33681004012051wedea9538w9da89e210b731422@mail.gmail.com>
	 <20100402140406.d3d7f18e.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 2 Apr 2010 14:15:56 +0900
Message-ID: <z2x28c262361004012215h2b2ea3dbu5260724f97f55b95@mail.gmail.com>
Subject: Re: [Question] race condition in mm/page_alloc.c regarding page->lru?
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: TAO HU <tghk48@motorola.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Ye Yuan.Bo-A22116" <yuan-bo.ye@motorola.com>, Chang Qing-A21550 <Qing.Chang@motorola.com>, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 2, 2010 at 2:04 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 2 Apr 2010 11:51:33 +0800
> TAO HU <tghk48@motorola.com> wrote:
>
>> 2 patches related to page_alloc.c were applied.
>> Does anyone see a connection between the 2 patches and the panic?
>> NOTE: the full patches are attached.
>>
>
> I don't think there are relationship between patches and your panic.
>
> BTW, there is other case about the backlog rather than race in alloc_pages()
> itself. If someone list_del(&page->lru) and the page is already freed,
> you'll see the same backlog later.
> Then, I doubt use-after-free case rather than complicated races.

It does make sense.
Please, grep "page handling" by out-of-mainline code.
If you found out, Please, post it.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
