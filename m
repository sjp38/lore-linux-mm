Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id A90FB6B0031
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 19:38:03 -0400 (EDT)
Date: Tue, 30 Jul 2013 19:37:23 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] hugetlb: fix lockdep splat caused by pmd sharing
Message-ID: <20130730233722.GA28747@redhat.com>
References: <20130730142957.GG15847@dhcp22.suse.cz>
 <1375195560-23888-1-git-send-email-mhocko@suse.cz>
 <20130730145834.GA32226@laptop.programming.kicks-ass.net>
 <20130730152333.GJ15847@dhcp22.suse.cz>
 <20130730233530.GA19340@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130730233530.GA19340@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jul 31, 2013 at 08:35:30AM +0900, Minchan Kim wrote:
 > > which is a false positive caused by hugetlb pmd sharing code which
 > > allocates a new pmd from withing mappint->i_mmap_mutex. If this
 > > allocation causes reclaim then the lockdep detector complains that we
 > > might self-deadlock.
 > > 
 > > This is not correct though, because hugetlb pages are not reclaimable so
 > > their mapping will be never touched from the reclaim path.
 > > 
 > > The patch tells lockup detector that hugetlb i_mmap_mutex is special
 > > by assigning it a separate lockdep class so it won't report possible
 > > deadlocks on unrelated mappings.
 > > 
 > > [peterz@infradead.org: comment for annotation]
 > > Reported-by: Dave Jones <davej@redhat.com>
 > > Signed-off-by: Michal Hocko <mhocko@suse.cz>
 > Reviewed-by: Minchan Kim <minchan@kernel.org>
 > 
 > Thanks, Michal!
 > Only remained thing is Dave's testing.

I've added it to my builds, all is quiet so far..

	Dave





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
