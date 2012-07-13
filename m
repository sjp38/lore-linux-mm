Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id AFDEF6B005C
	for <linux-mm@kvack.org>; Fri, 13 Jul 2012 04:21:55 -0400 (EDT)
Date: Fri, 13 Jul 2012 10:21:50 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 -mm] memcg: prevent from OOM with too many dirty pages
Message-ID: <20120713082150.GA1448@tiehlicka.suse.cz>
References: <1340117404-30348-1-git-send-email-mhocko@suse.cz>
 <20120619150014.1ebc108c.akpm@linux-foundation.org>
 <20120620101119.GC5541@tiehlicka.suse.cz>
 <alpine.LSU.2.00.1207111818380.1299@eggly.anvils>
 <20120712070501.GB21013@tiehlicka.suse.cz>
 <20120712141343.e1cb7776.akpm@linux-foundation.org>
 <alpine.LSU.2.00.1207121539150.27721@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1207121539150.27721@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Fengguang Wu <fengguang.wu@intel.com>

On Thu 12-07-12 15:42:53, Hugh Dickins wrote:
> On Thu, 12 Jul 2012, Andrew Morton wrote:
> > On Thu, 12 Jul 2012 09:05:01 +0200
> > Michal Hocko <mhocko@suse.cz> wrote:
> > 
> > > When we are back to the patch. Is it going into 3.5? I hope so and I
> > > think it is really worth stable as well. Andrew?
> > 
> > What patch.   "memcg: prevent OOM with too many dirty pages"?
> 
> Yes.
> 
> > 
> > I wasn't planning on 3.5, given the way it's been churning around.
> 
> I don't know if you had been intending to send it in for 3.5 earlier;
> but I'm sorry if my late intervention on may_enter_fs has delayed it.

Well I should investigate more when the question came up...
 
> > How about we put it into 3.6 and tag it for a -stable backport, so
> > it gets a bit of a run in mainline before we inflict it upon -stable
> > users?
> 
> That sounds good enough to me, but does fall short of Michal's hope.

I would be happier if it went into 3.5 already because the problem (OOM
on too many dirty pages) is real and long term (basically since ever).
We have the patch in SLES11-SP2 for quite some time (the original one
with the may_enter_fs check) and it helped a lot.
The patch was designed as a band aid primarily because it is very simple
that way and with a hope that the real fix will come later.
The decision is up to you Andrew, but I vote for pushing it as soon as
possible and try to come up with something more clever for 3.6.

> 
> Hugh

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
