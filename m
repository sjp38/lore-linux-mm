Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 06E386B0037
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 06:47:19 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fa1so5166899pad.27
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 03:47:16 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id xi3si5493040pab.111.2014.07.18.03.47.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 18 Jul 2014 03:47:16 -0700 (PDT)
Message-ID: <53C8FAA6.9050908@oracle.com>
Date: Fri, 18 Jul 2014 06:44:54 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] shmem: fix faulting into a hole while it's punched,
 take 3
References: <alpine.LSU.2.11.1407150247540.2584@eggly.anvils> <53C7F55B.8030307@suse.cz> <53C7F5FF.7010006@oracle.com>
In-Reply-To: <53C7F5FF.7010006@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Lukas Czerner <lczerner@redhat.com>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 07/17/2014 12:12 PM, Sasha Levin wrote:
> On 07/17/2014 12:10 PM, Vlastimil Babka wrote:
>> > On 07/15/2014 12:28 PM, Hugh Dickins wrote:
>>> >> In the end I decided that we had better look at it as two problems,
>>> >> the trinity faulting starvation, and the indefinite punching loop,
>>> >> so 1/2 and 2/2 present both solutions: belt and braces.
>> > 
>> > I tested that with my reproducer and it was OK, but as I already said, it's not trinity so I didn't observe the new problems in the first place.
> I've started seeing a new hang in the lru code, but I'm not sure if
> it's related to this patch or not (the locks are the same ones, but
> the location is very different).
> 
> I'm looking into that.

Hi Hugh,

The new hang I'm seeing is much simpler to analyse (compared to shmem_fallocate) and
doesn't seem to be related. I'll send a separate mail and Cc you just in case, but
I don't think that this patchset has anything to do with it.

Otherwise, I've been unable to reproduce the shmem_fallocate hang.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
