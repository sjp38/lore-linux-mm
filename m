Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9F1C36B02C3
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 02:50:49 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 12so3567396wmn.1
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 23:50:49 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o123si1798905wmg.87.2017.06.26.23.50.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Jun 2017 23:50:48 -0700 (PDT)
Subject: Re: OOM kills with lots of free swap
References: <CAA25o9T1WmkWJn1LA-vS=W_Qu8pBw3rfMtTreLNu8fLuZjTDsw@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2fc63faa-c4ac-1ea2-c68d-1905af93e306@suse.cz>
Date: Tue, 27 Jun 2017 08:50:47 +0200
MIME-Version: 1.0
In-Reply-To: <CAA25o9T1WmkWJn1LA-vS=W_Qu8pBw3rfMtTreLNu8fLuZjTDsw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>, Linux Memory Management List <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>

[+CC Michal]

On 06/24/2017 01:29 AM, Luigi Semenzato wrote:
> It is fairly easy to trigger OOM-kills with almost empty swap, by
> running several fast-allocating processes in parallel.  I can
> reproduce this on many 3.x kernels (I think I tried also on 4.4 but am
> not sure).  I am hoping this is a known problem.

There was a notable OOM rework by Michal around 4.6 ?, so knowing the
state on recent kernels would be really useful.

In any case, please include the actual oom reports.

> I tried to debug this in the past, by backtracking from the call to
> the OOM code, and adding instrumentation to understand why the task
> failed to allocate (or even make progress, apparently), but my effort
> did not yield results within reasonable time.
> 
> I believe that it is possible that one task succeeds in reclaiming
> pages, and then another task takes those pages before the first task
> has a chance to get them.  But in that case the first task should
> still notice progress and should retry, correct?  Is it possible in
> theory that one task fails to allocate AND fails to make progress
> while other tasks succeed?
> 
> (I asked this question, in not so many words, in 2013, but received no answers.)
> 
> Thanks!
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
