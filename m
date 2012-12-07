Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 4CEA46B005D
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 14:35:05 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so592972eek.14
        for <linux-mm@kvack.org>; Fri, 07 Dec 2012 11:35:03 -0800 (PST)
Date: Fri, 7 Dec 2012 20:35:01 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v2 3/6] memcg: rework mem_cgroup_iter to use cgroup
 iterators
Message-ID: <20121207193501.GA10988@dhcp22.suse.cz>
References: <1353955671-14385-1-git-send-email-mhocko@suse.cz>
 <1353955671-14385-4-git-send-email-mhocko@suse.cz>
 <CALWz4ixQR0vHp+mGJdi2q77dMHaG8BZmb+iKfMmT=T0V8X8rAg@mail.gmail.com>
 <CALWz4iwrJtG-YUkA8ZpQC=JDMs3_ZRqwjrg+OEEO+_HA_KM9UA@mail.gmail.com>
 <20121207085839.GB31938@dhcp22.suse.cz>
 <CALWz4iwP5vzqE8O0uyCuBnOwbJX_07CB=CsGpP3yzrtQDkr2Qw@mail.gmail.com>
 <20121207172734.GG31938@dhcp22.suse.cz>
 <CALWz4ixB79DWXBA=DOayRx6X6AT0k2ntYbC4S9WVrBqWL3mmxw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALWz4ixB79DWXBA=DOayRx6X6AT0k2ntYbC4S9WVrBqWL3mmxw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

On Fri 07-12-12 11:16:23, Ying Han wrote:
> On Fri, Dec 7, 2012 at 9:27 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Fri 07-12-12 09:12:25, Ying Han wrote:
> >> On Fri, Dec 7, 2012 at 12:58 AM, Michal Hocko <mhocko@suse.cz> wrote:
> >> > On Thu 06-12-12 19:43:52, Ying Han wrote:
> >> > [...]
> >> >> Forgot to mention, I was testing 3.7-rc6 with the two cgroup changes :
> >> >
> >> > Could you give a try to -mm tree as well. There are some changes for
> >> > memcgs removal in that tree which are not in Linus's tree.
> >>
> >> I will give a try, which patchset you have in mind so i can double check?
> >
> > Have a look at ba5e0e6be1c76fd37508b2825372b28a90a5b729 in my tree.
> 
> Tried the tag: mmotm-2012-12-05-16-59 which includes the commit above.
> The test runs better. Thank you for the pointer.

Interesting.

> Looking into the patch itself, it includes 9 patchset where 6 from
> cgroup and 3 from memcg.
> 
>     Michal Hocko (3):
>           memcg: make mem_cgroup_reparent_charges non failing
>           hugetlb: do not fail in hugetlb_cgroup_pre_destroy
>           Merge remote-tracking branch
> 'tj-cgroups/cgroup-rmdir-updates' into mmotm

These are just follow up fixes. The core memcg changes were merged
earlier cad5c694dce67d8aa307a919d247c6a7e1354264. The commit I referred
to above is the finish of that effort.

>     Tejun Heo (6):
>           cgroup: kill cgroup_subsys->__DEPRECATED_clear_css_refs
>           cgroup: kill CSS_REMOVED
>           cgroup: use cgroup_lock_live_group(parent) in cgroup_create()
>           cgroup: deactivate CSS's and mark cgroup dead before
> invoking ->pre_destroy()
>           cgroup: remove CGRP_WAIT_ON_RMDIR, cgroup_exclude_rmdir()
> and cgroup_release_and_wakeup_rmdir()
>           cgroup: make ->pre_destroy() return void
> 
> Any suggestion of the minimal patchset I need to apply for testing
> this patchset? (hopefully not all of them)

The patches shouldn't make a difference but maybe there was a hidden
bug in the previous code which got visible by the iterators rework (we
stored only css id into the cached cookie so if the group went away in
the meantime would just skip it without noticing). Dunno...

Myabe you can start with cad5c694dce67d8aa307a919d247c6a7e1354264 and
move to cgroup changes after that?

[...]

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
