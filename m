Date: Wed, 2 Jan 2008 12:55:18 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 05/10] x86_64: Use generic percpu
In-Reply-To: <200712281354.52453.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0801021254250.22538@schroedinger.engr.sgi.com>
References: <20071228001046.854702000@sgi.com> <20071228001047.556634000@sgi.com>
 <200712281354.52453.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: travis@sgi.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, tglx@linutronix.de, mingo@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, 28 Dec 2007, Andi Kleen wrote:

> On Friday 28 December 2007 01:10:51 travis@sgi.com wrote:
> > x86_64 provides an optimized way to determine the local per cpu area
> > offset through the pda and determines the base by accessing a remote
> > pda.
> 
> And? The rationale for this patch seems to be incomplete.
> 
> As far as I can figure out you're replacing an optimized percpu 
> implementation which a dumber generic one. Which needs
> at least some description why.

The implementation stays the same. The code is just consolidated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
