Date: Sun, 17 Sep 2006 06:03:58 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
Message-Id: <20060917060358.ac16babf.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.64.0609170540020.14516@schroedinger.engr.sgi.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: rientjes@google.com, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph wrote:
> Are you sure that you are looking at a current tree? This is zone_to_nid 
> here.

You're two steps ahead of me.  Yes, it's zone_to_nid() in the
current tree.

So ... any idea why your patch made only 0.000042%
difference in the cost per call of __cpuset_zone_allowed()?

That is bizarrely close to zero.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
