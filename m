Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E84C66B000A
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 01:39:45 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b17-v6so4953023pff.17
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 22:39:45 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j85-v6si8393011pfa.232.2018.07.05.22.39.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jul 2018 22:39:44 -0700 (PDT)
Date: Fri, 6 Jul 2018 07:39:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Bring OOM notifier callbacks to outside of OOM
 killer.
Message-ID: <20180706053942.GF32658@dhcp22.suse.cz>
References: <20180627143125.GW3593@linux.vnet.ibm.com>
 <20180628113942.GD32348@dhcp22.suse.cz>
 <20180628213105.GP3593@linux.vnet.ibm.com>
 <20180629090419.GD13860@dhcp22.suse.cz>
 <20180629125218.GX3593@linux.vnet.ibm.com>
 <20180629132638.GD5963@dhcp22.suse.cz>
 <20180630170522.GZ3593@linux.vnet.ibm.com>
 <20180702213714.GA7604@linux.vnet.ibm.com>
 <20180703072413.GD16767@dhcp22.suse.cz>
 <20180703160101.GC3593@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180703160101.GC3593@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Tue 03-07-18 09:01:01, Paul E. McKenney wrote:
> On Tue, Jul 03, 2018 at 09:24:13AM +0200, Michal Hocko wrote:
> > On Mon 02-07-18 14:37:14, Paul E. McKenney wrote:
> > [...]
> > > commit d2b8d16b97ac2859919713b2d98b8a3ad22943a2
> > > Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > > Date:   Mon Jul 2 14:30:37 2018 -0700
> > > 
> > >     rcu: Remove OOM code
> > >     
> > >     There is reason to believe that RCU's OOM code isn't really helping
> > >     that much, given that the best it can hope to do is accelerate invoking
> > >     callbacks by a few seconds, and even then only if some CPUs have no
> > >     non-lazy callbacks, a condition that has been observed to be rare.
> > >     This commit therefore removes RCU's OOM code.  If this causes problems,
> > >     it can easily be reinserted.
> > >     
> > >     Reported-by: Michal Hocko <mhocko@kernel.org>
> > >     Reported-by: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
> > >     Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > 
> > I would also note that waiting in the notifier might be a problem on its
> > own because we are holding the oom_lock and the system cannot trigger
> > the OOM killer while we are holding it and waiting for oom_callback_wq
> > event. I am not familiar with the code to tell whether this can deadlock
> > but from a quick glance I _suspect_ that we might depend on __rcu_reclaim
> > and basically an arbitrary callback so no good.
> > 
> > Acked-by: Michal Hocko <mhocko@suse.com>
> > 
> > Thanks!
> 
> Like this?

Thanks!
-- 
Michal Hocko
SUSE Labs
