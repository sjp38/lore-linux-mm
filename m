Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 6654F6B002B
	for <linux-mm@kvack.org>; Wed, 10 Oct 2012 18:37:05 -0400 (EDT)
Date: Thu, 11 Oct 2012 00:36:32 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 19/33] autonuma: memory follows CPU algorithm and
 task/mm_autonuma stats collection
Message-ID: <20121010223632.GB10937@redhat.com>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
 <1349308275-2174-20-git-send-email-aarcange@redhat.com>
 <5075F042.2030206@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5075F042.2030206@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Wed, Oct 10, 2012 at 06:01:38PM -0400, Rik van Riel wrote:
> > +static inline bool last_nid_set(struct page *page, int this_nid)
> > +{
> 
> Could be nice to rename this function to should_migrate_page()...

Done, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
