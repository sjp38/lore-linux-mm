Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id F14066B009D
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 02:32:31 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id eb20so9189782lab.1
        for <linux-mm@kvack.org>; Sun, 14 Jul 2013 23:32:30 -0700 (PDT)
Date: Mon, 15 Jul 2013 10:32:26 +0400
From: Glauber Costa <glommer@gmail.com>
Subject: Re: [PATCH V4 5/6] memcg: patch
 mem_cgroup_{begin,end}_update_page_stat() out if only root memcg exists
Message-ID: <20130715063224.GA3745@localhost.localdomain>
References: <1373044710-27371-1-git-send-email-handai.szj@taobao.com>
 <1373045623-27712-1-git-send-email-handai.szj@taobao.com>
 <20130711145625.GK21667@dhcp22.suse.cz>
 <CAFj3OHV=6YDcbKmSeuF3+oMv1HfZF1RxXHoiLgTk0wH5cJVsiQ@mail.gmail.com>
 <CAFj3OHXF+ZjnaDS2L6ZmuHPx20+7XC9r-s7Gh=_TYOr4Opr4Bw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFj3OHXF+ZjnaDS2L6ZmuHPx20+7XC9r-s7Gh=_TYOr4Opr4Bw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mgorman@suse.de>, Sha Zhengju <handai.szj@taobao.com>

On Fri, Jul 12, 2013 at 09:13:56PM +0800, Sha Zhengju wrote:
> Ooops.... it seems unreachable, change Glauber's email...
> 
> 
> On Fri, Jul 12, 2013 at 8:59 PM, Sha Zhengju <handai.szj@gmail.com> wrote:
> 
> > Add cc to Glauber
> >
Thanks

> >
> > On Thu, Jul 11, 2013 at 10:56 PM, Michal Hocko <mhocko@suse.cz> wrote:
> > > On Sat 06-07-13 01:33:43, Sha Zhengju wrote:
> > >> From: Sha Zhengju <handai.szj@taobao.com>
> > >>
> > >> If memcg is enabled and no non-root memcg exists, all allocated
> > >> pages belongs to root_mem_cgroup and wil go through root memcg
> > >> statistics routines.  So in order to reduce overheads after adding
> > >> memcg dirty/writeback accounting in hot paths, we use jump label to
> > >> patch mem_cgroup_{begin,end}_update_page_stat() in or out when not
> > >> used.
> > >
> > > I do not think this is enough. How much do you save? One atomic read.
> > > This doesn't seem like a killer.
> > >
> > > I hoped we could simply not account at all and move counters to the root
> > > cgroup once the label gets enabled.
> >
> > I have thought of this approach before, but it would probably run into
> > another issue, e.g, each zone has a percpu stock named ->pageset to
> > optimize the increment and decrement operations, and I haven't figure out a
> > simpler and cheaper approach to handle that stock numbers if moving global
> > counters to root cgroup, maybe we can just leave them and can afford the
> > approximation?
> >
> > Glauber have already done lots of works here, in his previous patchset he
> > also tried to move some global stats to root (
> > http://comments.gmane.org/gmane.linux.kernel.cgroups/6291). May I steal
> > some of your ideas here, Glauber? :P
> >
Of course. Please go ahead and keep me posted in my new address.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
