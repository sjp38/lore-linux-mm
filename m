Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 94AE96B005A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 16:30:36 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so6147476pbb.14
        for <linux-mm@kvack.org>; Fri, 29 Jun 2012 13:30:35 -0700 (PDT)
Date: Fri, 29 Jun 2012 13:30:33 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [rfc][patch 3/3] mm, memcg: introduce own oom handler to iterate
 only over its own threads
In-Reply-To: <4FEC1C06.70802@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1206291329520.6040@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1206251846020.24838@chino.kir.corp.google.com> <alpine.DEB.2.00.1206251847180.24838@chino.kir.corp.google.com> <4FE94968.6010500@jp.fujitsu.com> <alpine.DEB.2.00.1206261323260.8673@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1206262229380.32567@chino.kir.corp.google.com> <4FEC1C06.70802@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org

On Thu, 28 Jun 2012, Kamezawa Hiroyuki wrote:

> > It turns out that task->children is not an rcu-protected list so this
> > doesn't work.
> 
> Can't we use sighand->lock to iterate children ?
> 

I don't think so, this list is protected by tasklist_lock.  Oleg?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
