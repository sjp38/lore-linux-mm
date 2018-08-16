Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id E46A36B0007
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 08:54:21 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id q123-v6so744153pgq.8
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 05:54:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w64-v6sor7264894pfa.81.2018.08.16.05.54.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 Aug 2018 05:54:20 -0700 (PDT)
Date: Thu, 16 Aug 2018 20:54:11 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 2/2] x86/numa_emulation: Introduce uniform split
 capability
Message-ID: <20180816125411.GA3740@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <152738260746.11641.13275998345345705617.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152738261787.11641.828328345742419506.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152738261787.11641.828328345742419506.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: mingo@kernel.org, Wei Yang <richard.weiyang@gmail.com>, David Rientjes <rientjes@google.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, May 26, 2018 at 05:56:57PM -0700, Dan Williams wrote:
...
>
>numa=fake=6
>available: 5 nodes (0-4)
>node 0 cpus: 0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38
>node 0 size: 2648 MB
>node 0 free: 2443 MB
>node 1 cpus: 1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39
>node 1 size: 2672 MB
>node 1 free: 2442 MB
>node 2 cpus: 0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38
>node 2 size: 5291 MB
>node 2 free: 5278 MB

Hi, Dan

I am trying to understand in which case leads to this behavior.

The difference between this and the new one is this node gets too
much memory and leads to no memory for node 5.

I guess the reason is there are mem hole in this region, so it tries to add
FAKE_NODE_MIN_SIZE until it is enough.

FAKE_NODE_MIN_SIZE is 32M, while this fake node is 2000M larger than others.
This means the mem hole is that large?

In which case, eg. the physical numa layout, leads to this behavior?

>node 3 cpus: 1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39
>node 3 size: 2677 MB
>node 3 free: 2665 MB
>node 4 cpus: 1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39
>node 4 size: 2676 MB
>node 4 free: 2663 MB
>node distances:
>node   0   1   2   3   4
>  0:  10  20  10  20  20
>  1:  20  10  20  10  10
>  2:  10  20  10  20  20
>  3:  20  10  20  10  10
>  4:  20  10  20  10  10
>
>
>numa=fake=3U
># numactl --hardware
>available: 6 nodes (0-5)
>node 0 cpus: 0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38
>node 0 size: 2900 MB
>node 0 free: 2637 MB
>node 1 cpus: 0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38
>node 1 size: 3023 MB
>node 1 free: 3012 MB
>node 2 cpus: 0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38
>node 2 size: 2015 MB
>node 2 free: 2004 MB
>node 3 cpus: 1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39
>node 3 size: 2704 MB
>node 3 free: 2522 MB
>node 4 cpus: 1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39
>node 4 size: 2709 MB
>node 4 free: 2698 MB
>node 5 cpus: 1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39
>node 5 size: 2612 MB
>node 5 free: 2601 MB
>node distances:
>node   0   1   2   3   4   5
>  0:  10  10  10  20  20  20
>  1:  10  10  10  20  20  20
>  2:  10  10  10  20  20  20
>  3:  20  20  20  10  10  10
>  4:  20  20  20  10  10  10
>  5:  20  20  20  10  10  10
>

-- 
Wei Yang
Help you, Help me
