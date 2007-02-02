Date: Thu, 1 Feb 2007 23:12:57 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC 0/8] Cpuset aware writeback
Message-Id: <20070201231257.abdafbae.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0702012044090.10575@schroedinger.engr.sgi.com>
References: <20070116054743.15358.77287.sendpatchset@schroedinger.engr.sgi.com>
	<45C2960B.9070907@google.com>
	<Pine.LNX.4.64.0702011815240.9799@schroedinger.engr.sgi.com>
	<20070201200358.89dd2991.akpm@osdl.org>
	<Pine.LNX.4.64.0702012044090.10575@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Ethan Solomita <solo@google.com>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Paul Jackson <pj@sgi.com>, Dave Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

On Thu, 1 Feb 2007 21:29:06 -0800 (PST) Christoph Lameter <clameter@sgi.com> wrote:

> On Thu, 1 Feb 2007, Andrew Morton wrote:
> 
> > > Peter Zilkstra addressed the NFS issue.
> > 
> > Did he?  Are you yet in a position to confirm that?
> 
> He provided a solution to fix the congestion issue in NFS. I thought 
> that is what you were looking for? That should make NFS behave more
> like a block device right?

We hope so.

The cpuset-aware-writeback patches were explicitly written to hide the bug which
Peter's patches hopefully address.  They hence remove our best way of confirming
that Peter's patches fix the problem which you've observed in a proper fashion.

Until we've confirmed that the NFS problem is nailed, I wouldn't want to merge
cpuset-aware-writeback.  I'm hoping to be able to do that with fake-numa on x86-64
but haven't got onto it yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
