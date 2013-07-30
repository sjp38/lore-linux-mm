Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 804A36B0031
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 11:23:38 -0400 (EDT)
Date: Tue, 30 Jul 2013 17:23:33 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] hugetlb: fix lockdep splat caused by pmd sharing
Message-ID: <20130730152333.GJ15847@dhcp22.suse.cz>
References: <20130730142957.GG15847@dhcp22.suse.cz>
 <1375195560-23888-1-git-send-email-mhocko@suse.cz>
 <20130730145834.GA32226@laptop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130730145834.GA32226@laptop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 30-07-13 16:58:34, Peter Zijlstra wrote:
> On Tue, Jul 30, 2013 at 04:46:00PM +0200, Michal Hocko wrote:
[...]
> > +/*
> > + * Now, reclaim path never holds hugetlbfs_inode->i_mmap_mutex while it could
> > + * hold normal inode->i_mmap_mutex so this annotation avoids a lockdep splat.
> 
> How about something like:
> 
> /*
>  * Hugetlbfs is not reclaimable; therefore its i_mmap_mutex will never
>  * be taken from reclaim -- unlike regular filesystems. This needs an
>  * annotation because huge_pmd_share() does an allocation under
>  * i_mmap_mutex.
>  */
> 
> It clarifies the exact conditions and makes easier to verify the
> validity of the annotation.

Yes, looks much better. Thanks!
---
