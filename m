Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 34BC16B026B
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 03:32:33 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b25-v6so1344585eds.17
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 00:32:33 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n38-v6si2185295edn.443.2018.07.24.00.32.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 00:32:31 -0700 (PDT)
Date: Tue, 24 Jul 2018 09:32:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: cgroup-aware OOM killer, how to move forward
Message-ID: <20180724073230.GE28386@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1807162115180.157949@chino.kir.corp.google.com>
 <20180717173844.GB14909@castle.DHCP.thefacebook.com>
 <20180717194945.GM7193@dhcp22.suse.cz>
 <20180717200641.GB18762@castle.DHCP.thefacebook.com>
 <20180718081230.GP7193@dhcp22.suse.cz>
 <20180718152846.GA6840@castle.DHCP.thefacebook.com>
 <20180719073843.GL7193@dhcp22.suse.cz>
 <20180719170543.GA21770@castle.DHCP.thefacebook.com>
 <20180723141748.GH31229@dhcp22.suse.cz>
 <20180723150929.GD1934745@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180723150929.GD1934745@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, hannes@cmpxchg.org, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, akpm@linux-foundation.org, gthelen@google.com

On Mon 23-07-18 08:09:29, Tejun Heo wrote:
> Hello,
> 
> On Mon, Jul 23, 2018 at 04:17:48PM +0200, Michal Hocko wrote:
> > I am not sure. If you are going to delegate then you are basically
> > losing control of the group_oom at A-level. Is this good? What if I
> > _want_ to tear down the whole thing if it starts misbehaving because I
> > do not trust it?
> > 
> > The more I think about it the more I am concluding that we should start
> > with a more contrained model and require that once parent is
> > group_oom == 1 then children have to as well. If we ever find a usecase
> > to require a different scheme we can weaker it later. We cannot do that
> > other way around.
> > 
> > Tejun, Johannes what do you think about that?
> 
> I'd find the cgroup closest to the root which has the oom group set
> and kill the entire subtree.

Yes, this is what we have been discussing. In fact it would match the
behavior which is still sitting in the mmotm tree where we compare
groups.

> There's no reason to put any
> restrictions on what each cgroup can configure.  The only thing which
> matters is is that the effective behavior is what the highest in the
> ancestry configures, and, at the system level, it'd conceptually map
> to panic_on_oom.

Hmm, so do we inherit group_oom? If not, how do we prevent from
unexpected behavior?
-- 
Michal Hocko
SUSE Labs
