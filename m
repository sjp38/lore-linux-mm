Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9D3BF6B016A
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 05:10:12 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id p7Q9AAGG027333
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 02:10:10 -0700
Received: from pzk32 (pzk32.prod.google.com [10.243.19.160])
	by hpaq12.eem.corp.google.com with ESMTP id p7Q99OuV030829
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 02:10:08 -0700
Received: by pzk32 with SMTP id 32so4525590pzk.33
        for <linux-mm@kvack.org>; Fri, 26 Aug 2011 02:10:03 -0700 (PDT)
Date: Fri, 26 Aug 2011 02:09:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: skip frozen tasks
In-Reply-To: <4E574CA5.4010701@openvz.org>
Message-ID: <alpine.DEB.2.00.1108260209050.14732@chino.kir.corp.google.com>
References: <20110823073101.6426.77745.stgit@zurg> <alpine.DEB.2.00.1108231313520.21637@chino.kir.corp.google.com> <20110824101927.GB3505@tiehlicka.suse.cz> <alpine.DEB.2.00.1108241226550.31357@chino.kir.corp.google.com> <20110825091920.GA22564@tiehlicka.suse.cz>
 <20110825151818.GA4003@redhat.com> <20110825164758.GB22564@tiehlicka.suse.cz> <alpine.DEB.2.00.1108251404130.18747@chino.kir.corp.google.com> <4E574CA5.4010701@openvz.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Michal Hocko <mhocko@suse.cz>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Fri, 26 Aug 2011, Konstantin Khlebnikov wrote:

> > A much better solution would be to lower the badness score that the oom
> > killer uses for PF_FROZEN threads so that they aren't considered a
> > priority for kill unless there's nothing else left to kill.
> 
> Anyway, oom killer shouldn't loop endlessly if it see TIF_MEMDIE on frozen
> task,
> it must go on and try to kill somebody else. We cannot wait for thawing this
> task.
> 

Did you read my suggestion?  I quoted it above again for you.  The badness 
heuristic would only select those tasks to kill as a last resort in the 
hopes they will eventually be thawed and may exit.  Panicking the entire 
machine for what could be isolated by a cgroup is insanity.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
