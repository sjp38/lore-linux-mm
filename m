Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 32FD29000BD
	for <linux-mm@kvack.org>; Fri, 23 Sep 2011 15:27:59 -0400 (EDT)
Message-ID: <4E7CDDAD.7010704@redhat.com>
Date: Fri, 23 Sep 2011 15:27:41 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/8] kstaled: documentation and config option.
References: <1316230753-8693-1-git-send-email-walken@google.com> <1316230753-8693-3-git-send-email-walken@google.com>
In-Reply-To: <1316230753-8693-3-git-send-email-walken@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Michael Wolf <mjwolf@us.ibm.com>

On 09/16/2011 11:39 PM, Michel Lespinasse wrote:
> Extend memory cgroup documentation do describe the optional idle page
> tracking features, and add the corresponding configuration option.
>
>
> Signed-off-by: Michel Lespinasse<walken@google.com>

> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -370,3 +370,13 @@ config CLEANCACHE
>   	  in a negligible performance hit.
>
>   	  If unsure, say Y to enable cleancache
> +
> +config KSTALED
> +       depends on CGROUP_MEM_RES_CTLR

Looking at patch #3, I wonder if this needs to be dependent
on 64 bit, or at least make sure this is not selected when
a user builds a 32 bit kernel with NUMA.

The reason is that on a 32 bit system we could run out of
page flags + zone bits + node bits.

> +       bool "Per-cgroup idle page tracking"
> +       help
> +         This feature allows the kernel to report the amount of user pages
> +	 in a cgroup that have not been touched in a given time.
> +	 This information may be used to size the cgroups and/or for
> +	 job placement within a compute cluster.
> +	 See Documentation/cgroups/memory.txt for a more complete description.



-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
