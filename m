Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A1C706B0169
	for <linux-mm@kvack.org>; Wed, 24 Aug 2011 15:31:35 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id p7OJVXKd029441
	for <linux-mm@kvack.org>; Wed, 24 Aug 2011 12:31:33 -0700
Received: from gxk1 (gxk1.prod.google.com [10.202.11.1])
	by hpaq3.eem.corp.google.com with ESMTP id p7OJVSMi022529
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 Aug 2011 12:31:31 -0700
Received: by gxk1 with SMTP id 1so999650gxk.10
        for <linux-mm@kvack.org>; Wed, 24 Aug 2011 12:31:28 -0700 (PDT)
Date: Wed, 24 Aug 2011 12:31:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: skip frozen tasks
In-Reply-To: <20110824101927.GB3505@tiehlicka.suse.cz>
Message-ID: <alpine.DEB.2.00.1108241226550.31357@chino.kir.corp.google.com>
References: <20110823073101.6426.77745.stgit@zurg> <alpine.DEB.2.00.1108231313520.21637@chino.kir.corp.google.com> <20110824101927.GB3505@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Wed, 24 Aug 2011, Michal Hocko wrote:

> When we are in the global OOM condition then you are right, we have a
> higher chance to panic. I still find the patch an improvement because
> encountering a frozen task and looping over it without any progress
> (even though there are other tasks that could be killed) is more
> probable than having no killable task at all.
> On non-NUMA machines there is even not a big chance that somebody would
> be able to thaw a task as the system is already on knees.
> 

That's obviously false since we call oom_killer_disable() in 
freeze_processes() to disable the oom killer from ever being called in the 
first place, so this is something you need to resolve with Rafael before 
you cause more machines to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
