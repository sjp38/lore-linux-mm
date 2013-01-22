Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 9EB726B0005
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 14:49:10 -0500 (EST)
Message-ID: <50FEED30.5090709@redhat.com>
Date: Tue, 22 Jan 2013 14:49:04 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 2/3 v2]swap: make each swap partition have one address_space
References: <20130122022951.GB12293@kernel.org>
In-Reply-To: <20130122022951.GB12293@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, minchan@kernel.org

On 01/21/2013 09:29 PM, Shaohua Li wrote:
>
> When I use several fast SSD to do swap, swapper_space.tree_lock is heavily
> contended. This makes each swap partition have one address_space to reduce the
> lock contention. There is an array of address_space for swap. The swap entry
> type is the index to the array.
>
> In my test with 3 SSD, this increases the swapout throughput 20%.
>
> V1->V2: simplify code
>
> Signed-off-by: Shaohua Li <shli@fusionio.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
