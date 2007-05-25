Date: Fri, 25 May 2007 08:25:15 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 0/8] Mapped File Policy Overview
In-Reply-To: <1180104952.5730.28.camel@localhost>
Message-ID: <Pine.LNX.4.64.0705250823260.5850@schroedinger.engr.sgi.com>
References: <20070524172821.13933.80093.sendpatchset@localhost>
 <200705242241.35373.ak@suse.de> <1180040744.5327.110.camel@localhost>
 <Pine.LNX.4.64.0705241417130.31587@schroedinger.engr.sgi.com>
 <1180104952.5730.28.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andi Kleen <ak@suse.de>, linux-mm@kvack.org, akpm@linux-foundation.org, nish.aravamudan@gmail.com
List-ID: <linux-mm.kvack.org>

On Fri, 25 May 2007, Lee Schermerhorn wrote:

> It's easy to fix.  The shared policy support is already there.  We just
> need to generalize it for regular files.  In the process,
> *page_cache_alloc() obeys "file policy", which will allow additional
> features such as you mentioned:  global page cache policy as the default
> "file policy".

A page cache policy would not need to be file based. It would be enough 
to have a global one or one per cpuset. And it would not suffer from the 
vanishing act of the inodes.

> By the way, I think we need the numa_maps fixes in any case because the
> current implementation lies about shmem segments if you look at any task
> that didn't install [all of] the policy on the segment, unless it
> happens to be a child of the task that did install the policy and that
> child was forked after the mbind() calls.  I really dislike all of those
> "ifs" and "unlesses"--I found it humorous in the George Carlin routine,
> but not in user/programming interface design.

Could you separate out a patch that fixes these issues?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
