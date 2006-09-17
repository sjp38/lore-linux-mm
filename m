Date: Sun, 17 Sep 2006 14:19:18 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
Message-Id: <20060917141918.1066e8fb.pj@sgi.com>
In-Reply-To: <450D5310.50004@yahoo.com.au>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
	<20060914220011.2be9100a.akpm@osdl.org>
	<20060914234926.9b58fd77.pj@sgi.com>
	<20060915002325.bffe27d1.akpm@osdl.org>
	<20060915012810.81d9b0e3.akpm@osdl.org>
	<20060915203816.fd260a0b.pj@sgi.com>
	<20060915214822.1c15c2cb.akpm@osdl.org>
	<20060916043036.72d47c90.pj@sgi.com>
	<20060916081846.e77c0f89.akpm@osdl.org>
	<20060917022834.9d56468a.pj@sgi.com>
	<450D1A94.7020100@yahoo.com.au>
	<20060917041525.4ddbd6fa.pj@sgi.com>
	<450D434B.4080702@yahoo.com.au>
	<20060917061922.45695dcb.pj@sgi.com>
	<450D5310.50004@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: akpm@osdl.org, clameter@sgi.com, linux-mm@kvack.org, rientjes@google.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

Nick wrote:
> So that's the part where you wanted to see if a zone has any free
> memory pages. What you are doing is not actually seeing if a zone
> has _any_ free memory pages, but testing whether a given allocation
> type is within its corresponding watermarks.

Ah - now your point makes sense.  Yes, I should not have been looking
for _any_ free memory, but rather for memory satisfying the watermark
and other conditions of the current request.


And the question of whether the cached 'base' and 'cur' pointers should
be invalidated everytime a request has differing watermarks ... well I
can think of several answers to that question ... all sucky.

However ... Andrew has prodded me into some more simplification, which
will toss this 'retry' pointer in the ash heap of history.  See my
upcoming reply to his latest post.

I trust you will not mind that this 'retry' pointer gets thrown out ;).

Nick wrote:
> What we could do then, is allocate pages in batches (we already do),
> but only check watermarks if we have to go to the buddly allocator
> (we don't currently do this, but really should anyway, considering
> that the watermark checks are based on pages in the buddy allocator
> rather than pages in buddy + pcp).

I'll have to leave this matter to you.  It's not something I understand
well enough to be useful.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
