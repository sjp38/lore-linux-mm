Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B03536B0010
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 15:03:44 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id w22-v6so1416515edr.14
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 12:03:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h2-v6si3600317edr.245.2018.06.28.12.03.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jun 2018 12:03:38 -0700 (PDT)
Date: Thu, 28 Jun 2018 13:39:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Bring OOM notifier callbacks to outside of OOM
 killer.
Message-ID: <20180628113942.GD32348@dhcp22.suse.cz>
References: <1529493638-6389-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.21.1806201528490.16984@chino.kir.corp.google.com>
 <20180621073142.GA10465@dhcp22.suse.cz>
 <2d8c3056-1bc2-9a32-d745-ab328fd587a1@i-love.sakura.ne.jp>
 <20180626170345.GA3593@linux.vnet.ibm.com>
 <20180627072207.GB32348@dhcp22.suse.cz>
 <20180627143125.GW3593@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180627143125.GW3593@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Wed 27-06-18 07:31:25, Paul E. McKenney wrote:
> On Wed, Jun 27, 2018 at 09:22:07AM +0200, Michal Hocko wrote:
> > On Tue 26-06-18 10:03:45, Paul E. McKenney wrote:
> > [...]
> > > 3.	Something else?
> > 
> > How hard it would be to use a different API than oom notifiers? E.g. a
> > shrinker which just kicks all the pending callbacks if the reclaim
> > priority reaches low values (e.g. 0)?
> 
> Beats me.  What is a shrinker?  ;-)

This is a generich mechanism to reclaim memory that is not on standard
LRU lists. Lwn.net surely has some nice coverage (e.g.
https://lwn.net/Articles/548092/).

> More seriously, could you please point me at an exemplary shrinker
> use case so I can see what is involved?

Well, I am not really sure what is the objective of the oom notifier to
point you to the right direction. IIUC you just want to kick callbacks
to be handled sooner under a heavy memory pressure, right? How is that
achieved? Kick a worker?
-- 
Michal Hocko
SUSE Labs
