Date: Wed, 8 Nov 2006 02:21:41 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [TAKE] memory page_alloc zonelist caching speedup
Message-Id: <20061108022141.447abc92.pj@sgi.com>
In-Reply-To: <20061010081429.15156.77206.sendpatchset@jackhammer.engr.sgi.com>
References: <20061010081429.15156.77206.sendpatchset@jackhammer.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: linux-mm@kvack.org, akpm@osdl.org, nickpiggin@yahoo.com.au, rientjes@google.com, ak@suse.de, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

As discussed in a separate lkml thread:

  Avoid allocating during interleave from almost full nodes

the suggestion was made by Andrew and Christoph to consider replacing
the wall clock based zapping of this zonelist cache with something
based on the rate of vm paging activity, such as perhaps the counters.
PGALLOC_* and PGSCAN_* (see further vmstat.h).

But it will be a few weeks before I can get to doing this; I've got
to do some other stuff first.

I'm assuming that, as a practical matter, for the short term, either
"time base" works, so that this is not an urgent change.

Of course, if any lurkers want to jump in and do this sooner, have
at it.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
