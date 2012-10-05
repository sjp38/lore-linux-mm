Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 49BD26B0085
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 03:05:24 -0400 (EDT)
Date: Fri, 5 Oct 2012 09:05:21 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/2] mm: memcontrol: handle potential crash when rmap
 races with task exit
Message-ID: <20121005070521.GB27757@dhcp22.suse.cz>
References: <1349374157-20604-1-git-send-email-hannes@cmpxchg.org>
 <1349374157-20604-2-git-send-email-hannes@cmpxchg.org>
 <20121004184958.GG27536@dhcp22.suse.cz>
 <20121004201908.GA2625@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121004201908.GA2625@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 04-10-12 16:19:08, Johannes Weiner wrote:
> On Thu, Oct 04, 2012 at 08:49:58PM +0200, Michal Hocko wrote:
> > On Thu 04-10-12 14:09:16, Johannes Weiner wrote:
> > > page_referenced() counts only references of mm's that are associated
> > > with the memcg hierarchy that is being reclaimed.  However, if it
> > > races with the owner of the mm exiting, mm->owner may be NULL.  Don't
> > > crash, just ignore the reference.
> > 
> > This seems to be fixed by Hugh's patch 3a981f48 "memcg: fix use_hierarchy
> > css_is_ancestor oops regression" which seems to be merged already.
> 
> And look who acked the patch.  I'll show myself out...

My memory is a bit fuzzy but I remember we had two alternatives and
Hugh's won.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
