Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B17116B0636
	for <linux-mm@kvack.org>; Thu, 10 May 2018 14:20:03 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e26-v6so1539742wmh.7
        for <linux-mm@kvack.org>; Thu, 10 May 2018 11:20:03 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i20-v6si1385858edg.354.2018.05.10.11.20.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 May 2018 11:20:02 -0700 (PDT)
Subject: Re: [PATCH -next 0/2] ipc/shm: shmat() fixes around nil-page
References: <20180503203243.15045-1-dave@stgolabs.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <8addf0c1-26cd-add9-fb9c-292cc3567014@suse.cz>
Date: Thu, 10 May 2018 20:17:55 +0200
MIME-Version: 1.0
In-Reply-To: <20180503203243.15045-1-dave@stgolabs.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>, akpm@linux-foundation.org, aarcange@redhat.com
Cc: joe.lawrence@redhat.com, gareth.evans@contextis.co.uk, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org, ltp@lists.linux.it

On 05/03/2018 10:32 PM, Davidlohr Bueso wrote:
> Hi,
> 
> These patches fix two issues reported[1] a while back by Joe and Andrea
> around how shmat(2) behaves with nil-page.
> 
> The first reverts a commit that it was incorrectly thought that mapping
> nil-page (address=0) was a no no with MAP_FIXED. This is not the case,
> with the exception of SHM_REMAP; which is address in the second patch.

Can you add appropriate Fixes: tags if possible? I guess patch 1 is
clear, dunno about patch 2...

> I chose two patches because it is easier to backport and it explicitly
> reverts bogus behaviour. Both patches ought to be in -stable and ltp
> testcases need updated (the added testcase around the cve can be modified
> to just test for SHM_RND|SHM_REMAP).

CC'd ltp so they know :)

Thanks,
Vlastimil

> 
> [1] lkml.kernel.org/r/20180430172152.nfa564pvgpk3ut7p@linux-n805
> 
> Thanks! 
> 
> Davidlohr Bueso (2):
>   Revert "ipc/shm: Fix shmat mmap nil-page protection"
>   ipc/shm: fix shmat() nil address after round-down when remapping
> 
>  ipc/shm.c | 19 +++++++++++--------
>  1 file changed, 11 insertions(+), 8 deletions(-)
> 
