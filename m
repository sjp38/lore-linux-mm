Date: Thu, 13 Sep 2007 11:53:21 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 04 of 24] serialize oom killer
In-Reply-To: <alpine.DEB.0.9999.0709131139340.30279@chino.kir.corp.google.com>
Message-ID: <Pine.LNX.4.64.0709131152400.9999@schroedinger.engr.sgi.com>
References: <871b7a4fd566de081120.1187786931@v2.random>
 <Pine.LNX.4.64.0709121658450.4489@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709131126370.27997@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709131136560.9590@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709131139340.30279@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: pj@sgi.com, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 13 Sep 2007, David Rientjes wrote:

> > Ok then that needs to be changed. We need to do a cpuset_try_lock there?
> 
> It's easier to serialize it outside of out_of_memory() instead, since it 
> only has a single caller and we don't need to serialize for sysrq.
> 
> This seems like it would collapse down nicely to a global or per-cpuset 
> serialization with an added helper function implemented partially in 
> kernel/cpuset.c for the CONFIG_CPUSETS case.
> 
> Then, in __alloc_pages(), we test for either a global or per-cpuset 
> spin_trylock() and, if we acquire it, call out_of_memory() and goto 
> restart as we currently do.  If it's contended, we reschedule ourself and 
> goto restart when we awaken.

Could you rephrase that in patch form? ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
