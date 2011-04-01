Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B999A8D0040
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 10:04:50 -0400 (EDT)
Date: Fri, 1 Apr 2011 16:04:46 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 0/3] Implementation of cgroup isolation
Message-ID: <20110401140446.GF16661@tiehlicka.suse.cz>
References: <20110328093957.089007035@suse.cz>
 <20110328200332.17fb4b78.kamezawa.hiroyu@jp.fujitsu.com>
 <4D920066.7000609@gmail.com>
 <20110330081853.GC15394@tiehlicka.suse.cz>
 <BANLkTinTKyqv11JPwQ1GszYv5e3xOM=b8A@mail.gmail.com>
 <20110331095306.GA30290@tiehlicka.suse.cz>
 <BANLkTik8g=VZmsn_ZybVVVVco6oNYmakGA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTik8g=VZmsn_ZybVVVVco6oNYmakGA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 31-03-11 11:10:00, Ying Han wrote:
> On Thu, Mar 31, 2011 at 2:53 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Wed 30-03-11 10:59:21, Ying Han wrote:
[...]
> > That was my concern so I made that isolation rather opt-in without
> > modifying the current reclaim logic too much (there are, of course,
> > parts that can be improved).
> 
> So far we are discussing the memory limit only for user pages. Later
> we definitely need a kernel memory slab accounting and also for
> reclaim. If we put them together, do you still have the concern? Sorry
> guess I am just trying to understand the concern w/ example.

If we account the kernel memory then it should be less problematic, I
guess.

[...]
> > Lots of groups is really an issue because we can end up in a situation
> > when everybody is under the limit while there is not much memory left
> > for the kernel. Maybe sum(soft_limit) < kernel_treshold condition would
> > solve this.
> most of the kernel memory are allocated on behalf of processes in
> cgroup. One way of doing that (after having kernel memory accounting)
> is to count in kernel memory into usage_in_bytes. So we have the
> following:
> 
> 1) limit_in_bytes: cap of memory allocation (user + kernel) for cgroup-A
> 2) soft_limit_in_bytes: guarantee of memory allocation  (user +
> kernel) for cgroup-A
> 3) usage_in_bytes: user pages + kernel pages (allocated on behalf of the memcg)
> 
> The above need kernel memory accounting and targeting reclaim. Then we
> have sum(soft_limit) < machine capacity. Hope we can talk a bit in the
> LSF on this too.

Sure. I am looking forward.

> >> The later one breaks the isolation.
> >
> > Sorry, I don't understand. Why would elimination of the global lru
> > scanning break isolation? Or am I misreading you?
> 
> Sorry, i meant the other way around. So we agree on this .

Makes more sense now ;)

Thanks
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
