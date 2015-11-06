Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 3B81E82F64
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 05:57:27 -0500 (EST)
Received: by wicfv8 with SMTP id fv8so26450742wic.0
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 02:57:26 -0800 (PST)
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com. [209.85.212.180])
        by mx.google.com with ESMTPS id uv3si14089830wjc.161.2015.11.06.02.57.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Nov 2015 02:57:25 -0800 (PST)
Received: by wikq8 with SMTP id q8so27827646wik.1
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 02:57:25 -0800 (PST)
Date: Fri, 6 Nov 2015 11:57:24 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Message-ID: <20151106105724.GG4390@dhcp22.suse.cz>
References: <20151027154138.GA4665@cmpxchg.org>
 <20151027161554.GJ9891@dhcp22.suse.cz>
 <20151027164227.GB7749@cmpxchg.org>
 <20151029152546.GG23598@dhcp22.suse.cz>
 <20151029161009.GA9160@cmpxchg.org>
 <20151104104239.GG29607@dhcp22.suse.cz>
 <20151104195037.GA6872@cmpxchg.org>
 <20151105144002.GB15111@dhcp22.suse.cz>
 <20151105205522.GA1067@cmpxchg.org>
 <20151105225200.GA5432@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151105225200.GA5432@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org, vdavydov@virtuozzo.com, tj@kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 05-11-15 17:52:00, Johannes Weiner wrote:
> On Thu, Nov 05, 2015 at 03:55:22PM -0500, Johannes Weiner wrote:
> > On Thu, Nov 05, 2015 at 03:40:02PM +0100, Michal Hocko wrote:
> > > This would be true if they moved on to the new cgroup API intentionally.
> > > The reality is more complicated though. AFAIK sysmted is waiting for
> > > cgroup2 already and privileged services enable all available resource
> > > controllers by default as I've learned just recently.
> > 
> > Have you filed a report with them? I don't think they should turn them
> > on unless users explicitely configure resource control for the unit.
> 
> Okay, verified with systemd people that they're not planning on
> enabling resource control per default.
> 
> Inflammatory half-truths, man. This is not constructive.

What about Delegate=yes feature then? We have just been burnt by this
quite heavily. AFAIU nspawn@.service and nspawn@.service have this
enabled by default
http://lists.freedesktop.org/archives/systemd-commits/2014-November/007400.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
