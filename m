Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 55E3B6B0072
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 10:57:56 -0500 (EST)
Date: Wed, 2 Jan 2013 15:57:54 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] tmpfs mempolicy: fix /proc/mounts corrupting
 memory
In-Reply-To: <alpine.LNX.2.00.1301020153090.18049@eggly.anvils>
Message-ID: <0000013bfbfbb293-ccc455ed-2db6-46e2-8362-dc418bae0def-000000@email.amazonses.com>
References: <alpine.LNX.2.00.1301020153090.18049@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 2 Jan 2013, Hugh Dickins wrote:

> @@ -2756,13 +2747,13 @@ out:
>   * @buffer:  to contain formatted mempolicy string
>   * @maxlen:  length of @buffer
>   * @pol:  pointer to mempolicy to be formatted
> - * @no_context:  "context free" mempolicy - use nodemask in w.user_nodemask
> + * @unused:  redundant argument, to be removed later.
>   *
>   * Convert a mempolicy into a string.
>   * Returns the number of characters in buffer (if positive)
>   * or an error (negative)
>   */
> -int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol, int no_context)
> +int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol, int unused)
>  {
>  	char *p = buffer;
>  	int l;
> @@ -2796,10 +2787,7 @@ int mpol_to_str(char *buffer, int maxlen
>  	case MPOL_BIND:
>  		/* Fall through */
>  	case MPOL_INTERLEAVE:
> -		if (no_context)
> -			nodes = pol->w.user_nodemask;
> -		else
> -			nodes = pol->v.nodes;
> +		nodes = pol->v.nodes;
>  		break;
>

no_context was always true. Why is the code from the false branch kept?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
