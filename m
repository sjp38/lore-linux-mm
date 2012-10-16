Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id F0B786B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 15:30:24 -0400 (EDT)
Date: Tue, 16 Oct 2012 19:30:23 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v5 14/14] Add documentation about the kmem controller
In-Reply-To: <507DAF56.9010403@parallels.com>
Message-ID: <0000013a6b0e332a-81258f37-814f-4b7e-8b95-193ecb9d7b9d-000000@email.amazonses.com>
References: <1350382611-20579-1-git-send-email-glommer@parallels.com> <1350382611-20579-15-git-send-email-glommer@parallels.com> <0000013a6ad26c73-d043cf97-c44a-45c1-9cae-0a962e93a005-000000@email.amazonses.com> <507DAF56.9010403@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Tue, 16 Oct 2012, Glauber Costa wrote:

> A limitation of kernel memory use would be good, for example, to prevent
> abuse from non-trusted containers in a high density, shared, container
> environment.

But that would be against intentional abuse by someone who has code that
causes the kernel to use a lot of memory on its behalf. We already need
protection from that without memcg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
