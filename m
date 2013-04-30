Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 836486B012F
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 13:36:17 -0400 (EDT)
Date: Tue, 30 Apr 2013 13:36:07 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm, memcg: add rss_huge stat to memory.stat
Message-ID: <20130430173607.GF1229@cmpxchg.org>
References: <alpine.DEB.2.02.1304251440190.27228@chino.kir.corp.google.com>
 <20130426111739.GF31157@dhcp22.suse.cz>
 <alpine.DEB.2.02.1304281432160.5570@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1304291721550.4634@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1304291721550.4634@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Apr 29, 2013 at 05:22:52PM -0700, David Rientjes wrote:
> This exports the amount of anonymous transparent hugepages for each memcg
> via the new "rss_huge" stat in memory.stat.  The units are in bytes.
> 
> This is helpful to determine the hugepage utilization for individual jobs
> on the system in comparison to rss and opportunities where MADV_HUGEPAGE
> may be helpful.
> 
> The amount of anonymous transparent hugepages is also included in "rss"
> for backwards compatibility.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
