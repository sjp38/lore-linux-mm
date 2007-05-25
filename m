From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH/RFC 0/8] Mapped File Policy Overview
Date: Fri, 25 May 2007 23:03:16 +0200
References: <20070524172821.13933.80093.sendpatchset@localhost> <1180104952.5730.28.camel@localhost> <Pine.LNX.4.64.0705250823260.5850@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0705250823260.5850@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200705252303.16752.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, akpm@linux-foundation.org, nish.aravamudan@gmail.com
List-ID: <linux-mm.kvack.org>

On Friday 25 May 2007 17:25:15 Christoph Lameter wrote:
> On Fri, 25 May 2007, Lee Schermerhorn wrote:
> 
> > It's easy to fix.  The shared policy support is already there.  We just
> > need to generalize it for regular files.  In the process,
> > *page_cache_alloc() obeys "file policy", which will allow additional
> > features such as you mentioned:  global page cache policy as the default
> > "file policy".
> 
> A page cache policy would not need to be file based. It would be enough 
> to have a global one or one per cpuset. And it would not suffer from the 
> vanishing act of the inodes.

I agree. A general page cache policy is probably a good idea and having
it in a cpuset is reasonable too. I've been also toying with the idea to 
change the global default to interleaved for unmapped files.

But in this case it's actually not needed to add something to the
address space. It can be all process policy based.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
