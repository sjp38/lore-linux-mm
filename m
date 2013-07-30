Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id C2D646B0031
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 10:30:01 -0400 (EDT)
Date: Tue, 30 Jul 2013 16:29:57 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: hugepage related lockdep trace.
Message-ID: <20130730142957.GG15847@dhcp22.suse.cz>
References: <20130717153223.GD27731@redhat.com>
 <20130718000901.GA31972@blaptop>
 <87hafrdatb.fsf@linux.vnet.ibm.com>
 <20130719001303.GB23354@blaptop>
 <20130723140120.GG8677@dhcp22.suse.cz>
 <20130724024428.GA14795@bbox>
 <20130725133040.GI12818@dhcp22.suse.cz>
 <20130729082453.GB29129@bbox>
 <20130729145308.GG4678@dhcp22.suse.cz>
 <20130729152001.GC22156@laptop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130729152001.GC22156@laptop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Minchan Kim <minchan@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon 29-07-13 17:20:01, Peter Zijlstra wrote:
> On Mon, Jul 29, 2013 at 04:53:08PM +0200, Michal Hocko wrote:
> > Peter, for you context the lockdep splat has been reported
> > here: https://lkml.org/lkml/2013/7/17/381
> > 
> > Minchan has proposed to workaround it by using SINGLE_DEPTH_NESTING
> > https://lkml.org/lkml/2013/7/23/812
> > 
> > my idea was to use a separate class key for hugetlb as it is quite
> > special in many ways:
> > https://lkml.org/lkml/2013/7/25/277
> > 
> > What is the preferred way of fixing such an issue?
> 
> The class is the safer annotation.

OK, I will use the class then. It should prevent other false positives
AFAIU.

> That said; it is a rather horrible issue any which way. This PMD sharing
> is very unique to hugetlbfs (also is that really worth the effort these
> days?) and it will make it impossible to make hugetlbfs swappable.

No idea.

> The other solution is to make the pmd allocation GFP_NOFS.

That would be just papering over the lockdep limitation. So I would
rather stick with something lockdep specific.

I will cook up a patch.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
