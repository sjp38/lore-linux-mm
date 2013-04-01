Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id C6A586B0002
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 05:37:46 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id l10so990457eei.31
        for <linux-mm@kvack.org>; Mon, 01 Apr 2013 02:37:45 -0700 (PDT)
Date: Mon, 1 Apr 2013 11:37:40 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: implement boost mode
Message-ID: <20130401093740.GA30749@dhcp22.suse.cz>
References: <1364801670-10241-1-git-send-email-glommer@parallels.com>
 <51595311.7070509@jp.fujitsu.com>
 <515953AE.3000403@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <515953AE.3000403@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>

On Mon 01-04-13 13:30:22, Glauber Costa wrote:
> On 04/01/2013 01:27 PM, Kamezawa Hiroyuki wrote:
> > (2013/04/01 16:34), Glauber Costa wrote:
> >> There are scenarios in which we would like our programs to run faster.
> >> It is a hassle, when they are contained in memcg, that some of its
> >> allocations will fail and start triggering reclaim. This is not good
> >> for the program, that will now be slower.
> >>
> >> This patch implements boost mode for memcg. It exposes a u64 file
> >> "memcg boost". Every time you write anything to it, it will reduce the
> >> counters by ~20 %. Note that we don't want to actually reclaim pages,
> >> which would defeat the very goal of boost mode. We just make the
> >> res_counters able to accomodate more.
> >>
> >> This file is also available in the root cgroup. But with a slightly
> >> different effect. Writing to it will make more memory physically
> >> available so our programs can profit.
> >>
> >> Please ack and apply.
> >>
> > Nack.
> > 
> >> Signed-off-by: Glauber Costa <glommer@parallels.com>
> > 
> > Please update limit temporary. If you need call-shrink-explicitly-by-user, 
> > I think you can add it.
> > 
> 
> I don't want to shrink memory because that will make applications
> slower. I want them to be faster, so they need to have more memory.
> There is solid research backing up my approach:
> http://www.dilbert.com/fast/2008-05-08/

:)

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
