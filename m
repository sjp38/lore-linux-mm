Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 4BA5D6B005C
	for <linux-mm@kvack.org>; Thu, 31 May 2012 16:41:32 -0400 (EDT)
Received: by dakp5 with SMTP id p5so2249597dak.14
        for <linux-mm@kvack.org>; Thu, 31 May 2012 13:41:31 -0700 (PDT)
Date: Thu, 31 May 2012 13:41:29 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v4] slab/mempolicy: always use local policy from interrupt
 context
In-Reply-To: <1338429749-5780-1-git-send-email-tdmackey@twitter.com>
Message-ID: <alpine.DEB.2.00.1205311340170.2764@chino.kir.corp.google.com>
References: <1336431315-29736-1-git-send-email-andi@firstfloor.org> <1338429749-5780-1-git-send-email-tdmackey@twitter.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Mackey <tdmackey@twitter.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, penberg@kernel.org, cl@linux.com

On Wed, 30 May 2012, David Mackey wrote:

> From: Andi Kleen <ak@linux.intel.com>
> 
> slab_node() could access current->mempolicy from interrupt context.
> However there's a race condition during exit where the mempolicy
> is first freed and then the pointer zeroed.
> 
> Using this from interrupts seems bogus anyways. The interrupt
> will interrupt a random process and therefore get a random
> mempolicy. Many times, this will be idle's, which noone can change.
> 
> Just disable this here and always use local for slab
> from interrupts. I also cleaned up the callers of slab_node a bit
> which always passed the same argument.
> 
> I believe the original mempolicy code did that in fact,
> so it's likely a regression.
> 
> v2: send version with correct logic
> v3: simplify. fix typo.
> Reported-by: Arun Sharma <asharma@fb.com>
> Cc: penberg@kernel.org
> Cc: cl@linux.com
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> [tdmackey@twitter.com: Rework patch logic and avoid dereference of current 
> task if in interrupt context.]
> Signed-off-by: David Mackey <tdmackey@twitter.com>

Acked-by: David Rientjes <rientjes@google.com>

Thanks for following up on this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
