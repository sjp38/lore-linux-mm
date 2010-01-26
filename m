Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 736456B0082
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 09:52:16 -0500 (EST)
Message-ID: <4B5F0179.6070005@redhat.com>
Date: Tue, 26 Jan 2010 09:51:37 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02 of 31] compound_lock
References: <patchbomb.1264513915@v2.random> <1037f5f6264364a9e4cc.1264513917@v2.random>
In-Reply-To: <1037f5f6264364a9e4cc.1264513917@v2.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 01/26/2010 08:51 AM, Andrea Arcangeli wrote:
> From: Andrea Arcangeli<aarcange@redhat.com>
>
> Add a new compound_lock() needed to serialize put_page against
> __split_huge_page_refcount().
>
> Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>

> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -108,6 +108,7 @@ enum pageflags {
>   #ifdef CONFIG_MEMORY_FAILURE
>   	PG_hwpoison,		/* hardware poisoned page. Don't touch */
>   #endif
> +	PG_compound_lock,

Maybe this should be under an #ifdef so it does not take
up a bit flag on 32 bit systems where it isn't compiled?

Other than that,

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
