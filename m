Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9FB3E6B0098
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 11:39:59 -0500 (EST)
Received: by mail-lb0-f179.google.com with SMTP id l4so974673lbv.10
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 08:39:58 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bn10si6966710lbc.108.2014.11.05.08.39.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Nov 2014 08:39:57 -0800 (PST)
Date: Wed, 5 Nov 2014 17:39:56 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/4] OOM, PM: OOM killed task shouldn't escape PM suspend
Message-ID: <20141105163956.GD28226@dhcp22.suse.cz>
References: <4766859.KSKPTm3b0x@vostro.rjw.lan>
 <20141021142939.GG9415@dhcp22.suse.cz>
 <20141104192705.GA22163@htj.dyndns.org>
 <20141105124620.GB4527@dhcp22.suse.cz>
 <20141105130247.GA14386@htj.dyndns.org>
 <20141105133100.GC4527@dhcp22.suse.cz>
 <20141105134219.GD4527@dhcp22.suse.cz>
 <20141105154436.GB14386@htj.dyndns.org>
 <20141105160115.GA28226@dhcp22.suse.cz>
 <20141105162929.GD14386@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141105162929.GD14386@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>

On Wed 05-11-14 11:29:29, Tejun Heo wrote:
> Hello, Michal.
> 
> On Wed, Nov 05, 2014 at 05:01:15PM +0100, Michal Hocko wrote:
> > I am not sure I am following. With the latest patch OOM path is no
> > longer blocked by the PM (aka oom_killer_disable()). Allocations simply
> > fail if the read_trylock fails.
> > oom_killer_disable is moved before tasks are frozen and it will wait for
> > all on-going OOM killers on the write lock. OOM killer is enabled again
> > on the resume path.
> 
> Sure, but why are we exposing new interfaces?  Can't we just make
> oom_killer_disable() first set the disable flag and wait for the
> on-going ones to finish (and make the function fail if it gets chosen
> as an OOM victim)?

Still not following. How do you want to detect an on-going OOM without
any interface around out_of_memory?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
