Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id EC79F6B0044
	for <linux-mm@kvack.org>; Thu, 13 Dec 2012 13:19:29 -0500 (EST)
Message-ID: <50CA1BD5.4070901@redhat.com>
Date: Thu, 13 Dec 2012 13:17:57 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 1/2]swap: make each swap partition have one address_space
References: <20121210012439.GA18570@kernel.org>
In-Reply-To: <20121210012439.GA18570@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, minchan@kernel.org

On 12/09/2012 08:24 PM, Shaohua Li wrote:
> When I use several fast SSD to do swap, swapper_space.tree_lock is heavily
> contended. This makes each swap partition have one address_space to reduce the
> lock contention. There is an array of address_space for swap. The swap entry
> type is the index to the array.
>
> In my test with 3 SSD, this increases the swapout throughput 20%.
>
> There are some code here which looks unnecessary, for example, moving some code
> from swapops.h to swap.h and soem changes in audit_tree.c. Those are to make
> the code compile.
>
> Signed-off-by: Shaohua Li <shli@fusionio.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
