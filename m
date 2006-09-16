Date: Fri, 15 Sep 2006 20:45:48 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
Message-Id: <20060915204548.0604e414.pj@sgi.com>
In-Reply-To: <20060915183604.11a8d045.akpm@osdl.org>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
	<20060914220011.2be9100a.akpm@osdl.org>
	<20060914234926.9b58fd77.pj@sgi.com>
	<20060915002325.bffe27d1.akpm@osdl.org>
	<20060915004402.88d462ff.pj@sgi.com>
	<20060915010622.0e3539d2.akpm@osdl.org>
	<Pine.LNX.4.63.0609151601230.9416@chino.corp.google.com>
	<20060915170455.f8b98784.pj@sgi.com>
	<20060915183604.11a8d045.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: rientjes@google.com, clameter@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew, replying to pj:
> > Separate question - would it be easy to run this again, with
> > a little patch from me that open coded cpuset_zone_allowed()
> > in get_page_from_freelist()?
>
> I guess it would,

Ah - I was asking (in my mind) David, not Andrew, if this test
could be rerun.

> but that'll be a next-week thing.

Good idea.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
