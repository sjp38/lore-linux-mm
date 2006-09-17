Date: Sun, 17 Sep 2006 05:09:44 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
Message-Id: <20060917050944.3fba690e.pj@sgi.com>
In-Reply-To: <20060916215545.32fba5c7.akpm@osdl.org>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
	<20060914220011.2be9100a.akpm@osdl.org>
	<20060914234926.9b58fd77.pj@sgi.com>
	<20060915002325.bffe27d1.akpm@osdl.org>
	<20060916044847.99802d21.pj@sgi.com>
	<20060916083825.ba88eee8.akpm@osdl.org>
	<20060916145117.9b44786d.pj@sgi.com>
	<20060916161031.4b7c2470.akpm@osdl.org>
	<Pine.LNX.4.64.0609162134540.13809@schroedinger.engr.sgi.com>
	<20060916215545.32fba5c7.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: clameter@sgi.com, linux-mm@kvack.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

Andrew wrote:
> Apart from the fact that
> get_page_from_freelist() sucks.  And speeding that up will speed up other
> workloads.

With the exception of this fake NUMA trick, I still haven't seen any
evidence that there is a performance issue here.  Sure, there is the
potential for painful linear searches here, but in actual use, that's
not what happens.

A linear search is not linear in performance if the search is heavily
biased toward succeeding on the first few probes.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
