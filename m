Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id B8A886B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 10:03:20 -0400 (EDT)
Date: Wed, 30 May 2012 15:49:53 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 13/35] autonuma: add page structure fields
Message-ID: <20120530134953.GD21339@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
 <1337965359-29725-14-git-send-email-aarcange@redhat.com>
 <1338297385.26856.74.camel@twins>
 <4FC4D58A.50800@redhat.com>
 <1338303251.26856.94.camel@twins>
 <4FC5D973.3080108@gmail.com>
 <1338368763.26856.207.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1338368763.26856.207.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On Wed, May 30, 2012 at 11:06:03AM +0200, Peter Zijlstra wrote:
> The trouble with making this per pmd is that you then get the false
> sharing per pmd, so if there's shared data on the 2m page you'll not
> know where to put it.

The numa hinting page fault is already scanning the pmd only, and it's
working fine. So reducing the page_autonuma to one per pmd would not
reduce the granularity of the information with the default settings
everyone has been using so far, but then it would prevent this runtime
tweak to work:

echo 0 >/sys/kernel/mm/autonuma/knuma_scand/pmd

I'm thinking about it but probably reducing the page_autonuma to one
per pmd is going to be the simplest solution considering by default we
only track the pmd anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
