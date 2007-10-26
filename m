Date: Fri, 26 Oct 2007 10:55:59 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
In-Reply-To: <20071026174409.GA1573@elf.ucw.cz>
Message-ID: <Pine.LNX.4.64.0710261052530.15895@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0709101220001.24735@schroedinger.engr.sgi.com>
 <1189454145.21778.48.camel@twins> <Pine.LNX.4.64.0709101318160.25407@schroedinger.engr.sgi.com>
 <1189457286.21778.68.camel@twins> <20071026174409.GA1573@elf.ucw.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Daniel Phillips <phillips@phunq.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, 26 Oct 2007, Pavel Machek wrote:

> > And, _no_, it does not necessarily mean global serialisation. By simply
> > saying there must be N pages available I say nothing about on which node
> > they should be available, and the way the watermarks work they will be
> > evenly distributed over the appropriate zones.
> 
> Agreed. Scalability of emergency swapping reserved is simply
> unimportant. Please, lets get swapping to _work_ first, then we can
> make it faster.

Global reserve means that any cpuset that runs out of memory may exhaust 
the global reserve and thereby impact the rest of the system. The 
emergencies that are currently localized to a subset of the system and 
may lead to the failure of a job may now become global and lead to the 
failure of all jobs running on it.

But Peter mentioned that he has some way of tracking the amount of memory 
used in a certain context (beancounter?) which would address the issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
