Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 3B4EE6B0093
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 19:48:01 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so828149pbc.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 16:48:00 -0800 (PST)
Date: Wed, 14 Nov 2012 16:47:58 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 0/7] fixups for kmemcg
In-Reply-To: <1352948093-2315-1-git-send-email-glommer@parallels.com>
Message-ID: <alpine.DEB.2.00.1211141647410.482@chino.kir.corp.google.com>
References: <1352948093-2315-1-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>

On Thu, 15 Nov 2012, Glauber Costa wrote:

> Andrew,
> 
> As you requested, here are some fixups and clarifications for the kmemcg series.
> It also handles one bug reported by Sasha.
> 

On the series:
Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
