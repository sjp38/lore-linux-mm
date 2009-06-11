Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 536226B004D
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 11:57:53 -0400 (EDT)
Message-ID: <4A3129E3.3010309@redhat.com>
Date: Thu, 11 Jun 2009 11:59:31 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/5] HWPOISON: fix tasklist_lock/anon_vma locking order
References: <20090611142239.192891591@intel.com> <20090611144430.540500784@intel.com>
In-Reply-To: <20090611144430.540500784@intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Wu Fengguang wrote:
> To avoid possible deadlock. Proposed by Nick Piggin:
> 
>   You have tasklist_lock(R) nesting outside i_mmap_lock, and inside anon_vma
>   lock. And anon_vma lock nests inside i_mmap_lock.
> 
>   This seems fragile. If rwlocks ever become FIFO or tasklist_lock changes
>   type (maybe -rt kernels do it), then you could have a task holding
>   anon_vma lock and waiting for tasklist_lock, and another holding tasklist
>   lock and waiting for i_mmap_lock, and another holding i_mmap_lock and
>   waiting for anon_vma lock.
> 
> CC: Nick Piggin <npiggin@suse.de>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
