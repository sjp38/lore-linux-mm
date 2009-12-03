Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 167A36B003D
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 20:53:43 -0500 (EST)
Date: Thu, 3 Dec 2009 09:53:39 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 21/24] cgroup: define empty css_put() when
	!CONFIG_CGROUPS
Message-ID: <20091203015339.GC8520@localhost>
References: <20091202031231.735876003@intel.com> <20091202043046.420815285@intel.com> <6599ad830912021448h6f939623y43fbe5fde2c36b85@mail.gmail.com> <20091202225243.GO18989@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20091202225243.GO18989@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Nick Piggin <npiggin@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 03, 2009 at 06:52:43AM +0800, Andi Kleen wrote:
> On Wed, Dec 02, 2009 at 02:48:03PM -0800, Paul Menage wrote:
> > On Tue, Dec 1, 2009 at 7:12 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > > --- linux-mm.orig/include/linux/cgroup.h A  A  A  A 2009-11-02 10:18:41.000000000 +0800
> > > +++ linux-mm/include/linux/cgroup.h A  A  2009-11-02 10:26:22.000000000 +0800
> > > @@ -581,6 +581,9 @@ static inline int cgroupstats_build(stru
> > > A  A  A  A return -EINVAL;
> > > A }
> > >
> > > +struct cgroup_subsys_state;
> > > +static inline void css_put(struct cgroup_subsys_state *css) {}
> > > +
> > > A #endif /* !CONFIG_CGROUPS */
> > 
> > This doesn't sound like the right thing to do - if !CONFIG_CGROUPS,
> > then the code shouldn't be able to see a css structure to pass to this
> > function.
> 
> I agree. The high level code should be ifdefed.

Right. Following your suggestion to ifdef the memcg user
hwpoison_filter_task(), this patch can be dropped.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
