Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 5DBBE6B0044
	for <linux-mm@kvack.org>; Sun, 29 Apr 2012 02:03:13 -0400 (EDT)
Date: Sun, 29 Apr 2012 08:03:06 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC][PATCH 0/7 v2] memcg: prevent failure in pre_destroy()
Message-ID: <20120429060306.GA22553@tiehlicka.suse.cz>
References: <4F9A327A.6050409@jp.fujitsu.com>
 <20120427181642.GG26595@google.com>
 <CABEgKgrir3PBGqm_9FmYsZTiFqsZ=Cdt5iZDu5WcOHPtZuEbFg@mail.gmail.com>
 <20120428161358.GA13010@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120428161358.GA13010@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Glauber Costa <glommer@parallels.com>, Han Ying <yinghan@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Sat 28-04-12 18:13:58, Michal Hocko wrote:
> On Sat 28-04-12 08:48:18, Hiroyuki Kamezawa wrote:
> > On Sat, Apr 28, 2012 at 3:16 AM, Tejun Heo <tj@kernel.org> wrote:
> > > Hello,
> > >
> > > On Fri, Apr 27, 2012 at 02:45:30PM +0900, KAMEZAWA Hiroyuki wrote:
> > >> This is a v2 patch for preventing failure in memcg->pre_destroy().
> > >> With this patch, ->pre_destroy() will never return error code and
> > >> users will not see warning at rmdir(). And this work will simplify
> > >> memcg->pre_destroy(), largely.
> > >>
> > >> This patch is based on linux-next + hugetlb memory control patches.
> > >
> > > Ergh... can you please set up a git branch somewhere for review
> > > purposes?
> > >
> > I'm sorry...I can't. (To do that, I need to pass many my company's check.)
> > I'll repost all a week later, hugetlb tree will be seen in memcg-devel or
> > linux-next.
> 
> I can push it to memcg-devel tree if you want.

As a separate branch of course...

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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
