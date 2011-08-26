Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 490DE6B016A
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 06:48:31 -0400 (EDT)
Date: Fri, 26 Aug 2011 12:48:27 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] oom: skip frozen tasks
Message-ID: <20110826104827.GC9083@tiehlicka.suse.cz>
References: <alpine.DEB.2.00.1108231313520.21637@chino.kir.corp.google.com>
 <20110824101927.GB3505@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1108241226550.31357@chino.kir.corp.google.com>
 <20110825091920.GA22564@tiehlicka.suse.cz>
 <20110825151818.GA4003@redhat.com>
 <20110825164758.GB22564@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1108251404130.18747@chino.kir.corp.google.com>
 <20110826070946.GA7280@tiehlicka.suse.cz>
 <20110826085610.GA9083@tiehlicka.suse.cz>
 <4E576F65.5060009@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4E576F65.5060009@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Fri 26-08-11 14:03:17, Konstantin Khlebnikov wrote:
> Michal Hocko wrote:
> 
> >@@ -450,6 +459,10 @@ static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
> >  			pr_err("Kill process %d (%s) sharing same memory\n",
> >  				task_pid_nr(q), q->comm);
> >  			task_unlock(q);
> >+
> >+			if (frozen(q))
> >+				thaw_process(q);
> >+
> 
> We must thaw task strictly after sending SIGKILL.

Sounds reasonable.

> But anyway I think this is a bad idea.

Why?

> 
> >  			force_sig(SIGKILL, q);
> >  		}
> >

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
