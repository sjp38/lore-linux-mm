Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E3D386B004D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 22:11:55 -0400 (EDT)
Received: by gxk20 with SMTP id 20so88423gxk.14
        for <linux-mm@kvack.org>; Wed, 11 Mar 2009 19:11:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090312105622.43A6.A69D9226@jp.fujitsu.com>
References: <20090312100049.43A3.A69D9226@jp.fujitsu.com>
	 <20090312105226.88df3f63.minchan.kim@barrios-desktop>
	 <20090312105622.43A6.A69D9226@jp.fujitsu.com>
Date: Thu, 12 Mar 2009 11:11:53 +0900
Message-ID: <28c262360903111911l4e14685emb0261fe649bc03fa@mail.gmail.com>
Subject: Re: [PATCH] NOMMU: Pages allocated to a ramfs inode's pagecache may
	get wrongly discarded
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, dhowells@redhat.com, torvalds@linux-foundation.org, peterz@infradead.org, Enrik.Berkhan@ge.com, uclinux-dev@uclinux.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@surriel.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 12, 2009 at 11:00 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> Hi, Kosaki-san.
>>
>> I think ramfs pages's unevictablility should not depend on CONFIG_UNEVICTABLE_LRU.
>> It would be better to remove dependency of CONFIG_UNEVICTABLE_LRU ?
>>
>> How about this ?
>> It's just RFC. It's not tested.
>>
>> That's because we can't reclaim that pages regardless of whether there is unevictable list or not
>
> maybe, your patch work.
>
> but we can remove CONFIG_UNEVICTABLE_LRU build option itself completely
> after nommu folks confirmed CONFIG_UNEVICTABLE_LRU works well on their machine
>
> it is more cleaner IMHO.
> What do you think?
>
>

I agree your opinion, totally
Let us wait nommu folks's comments.


-- 
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
