Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 618676B002C
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 05:24:27 -0400 (EDT)
Received: by qyk27 with SMTP id 27so6931673qyk.14
        for <linux-mm@kvack.org>; Tue, 11 Oct 2011 02:24:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20111010141851.GC17335@redhat.com>
References: <1318255086-7393-1-git-send-email-lliubbo@gmail.com>
	<20111010141851.GC17335@redhat.com>
Date: Tue, 11 Oct 2011 17:24:26 +0800
Message-ID: <CAA_GA1cC=6e6+bFp7on+BtmBp4qgfiyjSzvJQ23F41LobnzNfA@mail.gmail.com>
Subject: Re: [RFC PATCH] mm: thp: make swap configurable
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, riel@redhat.com

Hi Andrea

On Mon, Oct 10, 2011 at 10:18 PM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> Hi Bob,
>
> On Mon, Oct 10, 2011 at 09:58:06PM +0800, Bob Liu wrote:
>> Currently THP do swap by default, user has no control of it.
>> But some applications are swap sensitive, this patch add a boot param
>> and sys file to make it configurable.
>
> Why don't you use mlock or swapoff -a? I doubt we want to handle THP
> pages differently from regular pages with regard to swap or anything
> else, the value is to behave as close as possible to regular
> pages. What you want you can already achieve by other means I think.
>

Thanks for your reply.

Yes, mlock() can do it but it will require a lot of changes in every
user application.
If some of the applications are hugh and complicated(even not opensource), it's
hard to modify them.
Add this patch can make things simple and thp more flexible.

For using swapoff -a, it will disable swap for 4k normal pages.

A simple use case is like this:
a lot of swap sensitive apps run on a machine, it will use thp so we
need to disable swap.
But  this apps are hugh and complicated, it's hard to modify them by mlock().

In addition, there are also some normal and not swap sensitive apps
which don't use thp run on
the same machine, we can still reclaim their memory by swap when lack
of memory.

-- 
Thanks,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
