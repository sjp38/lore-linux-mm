Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id DBACE6B005C
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 19:08:23 -0400 (EDT)
Date: Wed, 5 Jun 2013 16:08:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v10 22/35] shrinker: convert remaining shrinkers to
 count/scan API
Message-Id: <20130605160821.59adf9ad4efe48144fd9e237@linux-foundation.org>
In-Reply-To: <1370287804-3481-23-git-send-email-glommer@openvz.org>
References: <1370287804-3481-1-git-send-email-glommer@openvz.org>
	<1370287804-3481-23-git-send-email-glommer@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>, Gleb Natapov <gleb@redhat.com>, Chuck Lever <chuck.lever@oracle.com>, "J. Bruce Fields" <bfields@redhat.com>, Trond Myklebust <Trond.Myklebust@netapp.com>

On Mon,  3 Jun 2013 23:29:51 +0400 Glauber Costa <glommer@openvz.org> wrote:

> From: Dave Chinner <dchinner@redhat.com>
> 
> Convert the remaining couple of random shrinkers in the tree to the
> new API.

Gee we have a lot of shrinkers.

> --- a/arch/x86/kvm/mmu.c
> +++ b/arch/x86/kvm/mmu.c
> @@ -4213,13 +4213,14 @@ restart:
>  	spin_unlock(&kvm->mmu_lock);
>  }
>  
> -static int mmu_shrink(struct shrinker *shrink, struct shrink_control *sc)
> +static long
> +mmu_shrink_scan(
> +	struct shrinker		*shrink,
> +	struct shrink_control	*sc)
>
> ...
>
> --- a/net/sunrpc/auth.c
> +++ b/net/sunrpc/auth.c
> -static int
> -rpcauth_cache_shrinker(struct shrinker *shrink, struct shrink_control *sc)
> +static long
> +rpcauth_cache_shrink_scan(
> +	struct shrinker		*shrink,
> +	struct shrink_control	*sc)
> +

It is pretty poor form to switch other people's code into this very
non-standard XFSish coding style.  The maintainers are just going to
have to go wtf and switch it back one day.

Really, it would be best if you were to go through the entire patchset
and undo all this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
