Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 7B0F76B0032
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 19:16:41 -0400 (EDT)
Date: Tue, 20 Aug 2013 16:16:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: readahead: return the value which
 force_page_cache_readahead() returns
Message-Id: <20130820161639.69ffa65b40c5cf761bbb727c@linux-foundation.org>
In-Reply-To: <5212E328.40804@asianux.com>
References: <5212E328.40804@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, rientjes@google.com, sasha.levin@oracle.com, linux@rasmusvillemoes.dk, kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, lczerner@redhat.com, linux-mm@kvack.org

On Tue, 20 Aug 2013 11:31:52 +0800 Chen Gang <gang.chen@asianux.com> wrote:

> force_page_cache_readahead() may fail, so need let the related upper
> system calls know about it by its return value.
> 
> Also let related code pass "scripts/checkpatch.pl's" checking.
> 
> --- a/mm/fadvise.c
> +++ b/mm/fadvise.c
> @@ -107,8 +107,8 @@ SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
>  		 * Ignore return value because fadvise() shall return
>  		 * success even if filesystem can't retrieve a hint,
>  		 */

		^^ look.

> -		force_page_cache_readahead(mapping, f.file, start_index,
> -					   nrpages);
> +		ret = force_page_cache_readahead(mapping, f.file, start_index,
> +						 nrpages);
>  		break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
