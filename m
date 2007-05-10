Date: Thu, 10 May 2007 11:41:32 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch] check cpuset mems_allowed for sys_mbind
In-Reply-To: <b040c32a0705101132m5baacb9cx59f15fe9dccfff05@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0705101141160.10271@schroedinger.engr.sgi.com>
References: <b040c32a0705091611mb35258ap334426e42d33372c@mail.gmail.com>
 <20070509164859.15dd347b.pj@sgi.com>  <b040c32a0705091747x75f45eacwbe11fe106be71833@mail.gmail.com>
  <Pine.LNX.4.64.0705091749180.2374@schroedinger.engr.sgi.com>
 <b040c32a0705101132m5baacb9cx59f15fe9dccfff05@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: Paul Jackson <pj@sgi.com>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 10 May 2007, Ken Chen wrote:

> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index da94639..c2aec0e 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -884,6 +884,10 @@ asmlinkage long sys_mbind(unsigned long
>        err = get_nodes(&nodes, nmask, maxnode);
>        if (err)
>                return err;
> +#ifdef CONFIG_CPUSETS
> +       /* Restrict the nodes to the allowed nodes in the cpuset */
> +       nodes_and(nodes, nodes, current->mems_allowed);
> +#endif
>        return do_mbind(start, len, mode, &nodes, flags);

Did I screw up whitespace there?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
