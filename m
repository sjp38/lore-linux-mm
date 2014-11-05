Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id E4E926B0074
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 09:15:01 -0500 (EST)
Received: by mail-la0-f48.google.com with SMTP id gq15so738014lab.21
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 06:15:01 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ke10si6423030lbc.41.2014.11.05.06.15.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Nov 2014 06:15:00 -0800 (PST)
Date: Wed, 5 Nov 2014 15:14:58 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/4] OOM, PM: OOM killed task shouldn't escape PM suspend
Message-ID: <20141105141458.GE4527@dhcp22.suse.cz>
References: <1413876435-11720-1-git-send-email-mhocko@suse.cz>
 <2156351.pWp6MNRoWm@vostro.rjw.lan>
 <20141021141159.GE9415@dhcp22.suse.cz>
 <4766859.KSKPTm3b0x@vostro.rjw.lan>
 <20141021142939.GG9415@dhcp22.suse.cz>
 <20141104192705.GA22163@htj.dyndns.org>
 <20141105124620.GB4527@dhcp22.suse.cz>
 <20141105130247.GA14386@htj.dyndns.org>
 <20141105133100.GC4527@dhcp22.suse.cz>
 <20141105134219.GD4527@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141105134219.GD4527@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>

On Wed 05-11-14 14:42:19, Michal Hocko wrote:
> On Wed 05-11-14 14:31:00, Michal Hocko wrote:
> > On Wed 05-11-14 08:02:47, Tejun Heo wrote:
> [...]
> > > Also, why isn't this part of
> > > oom_killer_disable/enable()?  The way they're implemented is really
> > > silly now.  It just sets a flag and returns whether there's a
> > > currently running instance or not.  How were these even useful? 
> > > Why can't you just make disable/enable to what they were supposed to
> > > do from the beginning?
> > 
> > Because then we would block all the potential allocators coming from
> > workqueues or kernel threads which are not frozen yet rather than fail
> > the allocation.
> 
> After thinking about this more it would be doable by using trylock in
> the allocation oom path. I will respin the patch. The API will be
> cleaner this way.
---
