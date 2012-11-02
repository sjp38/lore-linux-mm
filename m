Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 1EEEB6B0044
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 20:04:56 -0400 (EDT)
Date: Thu, 1 Nov 2012 17:04:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v6 00/29] kmem controller for memcg.
Message-Id: <20121101170454.b7713bce.akpm@linux-foundation.org>
In-Reply-To: <1351771665-11076-1-git-send-email-glommer@parallels.com>
References: <1351771665-11076-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

On Thu,  1 Nov 2012 16:07:16 +0400
Glauber Costa <glommer@parallels.com> wrote:

> Hi,
> 
> This work introduces the kernel memory controller for memcg. Unlike previous
> submissions, this includes the whole controller, comprised of slab and stack
> memory.

I'm in the middle of (re)reading all this.  Meanwhile I'll push it all
out to http://ozlabs.org/~akpm/mmots/ for the crazier testers.

One thing:

> Numbers can be found at https://lkml.org/lkml/2012/9/13/239

You claim in the above that the fork worload is 'slab intensive".  Or
at least, you seem to - it's a bit fuzzy.

But how slab intensive is it, really?

What is extremely slab intensive is networking.  The networking guys
are very sensitive to slab performance.  If this hasn't already been
done, could you please determine what impact this has upon networking? 
I expect Eric Dumazet, Dave Miller and Tom Herbert could suggest
testing approaches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
