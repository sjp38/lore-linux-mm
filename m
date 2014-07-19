Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 46E326B0035
	for <linux-mm@kvack.org>; Sat, 19 Jul 2014 19:45:54 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id z10so7023390pdj.30
        for <linux-mm@kvack.org>; Sat, 19 Jul 2014 16:45:53 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id rz4si9774763pab.184.2014.07.19.16.45.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 19 Jul 2014 16:45:53 -0700 (PDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so7410344pad.36
        for <linux-mm@kvack.org>; Sat, 19 Jul 2014 16:45:52 -0700 (PDT)
Date: Sat, 19 Jul 2014 16:44:15 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 0/2] shmem: fix faulting into a hole while it's punched,
 take 3
In-Reply-To: <53C8FAA6.9050908@oracle.com>
Message-ID: <alpine.LSU.2.11.1407191628450.24073@eggly.anvils>
References: <alpine.LSU.2.11.1407150247540.2584@eggly.anvils> <53C7F55B.8030307@suse.cz> <53C7F5FF.7010006@oracle.com> <53C8FAA6.9050908@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Lukas Czerner <lczerner@redhat.com>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, 18 Jul 2014, Sasha Levin wrote:
> On 07/17/2014 12:12 PM, Sasha Levin wrote:
> > On 07/17/2014 12:10 PM, Vlastimil Babka wrote:
> >> > On 07/15/2014 12:28 PM, Hugh Dickins wrote:
> >>> >> In the end I decided that we had better look at it as two problems,
> >>> >> the trinity faulting starvation, and the indefinite punching loop,
> >>> >> so 1/2 and 2/2 present both solutions: belt and braces.
> >> > 
> >> > I tested that with my reproducer and it was OK, but as I already said, it's not trinity so I didn't observe the new problems in the first place.
> > I've started seeing a new hang in the lru code, but I'm not sure if
> > it's related to this patch or not (the locks are the same ones, but
> > the location is very different).
> > 
> > I'm looking into that.
> 
> Hi Hugh,
> 
> The new hang I'm seeing is much simpler to analyse (compared to shmem_fallocate) and
> doesn't seem to be related. I'll send a separate mail and Cc you just in case, but
> I don't think that this patchset has anything to do with it.

Thanks for testing and following up, Sasha.  I agree, that one is
unrelated.  I've just sent a suggestion in your lru_add_drain_all thread.

> 
> Otherwise, I've been unable to reproduce the shmem_fallocate hang.

Great.  Andrew, I think we can say that it's now safe to send
1/2 shmem: fix faulting into a hole, not taking i_mutex
2/2 shmem: fix splicing from a hole while it's punched
on to Linus whenever suits you.

(You have some other patches in the mainline-later section of the
mmotm/series file: they're okay too, but not in doubt as these two were.)

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
