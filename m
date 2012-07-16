Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 6F3196B004D
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 05:02:41 -0400 (EDT)
Received: by ggm4 with SMTP id 4so5710331ggm.14
        for <linux-mm@kvack.org>; Mon, 16 Jul 2012 02:02:40 -0700 (PDT)
Date: Mon, 16 Jul 2012 02:01:55 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH mmotm] mm, oom: reduce dependency on tasklist_lock: fix
In-Reply-To: <20120716080603.GA14664@tiehlicka.suse.cz>
Message-ID: <alpine.LSU.2.00.1207160200200.4056@eggly.anvils>
References: <alpine.DEB.2.00.1206251846020.24838@chino.kir.corp.google.com> <alpine.DEB.2.00.1206291404530.6040@chino.kir.corp.google.com> <alpine.DEB.2.00.1206291406110.6040@chino.kir.corp.google.com> <20120713143206.GA4511@tiehlicka.suse.cz>
 <alpine.LSU.2.00.1207160039120.3936@eggly.anvils> <20120716080603.GA14664@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org

On Mon, 16 Jul 2012, Michal Hocko wrote:
> On Mon 16-07-12 00:42:37, Hugh Dickins wrote:
> > Slab poisoning gave me a General Protection Fault on the
> > 	atomic_dec(&__task_cred(p)->user->processes);
> > line of release_task() called from wait_task_zombie(),
> > every time my dd to USB testing generated a memcg OOM.
> 
> Just curious, was it with the wait-on-pagereclaim patch?

Yes, that's what I was trying to test.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
