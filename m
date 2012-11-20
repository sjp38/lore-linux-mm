Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 41DA76B005D
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 12:27:12 -0500 (EST)
Date: Tue, 20 Nov 2012 12:27:00 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm, memcg: avoid unnecessary function call when memcg is
 disabled
Message-ID: <20121120172700.GA21703@cmpxchg.org>
References: <alpine.DEB.2.00.1211191741060.24618@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1211191741060.24618@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

On Mon, Nov 19, 2012 at 05:44:34PM -0800, David Rientjes wrote:
> While profiling numa/core v16 with cgroup_disable=memory on the command 
> line, I noticed mem_cgroup_count_vm_event() still showed up as high as 
> 0.60% in perftop.
> 
> This occurs because the function is called extremely often even when memcg 
> is disabled.
> 
> To fix this, inline the check for mem_cgroup_disabled() so we avoid the 
> unnecessary function call if memcg is disabled.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
