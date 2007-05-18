Date: Fri, 18 May 2007 10:11:33 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 0/5] make slab gfp fair
Message-Id: <20070518101133.800db8de.pj@sgi.com>
In-Reply-To: <1179482054.2925.52.camel@lappy>
References: <20070514131904.440041502@chello.nl>
	<Pine.LNX.4.64.0705161957440.13458@schroedinger.engr.sgi.com>
	<1179385718.27354.17.camel@twins>
	<Pine.LNX.4.64.0705171027390.17245@schroedinger.engr.sgi.com>
	<20070517175327.GX11115@waste.org>
	<Pine.LNX.4.64.0705171101360.18085@schroedinger.engr.sgi.com>
	<1179429499.2925.26.camel@lappy>
	<Pine.LNX.4.64.0705171220120.3043@schroedinger.engr.sgi.com>
	<1179437209.2925.29.camel@lappy>
	<Pine.LNX.4.64.0705171516260.4593@schroedinger.engr.sgi.com>
	<1179482054.2925.52.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: clameter@sgi.com, mpm@selenic.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tgraf@suug.ch, davem@davemloft.net, akpm@linux-foundation.org, phillips@google.com, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

Peter wrote:
> cpusets are ignored when in dire straights for an kernel alloc.

No - most kernel allocations never ignore cpusets.

The ones marked NOFAIL or ATOMIC can ignore cpusets in dire straights
and the ones off interrupts lack an applicable cpuset context.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
