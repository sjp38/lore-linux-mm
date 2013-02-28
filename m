Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 9D48F6B0002
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 18:54:21 -0500 (EST)
Date: Thu, 28 Feb 2013 15:54:19 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mempolicy: fix typo
Message-Id: <20130228155419.cf412612.akpm@linux-foundation.org>
In-Reply-To: <1362029107-3908-2-git-send-email-kosaki.motohiro@gmail.com>
References: <CAJd=RBBxTutPsF+XPZGt44eT1f0uPAQfCvQj_UmwdDg82J=F+A@mail.gmail.com>
	<1362029107-3908-2-git-send-email-kosaki.motohiro@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Dave Jones <davej@redhat.com>, Hillf Danton <dhillf@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Thu, 28 Feb 2013 00:25:07 -0500
kosaki.motohiro@gmail.com wrote:

> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> Currently, n_new is wrongly initialized. start and end parameter
> are inverted. Let's fix it.
> 
> ...
>
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -2390,7 +2390,7 @@ static int shared_policy_replace(struct shared_policy *sp, unsigned long start,
>  
>  				*mpol_new = *n->policy;
>  				atomic_set(&mpol_new->refcnt, 1);
> -				sp_node_init(n_new, n->end, end, mpol_new);
> +				sp_node_init(n_new, end, n->end, mpol_new);
>  				n->end = start;
>  				sp_insert(sp, n_new);
>  				n_new = NULL;

huh.  What were the runtime effects of this problem?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
