Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7ED166B003D
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 11:08:41 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: why my systems never cache more than ~900 MB?
Date: Wed, 25 Mar 2009 02:20:45 +1100
References: <49C89CE0.2090103@wpkg.org>
In-Reply-To: <49C89CE0.2090103@wpkg.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200903250220.45575.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Tomasz Chmielewski <mangoo@wpkg.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 24 March 2009 19:42:08 Tomasz Chmielewski wrote:
> On my (32 bit) systems with more than 1 GB memory it is impossible to cache
> more than about 900 MB. Why?
>
> Caching never goes beyond ~900 MB (i.e. when I read a mounted drive with
> dd):

Because blockdev mappings are limited to lowmem due to sharing their
cache with filesystem metadata cache, which needs kernel mapped memory.
It will >900MB of pagecache data OK (data from regular files)

> # free
>              total       used       free     shared    buffers     cached
> Mem:       2076164     966788    1109376          0     855132      68932
> -/+ buffers/cache:      42724    2033440
> Swap:      2097144          0    2097144
>
>
> Same behaviour on 32 bit machines with 4 GB RAM.
>
> No problems on 64 bit machines.
> I have one 32 bit machine that caches beyond ~900 MB without problems.

Does it have a different user/kernel split?


> Is it some kernel/proc/sys setting that I'm missing?

No, it just can't be done without changing code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
