Date: Tue, 18 Sep 2007 14:01:51 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 6/4] oom: pass null to kfree if zonelist is not cleared
In-Reply-To: <alpine.DEB.0.9999.0709181340060.27785@chino.kir.corp.google.com>
Message-ID: <Pine.LNX.4.64.0709181400440.4494@schroedinger.engr.sgi.com>
References: <871b7a4fd566de081120.1187786931@v2.random>
 <Pine.LNX.4.64.0709131136560.9590@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709131139340.30279@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709131152400.9999@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709131732330.21805@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709131923410.12159@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709132010050.30494@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709180007420.4624@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709180245170.21326@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709180246350.21326@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709180246580.21326@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709181256260.3953@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709181306140.22984@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709181314160.3953@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709181340060.27785@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Sep 2007, David Rientjes wrote:

> Wrong.  Notice what the newly-named try_set_zone_oom() function returns if 
> the kzalloc() fails; this was a specific design decision.  It returns 1, 
> so the conditional in __alloc_pages() fails and the OOM killer progresses 
> as normal.

So if kzalloc fails then we think that the zone is already running an oom 
killer while it may only be active on other zones? Doesnt that create more 
trouble?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
