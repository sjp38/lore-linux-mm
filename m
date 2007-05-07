Date: Mon, 7 May 2007 13:32:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Support concurrent local and remote frees and allocs on a slab.
Message-Id: <20070507133232.d5701090.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0705071156570.6080@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0705042025520.29006@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0705052152060.29770@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0705052243490.29846@schroedinger.engr.sgi.com>
	<20070506122447.0d5b83e1.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0705071137290.5793@schroedinger.engr.sgi.com>
	<20070507115438.a271580a.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0705071156570.6080@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 7 May 2007 11:58:34 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> > > What is the problem with 21-mm1 btw? slab performance for both allocators 
> > > dropped from ~6M/sec to ~4.5M/sec
> > 
> > That's news to me.  You're the slab guy ;)
> > 
> > Are you sure the slowdown is due to slab, or did networking break?
> 
> Both slab allocators are affected. I poked around but nothing sprang to 
> my mind. Seems its networking.

Please, send a report to netdev@vger.kernel.org.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
