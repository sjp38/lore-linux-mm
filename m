Date: Sun, 17 Sep 2006 04:15:25 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
Message-Id: <20060917041525.4ddbd6fa.pj@sgi.com>
In-Reply-To: <450D1A94.7020100@yahoo.com.au>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: akpm@osdl.org, clameter@sgi.com, linux-mm@kvack.org, rientjes@google.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

Nick wrote:
> Too complex? ;)

I quite agree it looks more complex than we wanted.


> Why not just start with caching the first allowed
> zone and see how far that gets you?

I thought I had explained clearly why that doesn't work.

I'll try again.

I am presuming here that by 'first allowed zone' you are
referring by yet another phrase to what Andrew has called
'most-recently-allocated-from zone', and what I described with:

  cur   -- the current zone we're getting memory from

If that presumption is wrong, then my reply following is bogus,
and you'll have to explain what you meant.

I can't just cache this zone, because I at least have to also cache
something else, such as the zonelist I found that zone within, so
I know not to use that cached zone if I am later passed a different
zonelist.

So I need to cache at least two zone pointers, the base zonelist and
the first allowed zone.

Then I do need to do something to avoid using that cached zone
long after some closer zone gets some free memory again.  Caching a
revolving retry zone pointer is one way to do that.  Perhaps there
are simpler ways ... I'm open to suggestions.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
