Date: Tue, 18 Sep 2007 12:56:05 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 4/4] oom: serialize out of memory calls
In-Reply-To: <Pine.LNX.4.64.0709181253280.3953@schroedinger.engr.sgi.com>
Message-ID: <alpine.DEB.0.9999.0709181255320.22517@chino.kir.corp.google.com>
References: <871b7a4fd566de081120.1187786931@v2.random> <Pine.LNX.4.64.0709121658450.4489@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0709131126370.27997@chino.kir.corp.google.com> <Pine.LNX.4.64.0709131136560.9590@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709131139340.30279@chino.kir.corp.google.com> <Pine.LNX.4.64.0709131152400.9999@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0709131732330.21805@chino.kir.corp.google.com> <Pine.LNX.4.64.0709131923410.12159@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709132010050.30494@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709180007420.4624@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709180245170.21326@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709180246350.21326@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709180246580.21326@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709180247250.21326@chino.kir.corp.google.com> <Pine.LNX.4.64.0709181253280.3953@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Sep 2007, Christoph Lameter wrote:

> On Tue, 18 Sep 2007, David Rientjes wrote:
> 
> >  			goto got_pg;
> >  	} else if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
> > +		if (oom_killer_trylock(zonelist)) {
> 
> Condition reversed? We want to restart if the lock is taken right?
> 

All trylocks return non-zero if they are contended, so the conditional is 
correct as written.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
