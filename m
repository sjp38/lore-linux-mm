Date: Wed, 21 Feb 2007 10:22:54 -0500 (EST)
From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 09/29] selinux: tag avc cache alloc as non-critical
In-Reply-To: <20070221144842.396545000@taijtu.programming.kicks-ass.net>
Message-ID: <Pine.LNX.4.64.0702211022340.9134@d.namei>
References: <20070221144304.512721000@taijtu.programming.kicks-ass.net>
 <20070221144842.396545000@taijtu.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Stephen Smalley <sds@tycho.nsa.gov>
List-ID: <linux-mm.kvack.org>

On Wed, 21 Feb 2007, Peter Zijlstra wrote:

> Failing to allocate a cache entry will only harm performance.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
>  security/selinux/avc.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Acked-by: James Morris <jmorris@namei.org>

> 
> Index: linux-2.6-git/security/selinux/avc.c
> ===================================================================
> --- linux-2.6-git.orig/security/selinux/avc.c	2007-02-14 08:31:13.000000000 +0100
> +++ linux-2.6-git/security/selinux/avc.c	2007-02-14 10:10:47.000000000 +0100
> @@ -332,7 +332,7 @@ static struct avc_node *avc_alloc_node(v
>  {
>  	struct avc_node *node;
>  
> -	node = kmem_cache_zalloc(avc_node_cachep, GFP_ATOMIC);
> +	node = kmem_cache_zalloc(avc_node_cachep, GFP_ATOMIC|__GFP_NOMEMALLOC);
>  	if (!node)
>  		goto out;
>  
> 
> 

-- 
James Morris
<jmorris@namei.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
