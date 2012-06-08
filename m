Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id EE0686B0062
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 19:06:13 -0400 (EDT)
Date: Fri, 8 Jun 2012 16:06:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -V6 07/14] memcg: Add HugeTLB extension
Message-Id: <20120608160612.dea6d1ce.akpm@linux-foundation.org>
In-Reply-To: <87lik920h8.fsf@skywalker.in.ibm.com>
References: <1334573091-18602-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<1334573091-18602-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<alpine.DEB.2.00.1205241436180.24113@chino.kir.corp.google.com>
	<20120527202848.GC7631@skywalker.linux.vnet.ibm.com>
	<87lik920h8.fsf@skywalker.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, mgorman@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.orgMichal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>

On Wed, 30 May 2012 20:13:31 +0530
"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> >> 
> >>  - code: seperating hugetlb bits out from memcg bits to avoid growing 
> >>    mm/memcontrol.c beyond its current 5650 lines, and
> >> 
> >
> > I can definitely look at spliting mm/memcontrol.c 
> >
> >
> >>  - performance: not incurring any overhead of enabling memcg for per-
> >>    page tracking that is unnecessary if users only want to limit hugetlb 
> >>    pages.
> >> 
> 
> Since Andrew didn't sent the patchset to Linus because of this
> discussion, I looked at reworking the patchset as a seperate
> controller. The patchset I sent here
> 
> http://thread.gmane.org/gmane.linux.kernel.mm/79230
> 
> have seen minimal testing. I also folded the fixup patches
> Andrew had in -mm to original patchset.
> 
> Let me know if the changes looks good.

This is starting to be a problem.  I'm still sitting on the old version
of this patchset and it will start to get in the way of other work.

We now have this new version of the patchset which implements a
separate controller but it is unclear to me which way we want to go.

Can the memcg developers please drop everything else and make a
decision here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
