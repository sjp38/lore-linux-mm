Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E1F6C6B02CF
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 08:34:29 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id e126so2510285pfh.4
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 05:34:29 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l10si66048pfc.203.2018.02.22.05.34.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Feb 2018 05:34:28 -0800 (PST)
Date: Thu, 22 Feb 2018 14:34:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Lsf-pc] [LSF/MM ATTEND] Attend mm summit 2018
Message-ID: <20180222133425.GI30681@dhcp22.suse.cz>
References: <CAKTCnz=rS14Ry7pOC2qiX5wEbRZCKwP_0u7_ncanoV18Gz9=AQ@mail.gmail.com>
 <20180222130341.GF30681@dhcp22.suse.cz>
 <CAKTCnzmsEhMYnAOtN+BtN_6bEa=+fTRYSjB+OR9isfzRruwA_Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKTCnzmsEhMYnAOtN+BtN_6bEa=+fTRYSjB+OR9isfzRruwA_Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, lsf-pc <lsf-pc@lists.linux-foundation.org>

On Fri 23-02-18 00:23:53, Balbir Singh wrote:
> On Fri, Feb 23, 2018 at 12:03 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Thu 22-02-18 13:54:46, Balbir Singh wrote:
> > [...]
> >> 2. Memory cgroups - I don't see a pressing need for many new features,
> >> but I'd like to see if we can revive some old proposals around virtual
> >> memory limits
> >
> > Could you be more specific about usecase(s)?
> 
> I had for a long time a virtual memory limit controller in -mm tree.
> The use case was to fail allocations as opposed to OOM'ing in the
> worst case as we do with the cgroup memory limits (actual page usage
> control). I did not push for it then since I got side-tracked. I'd
> like to pursue a use case for being able to fail allocations as
> opposed to OOM'ing on a per cgroup basis. I'd like to start the
> discussion again.

So you basically want the strict no overcommit on the per memcg level?
I am really skeptical, to be completely honest. The global behavior is
not very usable in most cases already. Making it per-memcg will just
amplify all the issues (application tend to overcommit their virtual
address space). Not to mention that you cannot really prevent from the
OOM killer because there are allocations outside of the address space.

So if you want to push this forward you really need a very good existing
usecase to justifiy the change.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
