Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 641676B0044
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 16:54:27 -0400 (EDT)
Date: Mon, 26 Mar 2012 22:53:52 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 20/39] autonuma: avoid CFS select_task_rq_fair to return
 -1
Message-ID: <20120326205352.GA5906@redhat.com>
References: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
 <1332783986-24195-21-git-send-email-aarcange@redhat.com>
 <1332790614.16159.188.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1332790614.16159.188.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, Mar 26, 2012 at 09:36:54PM +0200, Peter Zijlstra wrote:
> On Mon, 2012-03-26 at 19:46 +0200, Andrea Arcangeli wrote:
> > Fix to avoid -1 retval.
> 
> Please fold this and the following 5 patches into something sane. 6
> patches changing the same few lines and none of them with a useful
> changelog isn't how we do thing.

I folded the next two patches, and other two patches into the later
CFS patch (still kept 2 patches total for such file as there are two
things happening so it should be simpler to review those
separately).

I should have folded those in the first place but I tried to retain
exact attribution of the fixes but I agree for now the priority should
be given to keep the code as easy to review as possible. So I added
attribution in the header of a common commit as I already did for
other commits before.

You can review the folded version in the autonuma-dev-smt branch which
I just pushed (not fast forward):

git clone --reference linux -b autonuma-dev-smt git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git
check head is 3b1ff002978862264c4a24308bddc5e7da24e9ee
git format-patch 0b100d7

0020-autonuma-avoid-CFS-select_task_rq_fair-to-return-1.patch
0021-autonuma-teach-CFS-about-autonuma-affinity.patch

This should be much simpler to review, sorry for the confusion.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
