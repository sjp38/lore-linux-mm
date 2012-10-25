Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id A87F36B0071
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 11:19:28 -0400 (EDT)
Date: Thu, 25 Oct 2012 15:19:27 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC] Support volatile range for anon vma
In-Reply-To: <1351133820-14096-1-git-send-email-minchan@kernel.org>
Message-ID: <0000013a9881a86c-c0fb5823-b6e7-4bea-8707-f6b8eddae14d-000000@email.amazonses.com>
References: <1351133820-14096-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, John Stultz <john.stultz@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Thu, 25 Oct 2012, Minchan Kim wrote:

>  #endif
> +	/*
> +	 * True if page in this vma is reclaimed.

What does that mean? All pages in the vma have been cleared out?

> +	TTU_IGNORE_VOLATILE = (1 << 11),/* ignore volatile */
>  };
>  #define TTU_ACTION(x) ((x) & TTU_ACTION_MASK)
>
>  int try_to_unmap(struct page *, enum ttu_flags flags);
>  int try_to_unmap_one(struct page *, struct vm_area_struct *,
> -			unsigned long address, enum ttu_flags flags);
> +			unsigned long address, enum ttu_flags flags,
> +			bool *is_volatile);

You already pass a vma pointer in. Why do you need to pass a
volatile flag in? Looks like unecessary churn.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
