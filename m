Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id B3CBE6B0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 03:25:11 -0400 (EDT)
Date: Thu, 11 Jul 2013 09:25:07 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH for 3.2] memcg: do not trap chargers with full callstack
 on OOM
Message-ID: <20130711072507.GA21667@dhcp22.suse.cz>
References: <20130624201345.GA21822@cmpxchg.org>
 <20130628120613.6D6CAD21@pobox.sk>
 <20130705181728.GQ17812@cmpxchg.org>
 <20130705210246.11D2135A@pobox.sk>
 <20130705191854.GR17812@cmpxchg.org>
 <20130708014224.50F06960@pobox.sk>
 <20130709131029.GH20281@dhcp22.suse.cz>
 <20130709151921.5160C199@pobox.sk>
 <20130709135450.GI20281@dhcp22.suse.cz>
 <20130710182506.F25DF461@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130710182506.F25DF461@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, righi.andrea@gmail.com

On Wed 10-07-13 18:25:06, azurIt wrote:
> >> Now i realized that i forgot to remove UID from that cgroup before
> >> trying to remove it, so cgroup cannot be removed anyway (we are using
> >> third party cgroup called cgroup-uid from Andrea Righi, which is able
> >> to associate all user's processes with target cgroup). Look here for
> >> cgroup-uid patch:
> >> https://www.develer.com/~arighi/linux/patches/cgroup-uid/cgroup-uid-v8.patch
> >> 
> >> ANYWAY, i'm 101% sure that 'tasks' file was empty and 'under_oom' was
> >> permanently '1'.
> >
> >This is really strange. Could you post the whole diff against stable
> >tree you are using (except for grsecurity stuff and the above cgroup-uid
> >patch)?
> 
> 
> Here are all patches which i applied to kernel 3.2.48 in my last test:
> http://watchdog.sk/lkml/patches3/

The two patches from Johannes seem correct.

>From a quick look even grsecurity patchset shouldn't interfere as it
doesn't seem to put any code between handle_mm_fault and mm_fault_error
and there also doesn't seem to be any new handle_mm_fault call sites.

But I cannot tell there aren't other code paths which would lead to a
memcg charge, thus oom, without proper FAULT_FLAG_KERNEL handling.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
