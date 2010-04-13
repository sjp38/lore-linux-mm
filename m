Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C28C46B0206
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 00:34:53 -0400 (EDT)
Received: by gxk10 with SMTP id 10so1619882gxk.10
        for <linux-mm@kvack.org>; Mon, 12 Apr 2010 21:34:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100412164335.GQ25756@csn.ul.ie>
References: <1270900173-10695-1-git-send-email-lliubbo@gmail.com>
	 <20100412164335.GQ25756@csn.ul.ie>
Date: Tue, 13 Apr 2010 13:34:52 +0900
Message-ID: <i2l28c262361004122134of7f96809va209e779ccd44195@mail.gmail.com>
Subject: Re: [PATCH] code clean rename alloc_pages_exact_node()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Bob Liu <lliubbo@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, cl@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, penberg@cs.helsinki.fi, lethal@linux-sh.org, a.p.zijlstra@chello.nl, nickpiggin@yahoo.com.au, dave@linux.vnet.ibm.com, lee.schermerhorn@hp.com, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Tue, Apr 13, 2010 at 1:43 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Sat, Apr 10, 2010 at 07:49:32PM +0800, Bob Liu wrote:
>> Since alloc_pages_exact_node() is not for allocate page from
>> exact node but just for removing check of node's valid,
>> rename it to alloc_pages_from_valid_node(). Else will make
>> people misunderstanding.
>>
>
> I don't know about this change either but as I introduced the original
> function name, I am biased. My reading of it is - allocate me pages and
> I know exactly which node I need. I see how it it could be read as
> "allocate me pages from exactly this node" but I don't feel the new
> naming is that much clearer either.

Tend to agree.
Then, don't change function name but add some comment?

/*
 * allow pages from fallback if page allocator can't find free page in your nid.
 * If you want to allocate page from exact node, please use
__GFP_THISNODE flags with
 * gfp_mask.
 */
static inline struct page *alloc_pages_exact_node(....

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
