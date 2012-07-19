Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id BDE9A6B0093
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 08:55:52 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so5528230pbb.14
        for <linux-mm@kvack.org>; Thu, 19 Jul 2012 05:55:52 -0700 (PDT)
Date: Thu, 19 Jul 2012 05:55:15 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v2] mm/memcg: use exist interface to get css from memcg
In-Reply-To: <5007E00B.6000802@jp.fujitsu.com>
Message-ID: <alpine.LSU.2.00.1207190552440.4949@eggly.anvils>
References: <1342609734-22437-1-git-send-email-liwanp@linux.vnet.ibm.com> <20120719092928.GA2864@tiehlicka.suse.cz> <5007E00B.6000802@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Gavin Shan <shangw@linux.vnet.ibm.com>, Bob Liu <lliubbo@gmail.com>

On Thu, 19 Jul 2012, Kamezawa Hiroyuki wrote:
> (2012/07/19 18:29), Michal Hocko wrote:
> > On Wed 18-07-12 19:08:54, Wanpeng Li wrote:
> > > use exist interface mem_cgroup_css instead of &mem->css.
> > 
> > This interface has been added to enable mem->css outside of
> > mm/memcontrol.c (where we define struct mem_cgroup). There is one user
> > left (hwpoison_filter_task) after recent clean ups.
> > 
> > I think we shouldn't spread the usage inside the mm/memcontrol.c. The
> > compiler inlines the function for all callers added by this patch but I
> > wouldn't rely on it. It is also unfortunate that we cannot convert all
> > dereferences (e.g. const mem_cgroup).
> > Moreover it doesn't add any additional type safety. So I would vote for
> > not taking the patch but if others like it I will not block it.
> > 
> 
> Agreed.

Very strongly agreed: I found it hard to be as polite as you have been.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
