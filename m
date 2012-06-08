Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 4C3216B006E
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 15:31:11 -0400 (EDT)
Date: Fri, 8 Jun 2012 14:31:07 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/4] Add a __GFP_SLABMEMCG flag
In-Reply-To: <1339148601-20096-3-git-send-email-glommer@parallels.com>
Message-ID: <alpine.DEB.2.00.1206081430380.4213@router.home>
References: <1339148601-20096-1-git-send-email-glommer@parallels.com> <1339148601-20096-3-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Frederic Weisbecker <fweisbeck@gmail.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Suleiman Souhlal <suleiman@google.com>

On Fri, 8 Jun 2012, Glauber Costa wrote:

>   */
>  #define __GFP_NOTRACK_FALSE_POSITIVE (__GFP_NOTRACK)
>
> -#define __GFP_BITS_SHIFT 25	/* Room for N __GFP_FOO bits */
> +#define __GFP_BITS_SHIFT 26	/* Room for N __GFP_FOO bits */
>  #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))

Please make this conditional on CONFIG_MEMCG or so. The bit can be useful
in particular on 32 bit architectures.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
