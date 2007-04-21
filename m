Date: Fri, 20 Apr 2007 23:11:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: slab allocators: Remove multiple alignment specifications.
Message-Id: <20070420231129.9252ca67.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0704202243480.25004@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0704202210060.17036@schroedinger.engr.sgi.com>
	<20070420223727.7b201984.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0704202243480.25004@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Fri, 20 Apr 2007 22:44:39 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> On Fri, 20 Apr 2007, Andrew Morton wrote:
> 
> > You're patching code which your earlier patches deleted.
> 
> Sorry. Trees overloaded with series of patches. Any change to get 
> a new tree?

rofl.

I'm still recovering from that dang Itanium conference.  Since rc6-mm1 I
have added 684 patches and removed 164.  It's simply idiotic.

http://userweb.kernel.org/~akpm/cl.bz2 is the current rollup against rc7. 
I haven't tried compiling it for nearly a week.  Good luck ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
