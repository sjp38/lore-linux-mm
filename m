Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8C52D6B01F2
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 12:20:57 -0400 (EDT)
Received: by gyg4 with SMTP id 4so3559738gyg.14
        for <linux-mm@kvack.org>; Tue, 13 Apr 2010 09:20:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100413161326.GG25756@csn.ul.ie>
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>
	 <d74305233536342dfeb1ca7ffe9e83495ce1f285.1271171877.git.minchan.kim@gmail.com>
	 <20100413161326.GG25756@csn.ul.ie>
Date: Wed, 14 Apr 2010 01:20:55 +0900
Message-ID: <j2z28c262361004130920s649c3f41mb35e39aa3621083a@mail.gmail.com>
Subject: Re: [PATCH 6/6] Add comment in alloc_pages_exact_node
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 14, 2010 at 1:13 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Wed, Apr 14, 2010 at 12:25:03AM +0900, Minchan Kim wrote:
>> alloc_pages_exact_node naming makes some people misleading.
>> They considered it following as.
>> "This function will allocate pages from node which I wanted
>> exactly".
>> But it can allocate pages from fallback list if page allocator
>> can't find free page from node user wanted.
>>
>> So let's comment this NOTE.
>>
>
> It's a little tough to read. How about
>
> /*
> =C2=A0* Use this instead of alloc_pages_node when the caller knows
> =C2=A0* exactly which node they need (as opposed to passing in -1
> =C2=A0* for current). Fallback to other nodes will still occur
> =C2=A0* unless __GFP_THISNODE is specified.
> =C2=A0*/

It is better than mine.

>
> That at least will tie in why "exact" is in the name?
>
>> Actually I wanted to change naming with better.
>> ex) alloc_pages_explict_node.
>
> "Explicit" can also be taken to mean "this and only this node".

I agree.
I will repost modified comment after Tejun comment [2/6].
Thanks for quick review, Mel. :)
--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
