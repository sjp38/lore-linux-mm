Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A81BB6B0083
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 23:13:19 -0500 (EST)
Message-ID: <4B7383D5.2080904@redhat.com>
Date: Wed, 10 Feb 2010 23:13:09 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 6/7 -mm] oom: avoid oom killer for lowmem allocations
References: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com> <alpine.DEB.2.00.1002100229410.8001@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1002100229410.8001@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 02/10/2010 11:32 AM, David Rientjes wrote:

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1914,6 +1914,9 @@ rebalance:
>   	 * running out of options and have to consider going OOM
>   	 */
>   	if (!did_some_progress) {
> +		/* The oom killer won't necessarily free lowmem */
> +		if (high_zoneidx<  ZONE_NORMAL)
> +			goto nopage;
>   		if ((gfp_mask&  __GFP_FS)&&  !(gfp_mask&  __GFP_NORETRY)) {
>   			if (oom_killer_disabled)
>   				goto nopage;

Are there architectures that only have one memory zone?

s390 or one of the other virtualized-only architectures perhaps?

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
