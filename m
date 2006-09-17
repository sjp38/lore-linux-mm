Date: Sun, 17 Sep 2006 14:20:57 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
Message-Id: <20060917142057.e6413cbb.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.63.0609171329540.25459@chino.corp.google.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
	<20060914220011.2be9100a.akpm@osdl.org>
	<20060914234926.9b58fd77.pj@sgi.com>
	<20060915002325.bffe27d1.akpm@osdl.org>
	<20060915004402.88d462ff.pj@sgi.com>
	<20060915010622.0e3539d2.akpm@osdl.org>
	<Pine.LNX.4.63.0609151601230.9416@chino.corp.google.com>
	<Pine.LNX.4.63.0609161734220.16748@chino.corp.google.com>
	<20060917041707.28171868.pj@sgi.com>
	<Pine.LNX.4.64.0609170540020.14516@schroedinger.engr.sgi.com>
	<20060917060358.ac16babf.pj@sgi.com>
	<Pine.LNX.4.63.0609171329540.25459@chino.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: clameter@sgi.com, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David wrote:
> So __cpuset_zone_allowed is 5822/29.1100 = 200.000000000 which is 4.8% 
> faster.

Excellent - that sounds reasonable.  Thanks.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
