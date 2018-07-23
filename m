Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0FAB96B0003
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 11:09:34 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id q141-v6so426753ywg.5
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 08:09:34 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k8-v6sor2307734ybd.88.2018.07.23.08.09.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Jul 2018 08:09:32 -0700 (PDT)
Date: Mon, 23 Jul 2018 08:09:29 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: cgroup-aware OOM killer, how to move forward
Message-ID: <20180723150929.GD1934745@devbig577.frc2.facebook.com>
References: <20180713231630.GB17467@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1807162115180.157949@chino.kir.corp.google.com>
 <20180717173844.GB14909@castle.DHCP.thefacebook.com>
 <20180717194945.GM7193@dhcp22.suse.cz>
 <20180717200641.GB18762@castle.DHCP.thefacebook.com>
 <20180718081230.GP7193@dhcp22.suse.cz>
 <20180718152846.GA6840@castle.DHCP.thefacebook.com>
 <20180719073843.GL7193@dhcp22.suse.cz>
 <20180719170543.GA21770@castle.DHCP.thefacebook.com>
 <20180723141748.GH31229@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180723141748.GH31229@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, hannes@cmpxchg.org, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, akpm@linux-foundation.org, gthelen@google.com

Hello,

On Mon, Jul 23, 2018 at 04:17:48PM +0200, Michal Hocko wrote:
> I am not sure. If you are going to delegate then you are basically
> losing control of the group_oom at A-level. Is this good? What if I
> _want_ to tear down the whole thing if it starts misbehaving because I
> do not trust it?
> 
> The more I think about it the more I am concluding that we should start
> with a more contrained model and require that once parent is
> group_oom == 1 then children have to as well. If we ever find a usecase
> to require a different scheme we can weaker it later. We cannot do that
> other way around.
> 
> Tejun, Johannes what do you think about that?

I'd find the cgroup closest to the root which has the oom group set
and kill the entire subtree.  There's no reason to put any
restrictions on what each cgroup can configure.  The only thing which
matters is is that the effective behavior is what the highest in the
ancestry configures, and, at the system level, it'd conceptually map
to panic_on_oom.

Thanks.

-- 
tejun
