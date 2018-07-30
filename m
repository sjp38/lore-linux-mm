Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A2D836B0008
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 11:29:53 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id i26-v6so2544460edr.4
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 08:29:53 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id s29-v6si3805156edd.58.2018.07.30.08.29.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 08:29:52 -0700 (PDT)
Date: Mon, 30 Jul 2018 08:29:33 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: cgroup-aware OOM killer, how to move forward
Message-ID: <20180730152928.GA3076@castle>
References: <20180718152846.GA6840@castle.DHCP.thefacebook.com>
 <20180719073843.GL7193@dhcp22.suse.cz>
 <20180719170543.GA21770@castle.DHCP.thefacebook.com>
 <20180723141748.GH31229@dhcp22.suse.cz>
 <20180723150929.GD1934745@devbig577.frc2.facebook.com>
 <20180724073230.GE28386@dhcp22.suse.cz>
 <20180724130836.GH1934745@devbig577.frc2.facebook.com>
 <20180724132640.GL28386@dhcp22.suse.cz>
 <20180730080357.GA24267@dhcp22.suse.cz>
 <20180730140241.GA1206094@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180730140241.GA1206094@devbig004.ftw2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, hannes@cmpxchg.org, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, akpm@linux-foundation.org, gthelen@google.com

On Mon, Jul 30, 2018 at 07:04:26AM -0700, Tejun Heo wrote:
> Hello,
> 
> On Mon, Jul 30, 2018 at 10:03:57AM +0200, Michal Hocko wrote:
> > Please be careful when defining differen oom.group policies within the
> > same hierarchy because OOM events at different hierarchy levels can 
> > have surprising effects. Example
> > 	R
> > 	|
> > 	A (oom.group = 1)
> >        / \
> >       B   C (oom.group = 0)
> > 
> > oom victim living in B resp. C.
> > 
> > OOM event at R - (e.g. global OOM) or A will kill all tasks in A subtree.
> > OOM event at B resp. C will only kill a single process from those
> > memcgs. 
> 
> That behavior makes perfect sense to me and it maps to panic_on_oom==2
> which works.  Roman, what do you think?

I'm totally fine with this behavior, this is what I've suggested initially.
I'll post the patchset soon.

Thanks!
