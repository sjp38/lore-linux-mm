Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 0E65B6B004D
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 15:58:46 -0400 (EDT)
Date: Thu, 1 Nov 2012 19:58:44 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v6 05/29] Add a __GFP_KMEMCG flag
In-Reply-To: <1351771665-11076-6-git-send-email-glommer@parallels.com>
Message-ID: <0000013abd8de069-8d1f5e1f-c717-48ba-b496-cbf9ba6b9b30-000000@email.amazonses.com>
References: <1351771665-11076-1-git-send-email-glommer@parallels.com> <1351771665-11076-6-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Thu, 1 Nov 2012, Glauber Costa wrote:

> This flag is used to indicate to the callees that this allocation is a
> kernel allocation in process context, and should be accounted to
> current's memcg. It takes numerical place of the of the recently removed
> __GFP_NO_KSWAPD.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
