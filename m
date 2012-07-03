Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 3B1946B0073
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 13:59:22 -0400 (EDT)
Date: Tue, 3 Jul 2012 19:56:56 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [rfc][patch 3/3] mm, memcg: introduce own oom handler to
	iterate only over its own threads
Message-ID: <20120703175656.GA14104@redhat.com>
References: <alpine.DEB.2.00.1206251846020.24838@chino.kir.corp.google.com> <alpine.DEB.2.00.1206251847180.24838@chino.kir.corp.google.com> <4FE94968.6010500@jp.fujitsu.com> <alpine.DEB.2.00.1206261323260.8673@chino.kir.corp.google.com> <alpine.DEB.2.00.1206262229380.32567@chino.kir.corp.google.com> <4FEC1C06.70802@jp.fujitsu.com> <alpine.DEB.2.00.1206291329520.6040@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1206291329520.6040@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org

Sorry for delay,

On 06/29, David Rientjes wrote:
>
> On Thu, 28 Jun 2012, Kamezawa Hiroyuki wrote:
>
> > > It turns out that task->children is not an rcu-protected list so this
> > > doesn't work.
> >
> > Can't we use sighand->lock to iterate children ?
> >
>
> I don't think so, this list is protected by tasklist_lock.  Oleg?

Yes, you are right, ->siglock can't help.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
