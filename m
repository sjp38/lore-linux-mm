Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 12BE56B003B
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 16:04:44 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id x12so8070333wgg.30
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 13:04:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id y41si29640114eel.230.2014.04.01.13.04.42
        for <linux-mm@kvack.org>;
        Tue, 01 Apr 2014 13:04:43 -0700 (PDT)
Message-ID: <533B12A6.9020403@redhat.com>
Date: Tue, 01 Apr 2014 15:25:26 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC v5] mm: prototype: rid swapoff of quadratic complexity
References: <20140401051638.GA13715@kelleynnn-virtual-machine>
In-Reply-To: <20140401051638.GA13715@kelleynnn-virtual-machine>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kelley Nielsen <kelleynnn@gmail.com>, jamieliu@google.com
Cc: linux-mm@kvack.org, riel@surriel.com, opw-kernel@googlegroups.com, hughd@google.com, akpm@linux-foundation.org, sarah.a.sharp@intel.com

On 04/01/2014 01:16 AM, Kelley Nielsen wrote:
> The function try_to_unuse() is of quadratic complexity, with a lot of
> wasted effort. It unuses swap entries one by one, potentially iterating
> over all the page tables for all the processes in the system for each
> one.
> 
> This new proposed implementation of try_to_unuse simplifies its
> complexity to linear. It iterates over the system's mms once, unusing
> all the affected entries as it walks each set of page tables. It also
> makes similar changes to shmem_unuse.
> 
> Improvement
> 
> Time took by swapoff on a swap partition containing about 240M of data,
> with about 1.1G free memory and about 520M swap available. Swap
> partition was on a laptop with a hard disk drive (not SSD).
> 
> Present implementation....about 13.8s
> Prototype.................about  5.5s

> TODO
> 
> * Handle count of unused pages for frontswap.

That should probably wait for a follow-up patch. This patch is big
enough as is.

> Signed-off-by: Kelley Nielsen <kelleynnn@gmail.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
