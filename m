Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id F32B26B0002
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 20:26:53 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so235614pde.23
        for <linux-mm@kvack.org>; Tue, 23 Apr 2013 17:26:53 -0700 (PDT)
Message-ID: <517726C8.4030207@linaro.org>
Date: Tue, 23 Apr 2013 17:26:48 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: Summary of LSF-MM Volatile Ranges Discussion
References: <516EE256.2070303@linaro.org> <5175FBEB.4020809@linaro.org> <CACT4Y+a+r8LqiiGfq3rTiwGbacLJ0P+tWVba+G5vVyrikkr+gw@mail.gmail.com>
In-Reply-To: <CACT4Y+a+r8LqiiGfq3rTiwGbacLJ0P+tWVba+G5vVyrikkr+gw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: lsf@lists.linux-foundation.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Paul Turner <pjt@google.com>, Robert Love <rlove@google.com>, Dave Hansen <dave@sr71.net>, Taras Glek <tglek@mozilla.com>, Mike Hommey <mh@glandium.org>, Kostya Serebryany <kcc@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, gthelen@google.com, Rik van Riel <riel@redhat.com>, glommer@parallels.com, mhocko@suse.de

On 04/22/2013 11:51 PM, Dmitry Vyukov wrote:
> Just want to make sure our case does not fall out of the discussion:
> https://code.google.com/p/thread-sanitizer/wiki/VolatileRanges

Yes, while I forgot to mention it in the summary, I did bring it up 
briefly, but I cannot claim to have done it justice.

Personally, while I suspect we might be able to support your desired 
semantics (ie: mark once volatile, always zero-fill, no sigbus) via a 
mode flag

> While reading your email, I remembered that we actually have some
> pages mapped from a file inside the range. So it's like 70TB of ANON
> mapping + few pages in the middle mapped from FILE. The file is mapped
> with MAP_PRIVATE + PROT_READ, it's read-only and not shared.
> But we want to mark the volatile range only once on startup, so
> performance is not a serious concern (while the function in executed
> in say no more than 10ms).
> If the mixed ANON+FILE ranges becomes a serious problem, we are ready
> to remove FILE mappings, because it's only an optimization. I.e. we
> can make it pure ANON mapping.
Well, in my mind, the MAP_PRIVATE mappings are semantically the same as 
anonymous memory with regards to volatility. So I hope this wouldn't be 
an issue.

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
