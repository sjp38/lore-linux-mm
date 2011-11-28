Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 881236B002D
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 04:17:17 -0500 (EST)
Date: Mon, 28 Nov 2011 10:17:03 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 4/8] mm: memcg: lookup_page_cgroup (almost) never returns
 NULL
Message-ID: <20111128091703.GB9356@cmpxchg.org>
References: <1322062951-1756-1-git-send-email-hannes@cmpxchg.org>
 <1322062951-1756-5-git-send-email-hannes@cmpxchg.org>
 <CAKTCnz=CObdw0z4Qf36=afwwApuTer5C4Jp21QUko-H__q-+aA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKTCnz=CObdw0z4Qf36=afwwApuTer5C4Jp21QUko-H__q-+aA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Nov 28, 2011 at 12:33:31PM +0530, Balbir Singh wrote:
> On Wed, Nov 23, 2011 at 9:12 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > From: Johannes Weiner <jweiner@redhat.com>
> >
> > Pages have their corresponding page_cgroup descriptors set up before
> > they are used in userspace, and thus managed by a memory cgroup.
> >
> > The only time where lookup_page_cgroup() can return NULL is in the
> > page sanity checking code that executes while feeding pages into the
> > page allocator for the first time.
> >
> 
> This is a legacy check from the days when we allocated PC during fault
> time on demand. It might make sense to assert on !pc in DEBUG_VM mode
> at some point in the future

I don't think a BUG_ON bears more information than a null-pointer
dereference.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
