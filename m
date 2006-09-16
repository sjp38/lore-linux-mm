Date: Fri, 15 Sep 2006 17:04:55 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
Message-Id: <20060915170455.f8b98784.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.63.0609151601230.9416@chino.corp.google.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
	<20060914220011.2be9100a.akpm@osdl.org>
	<20060914234926.9b58fd77.pj@sgi.com>
	<20060915002325.bffe27d1.akpm@osdl.org>
	<20060915004402.88d462ff.pj@sgi.com>
	<20060915010622.0e3539d2.akpm@osdl.org>
	<Pine.LNX.4.63.0609151601230.9416@chino.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@osdl.org, clameter@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Thanks for doing this, David.

> I used numa=fake=64 for 64 nodes of 48M each (with my numa=fake fix).  I 
> created a 2G cpuset with 43 nodes (43*48M = ~2G) and attached 'usemem -m 
> 1500 -s 10000000 &' to it for 1.5G of anonymous memory.  I then used 
> readprofile to time and profile a kernel build of 2.6.18-rc5 with x86_64 
> defconfig in the remaining 21 nodes.

I got confused here.  Was the kernel build running in the
2G cpuset (which only had 0.5G remaining free), or was it
running on the remaining 21 nodes, outside the 2G cpuset?

Separate question - would it be easy to run this again, with
a little patch from me that open coded cpuset_zone_allowed()
in get_page_from_freelist()?  The patch I have in mind would
not be acceptable for the real kernel, but it would give us
an idea of whether just a local code change might be sufficient
here.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
