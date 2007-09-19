Date: Wed, 19 Sep 2007 10:09:22 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [patch 6/4] oom: pass null to kfree if zonelist is not cleared
Message-Id: <20070919100922.16be90c0.pj@sgi.com>
In-Reply-To: <alpine.DEB.0.9999.0709181509420.2461@chino.kir.corp.google.com>
References: <871b7a4fd566de081120.1187786931@v2.random>
	<Pine.LNX.4.64.0709131923410.12159@schroedinger.engr.sgi.com>
	<alpine.DEB.0.9999.0709132010050.30494@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709180007420.4624@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709180245170.21326@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709180246350.21326@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709180246580.21326@chino.kir.corp.google.com>
	<Pine.LNX.4.64.0709181256260.3953@schroedinger.engr.sgi.com>
	<alpine.DEB.0.9999.0709181306140.22984@chino.kir.corp.google.com>
	<Pine.LNX.4.64.0709181314160.3953@schroedinger.engr.sgi.com>
	<alpine.DEB.0.9999.0709181340060.27785@chino.kir.corp.google.com>
	<Pine.LNX.4.64.0709181400440.4494@schroedinger.engr.sgi.com>
	<alpine.DEB.0.9999.0709181406490.31545@chino.kir.corp.google.com>
	<Pine.LNX.4.64.0709181423250.4494@schroedinger.engr.sgi.com>
	<alpine.DEB.0.9999.0709181509420.2461@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: clameter@sgi.com, akpm@linux-foundation.org, andrea@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David wrote:
> Why would it be constrained by the cpuset policy if there is no 
> __GFP_HARDWALL?

Er eh ... because it is ;)

With or without GFP_HARDWALL, allocations are constrained by cpuset
policy.

It's just a different policy (the nearest ancestor cpuset marked
mem_exclusive) without GFP_HARDWALL, rather than the current cpuset.

Cpuset constraints are ignored if in_interrupt, GFP_ATOMIC or
the thread flag TIF_MEMDIE is set.  Grep for "GFP_HARDWALL"
and read its comments (mostly in kernel/cpuset.c) and associated
code to see how these flags impact cpuset placement policy.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
