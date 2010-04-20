Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A29E86B01EF
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 20:18:27 -0400 (EDT)
Received: by yxe39 with SMTP id 39so935855yxe.12
        for <linux-mm@kvack.org>; Mon, 19 Apr 2010 17:20:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1004191238450.9855@router.home>
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>
	 <4BC6E581.1000604@kernel.org>
	 <z2p28c262361004150321sc65e84b4w6cc99927ea85a52b@mail.gmail.com>
	 <4BC6FBC8.9090204@kernel.org>
	 <w2h28c262361004150449qdea5cde9y687c1fce30e665d@mail.gmail.com>
	 <alpine.DEB.2.00.1004161105120.7710@router.home>
	 <1271606079.2100.159.camel@barrios-desktop>
	 <4BCB780C.1030001@kernel.org>
	 <j2h28c262361004181703gd3f4bc19r6d00451e01b779a7@mail.gmail.com>
	 <alpine.DEB.2.00.1004191238450.9855@router.home>
Date: Tue, 20 Apr 2010 09:20:27 +0900
Message-ID: <o2p28c262361004191720n1c2bc086ub93a195b612c7f01@mail.gmail.com>
Subject: Re: [PATCH 2/6] change alloc function in pcpu_alloc_pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 20, 2010 at 2:45 AM, Christoph Lameter
<cl@linux-foundation.org> wrote:
> On Mon, 19 Apr 2010, Minchan Kim wrote:
>
>> Let's tidy my table.
>>
>> I made quick patch to show the concept with one example of pci-dma.
>> (Sorry but I attach patch since web gmail's mangling.)
>>
>> On UMA, we can change alloc_pages with
>> alloc_pages_exact_node(numa_node_id(),....)
>> (Actually, the patch is already merged mmotm)
>
> UMA does not have the concept of nodes. Whatever node you specify is
> irrelevant. Please remove the patch from mmotm.

I didn't change API name. The patch is just for optimization.
http://lkml.org/lkml/2010/4/14/225
I think it's reasonable in UMA.
Why do you want to remove it?

Do you dislike alloc_pages_exact_node naming?
I added comment.
http://lkml.org/lkml/2010/4/14/230
Do you think it isn't enough?

This patch results from misunderstanding of alloc_pages_exact_node.
(http://marc.info/?l=linux-mm&m=127109064101184&w=2)
At that time, I thought naming changing is worth.
But many people don't like it.
Okay. It was just trial and if everyone dislike, I don't have any strong cause.
But this patch series don't relate to it. Again said, It's just for
optimization patch.

Let's clarify other's opinion.

1. "I dislike alloc_pages_exact_node naming. Let's change it with more
clear name."
2. "I hate alloc_pages_exact_node. It's trivial optimization. Let's
remove it and replace it with alloc_pages_node."
3. "alloc_pages_exact_node naming is not bad. Let's add the comment to
clear name"
4. "Let's cleanup alloc_pages_xxx in this change as well as 3.
5. "Please, don't touch. Remain whole of thing like as-is."

I think Chrsitop selects 5 or 1, Tejun selects 2, Mel selects 3, me
want to 4 but is satisfied with 3. Right?

If we selects 5, In future, there are confusing between
alloc_pages_node and alloc_pages_exact_node.So I don't want it.

If we select 2, We already have many place of alloc_pages_exact_node.
And I add this patch series. So most of caller uses alloc_pages_exact_node now.
Isn't it trivial?

So I want 3 at lest although you guys don't like 4.
Please, suggest better idea to me. :)

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
