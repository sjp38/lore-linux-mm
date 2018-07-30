Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1633B6B0003
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 10:04:37 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id g126-v6so7166296ywg.20
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 07:04:37 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y16-v6sor1927954ywg.573.2018.07.30.07.04.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Jul 2018 07:04:30 -0700 (PDT)
Date: Mon, 30 Jul 2018 07:04:26 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: cgroup-aware OOM killer, how to move forward
Message-ID: <20180730140241.GA1206094@devbig004.ftw2.facebook.com>
References: <20180718081230.GP7193@dhcp22.suse.cz>
 <20180718152846.GA6840@castle.DHCP.thefacebook.com>
 <20180719073843.GL7193@dhcp22.suse.cz>
 <20180719170543.GA21770@castle.DHCP.thefacebook.com>
 <20180723141748.GH31229@dhcp22.suse.cz>
 <20180723150929.GD1934745@devbig577.frc2.facebook.com>
 <20180724073230.GE28386@dhcp22.suse.cz>
 <20180724130836.GH1934745@devbig577.frc2.facebook.com>
 <20180724132640.GL28386@dhcp22.suse.cz>
 <20180730080357.GA24267@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180730080357.GA24267@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, hannes@cmpxchg.org, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, akpm@linux-foundation.org, gthelen@google.com

Hello,

On Mon, Jul 30, 2018 at 10:03:57AM +0200, Michal Hocko wrote:
> Please be careful when defining differen oom.group policies within the
> same hierarchy because OOM events at different hierarchy levels can 
> have surprising effects. Example
> 	R
> 	|
> 	A (oom.group = 1)
>        / \
>       B   C (oom.group = 0)
> 
> oom victim living in B resp. C.
> 
> OOM event at R - (e.g. global OOM) or A will kill all tasks in A subtree.
> OOM event at B resp. C will only kill a single process from those
> memcgs. 

That behavior makes perfect sense to me and it maps to panic_on_oom==2
which works.  Roman, what do you think?

Thanks.

-- 
tejun
