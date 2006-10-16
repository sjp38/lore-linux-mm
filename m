Date: Mon, 16 Oct 2006 09:58:05 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [TAKE] memory page_alloc zonelist caching speedup
Message-Id: <20061016095805.f7576230.pj@sgi.com>
In-Reply-To: <20061016112535.GA13218@lnx-holt.americas.sgi.com>
References: <20061010081429.15156.77206.sendpatchset@jackhammer.engr.sgi.com>
	<200610161134.07168.ak@suse.de>
	<20061016032632.486f4235.pj@sgi.com>
	<20061016112535.GA13218@lnx-holt.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: ak@suse.de, linux-mm@kvack.org, akpm@osdl.org, nickpiggin@yahoo.com.au, rientjes@google.com, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Robin wrote:
> Paul,  I think Andi is concerned that we will have a heavily shared
> cache line which now becomes frequently invalidated.

Once a second invalidation of a few cache lines that are
only accessed from one node beats once per memory allocation
cross-node accesses of cache lines invalidated every free.

Big time.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
