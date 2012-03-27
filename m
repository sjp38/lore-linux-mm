Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 68A086B0107
	for <linux-mm@kvack.org>; Tue, 27 Mar 2012 13:09:37 -0400 (EDT)
Received: by wgbds10 with SMTP id ds10so112510wgb.26
        for <linux-mm@kvack.org>; Tue, 27 Mar 2012 10:09:35 -0700 (PDT)
Date: Tue, 27 Mar 2012 19:09:30 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 11/39] autonuma: CPU follow memory algorithm
Message-ID: <20120327170929.GA28771@gmail.com>
References: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
 <1332783986-24195-12-git-send-email-aarcange@redhat.com>
 <1332786353.16159.173.camel@twins>
 <4F70C365.8020009@redhat.com>
 <20120326194435.GW5906@redhat.com>
 <CA+55aFwk0Etg_UhoZcKsfFJ7PQNLdQ58xxXiwcA-jemuXdZCZQ@mail.gmail.com>
 <20120326203951.GZ5906@redhat.com>
 <1332837595.16159.208.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1332837595.16159.208.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Dan Smith <danms@us.ibm.com>, Paul Turner <pjt@google.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, Bharata B Rao <bharata.rao@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org


* Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> You can talk pretty much anything down to O(1) that way. Take 
> an algorithm that is O(n) in the number of tasks, since you 
> know you have a pid-space constraint of 30bits you can never 
> have more than 2^30 (aka 1Gi) tasks, hence your algorithm is 
> O(2^30) aka O(1).

We can go even further than that, IIRC all physical states of 
this universe fit into a roughly 2^1000 finite state-space, so 
every computing problem in this universe is O(2^1000), i.e. 
every computing problem we can ever work on is O(1).

Really, I think Andrea is missing the big picture here.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
