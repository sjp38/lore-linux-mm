Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 61EAF6B002C
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 09:40:42 -0400 (EDT)
Message-ID: <4E944750.8080604@redhat.com>
Date: Tue, 11 Oct 2011 09:40:32 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] mm: thp: make swap configurable
References: <1318255086-7393-1-git-send-email-lliubbo@gmail.com> <20111010141851.GC17335@redhat.com> <CAA_GA1cC=6e6+bFp7on+BtmBp4qgfiyjSzvJQ23F41LobnzNfA@mail.gmail.com>
In-Reply-To: <CAA_GA1cC=6e6+bFp7on+BtmBp4qgfiyjSzvJQ23F41LobnzNfA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org

On 10/11/2011 05:24 AM, Bob Liu wrote:

> Yes, mlock() can do it but it will require a lot of changes in every
> user application.
> If some of the applications are hugh and complicated(even not opensource), it's
> hard to modify them.
> Add this patch can make things simple and thp more flexible.
>
> For using swapoff -a, it will disable swap for 4k normal pages.
>
> A simple use case is like this:
> a lot of swap sensitive apps run on a machine, it will use thp so we
> need to disable swap.
> But  this apps are hugh and complicated, it's hard to modify them by mlock().
>
> In addition, there are also some normal and not swap sensitive apps
> which don't use thp run on
> the same machine, we can still reclaim their memory by swap when lack
> of memory.

The normal applications could end up getting transparent
huge pages automatically, which would also disable swap
for them.

At that point, you could run out of memory, because you
disabled swap for 2MB pages.

How do you plan to avoid that?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
