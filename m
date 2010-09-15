Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 00EC46B007D
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 16:38:48 -0400 (EDT)
Message-ID: <4C912ED1.9040309@redhat.com>
Date: Wed, 15 Sep 2010 16:38:41 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] unlink_anon_vmas in __split_vma in case of error
References: <20100915171816.GQ5981@random.random>
In-Reply-To: <20100915171816.GQ5981@random.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, Hugh Dickins <hughd@google.com>, Marcelo Tosatti <mtosatti@redhat.com>
List-ID: <linux-mm.kvack.org>

On 09/15/2010 01:18 PM, Andrea Arcangeli wrote:
> From: Andrea Arcangeli<aarcange@redhat.com>
>
> If __split_vma fails because of an out of memory condition the
> anon_vma_chain isn't teardown and freed potentially leading to rmap
> walks accessing freed vma information plus there's a memleak.
>
> Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
