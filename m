Date: Mon, 6 Aug 2007 16:14:59 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 02/10] mm: system wide ALLOC_NO_WATERMARK
In-Reply-To: <200708061559.41680.phillips@phunq.net>
Message-ID: <Pine.LNX.4.64.0708061605400.5090@schroedinger.engr.sgi.com>
References: <20070806102922.907530000@chello.nl> <1186431992.7182.33.camel@twins>
 <Pine.LNX.4.64.0708061404300.3116@schroedinger.engr.sgi.com>
 <200708061559.41680.phillips@phunq.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@phunq.net>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 6 Aug 2007, Daniel Phillips wrote:

> Correct.  That is what the throttling part of these patches is about.  

Where are those patches?

> In order to fix the vm writeout deadlock problem properly, two things 
> are necessary:
> 
>   1) Throttle the vm writeout path to use a bounded amount of memory
> 
>   2) Provide access to a sufficiently large amount of reserve memory for 
> each memory user in the vm writeout path
> 
> You can understand every detail of this patch set and the following ones 
> coming from Peter in terms of those two requirements.

AFAICT: This patchset is not throttling processes but failing allocations. 
The patchset does not reconfigure the memory reserves as expected. Instead 
new reserve logic is added. And I suspect that we have the same issues as 
in earlier releases with various corner cases not being covered. Code is 
added that is supposedly not used. If it ever is on a large config then we 
are in very deep trouble by the new code paths themselves that serialize 
things in order to give some allocations precendence over the other 
allocations that are made to fail ....





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
