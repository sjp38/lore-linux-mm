Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 661656B004D
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 04:30:08 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id c4so2141652eek.14
        for <linux-mm@kvack.org>; Fri, 02 Nov 2012 01:30:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121101170454.b7713bce.akpm@linux-foundation.org>
References: <1351771665-11076-1-git-send-email-glommer@parallels.com>
	<20121101170454.b7713bce.akpm@linux-foundation.org>
Date: Fri, 2 Nov 2012 10:30:06 +0200
Message-ID: <CAOJsxLH7w_qvMofLD3sNuWpyJ0FO8CNHVnYo03TvY46R2qryog@mail.gmail.com>
Subject: Re: [PATCH v6 00/29] kmem controller for memcg.
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>

On Fri, Nov 2, 2012 at 2:04 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
> One thing:
>
>> Numbers can be found at https://lkml.org/lkml/2012/9/13/239
>
> You claim in the above that the fork worload is 'slab intensive".  Or
> at least, you seem to - it's a bit fuzzy.
>
> But how slab intensive is it, really?
>
> What is extremely slab intensive is networking.  The networking guys
> are very sensitive to slab performance.  If this hasn't already been
> done, could you please determine what impact this has upon networking?
> I expect Eric Dumazet, Dave Miller and Tom Herbert could suggest
> testing approaches.

IIRC, networking guys have reduced their dependency on slab
performance recently.

Few simple benchmarks to run are hackbench, netperf, and Christoph's
famous microbenchmarks. The sad reality is that you usually have to
wait for few release cycles before people notice that you've destroyed
performance of their favourite workload. :-/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
