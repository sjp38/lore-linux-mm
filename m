Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 2129B6B0035
	for <linux-mm@kvack.org>; Thu,  1 May 2014 09:36:13 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id b15so2274079eek.20
        for <linux-mm@kvack.org>; Thu, 01 May 2014 06:36:12 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id x47si34222355eel.13.2014.05.01.06.36.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 01 May 2014 06:36:11 -0700 (PDT)
Date: Thu, 1 May 2014 09:36:03 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/2] mm/memcontrol.c: introduce helper
 mem_cgroup_zoneinfo_zone()
Message-ID: <20140501133603.GA25536@cmpxchg.org>
References: <1397862103-31982-1-git-send-email-nasa4836@gmail.com>
 <20140422095923.GD29311@dhcp22.suse.cz>
 <20140428150426.GB24807@dhcp22.suse.cz>
 <20140501125450.GA23420@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140501125450.GA23420@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Jianyu Zhan <nasa4836@gmail.com>, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

[fix Andrew's email address]

On Thu, May 01, 2014 at 08:54:50AM -0400, Johannes Weiner wrote:
> On Mon, Apr 28, 2014 at 05:04:26PM +0200, Michal Hocko wrote:
> > On Tue 22-04-14 11:59:23, Michal Hocko wrote:
> > > On Sat 19-04-14 07:01:43, Jianyu Zhan wrote:
> > > > introduce helper mem_cgroup_zoneinfo_zone(). This will make
> > > > mem_cgroup_iter() code more compact.
> > > 
> > > I dunno. Helpers are usually nice but this one adds more code then it
> > > removes. It also doesn't help the generated code.
> > > 
> > > So I don't see any reason to merge it.
> > 
> > So should we drop it from mmotm?
> 
> Yes, please.
> 
> > > > Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
> > > > ---
> > > >  mm/memcontrol.c | 15 +++++++++++----
> > > >  1 file changed, 11 insertions(+), 4 deletions(-)
> 
> This helper adds no value, but more code and indirection.
> 
> Cc'd Andrew - this is about
> mm-memcontrolc-introduce-helper-mem_cgroup_zoneinfo_zone.patch
> mm-memcontrolc-introduce-helper-mem_cgroup_zoneinfo_zone-checkpatch-fixes.patch
> 
> Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
