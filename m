Date: Tue, 13 Nov 2007 21:41:00 +0100
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: x86_64: Make sparsemem/vmemmap the default memory model
Message-ID: <20071113204100.GB20167@lazybastard.org>
References: <Pine.LNX.4.64.0711121549370.29178@schroedinger.engr.sgi.com> <200711130059.34346.ak@suse.de> <Pine.LNX.4.64.0711121615120.29328@schroedinger.engr.sgi.com> <200711130149.54852.ak@suse.de> <Pine.LNX.4.64.0711121940410.30269@schroedinger.engr.sgi.com> <2c0942db0711122027m5b11502cveded5705c0bc4f64@mail.gmail.com> <Pine.LNX.4.64.0711122040380.30724@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <Pine.LNX.4.64.0711122040380.30724@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Ray Lee <ray-lk@madrabbit.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <ak@suse.de>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Mon, 12 November 2007 20:41:10 -0800, Christoph Lameter wrote:
> On Mon, 12 Nov 2007, Ray Lee wrote:
> 
> > Discontig obviously needs to die. However, FlatMem is consistently
> > faster, averaging about 2.1% better overall for your numbers above. Is
> > the page allocator not, erm, a fast path, where that matters?
> > 
> > Order	Flat	Sparse	% diff
> > 0	639	641	0.3
> 
> IMHO Order 0 currently matters most and the difference is negligible 
> there.

Is it?  I am a bit concerned about the non-monotonic distribution.
Difference starts a near-0, grows to 4.4, drops to near-0, grows to 4.9,
drops to near-0.

Order   Flat    Sparse  % diff
0       639     641     0.3
1       567     593     4.4
2       679     692     1.9
3       763     781     2.3
4       961     962     0.1
5       1356    1392    2.6
6       2224    2336    4.8
7       4869    5074    4.0
8       12500   12732   1.8
9       27926   28165   0.8
10      58578   58682   0.2

Is there an explanation for this behaviour?  More to the point, could
repeated runs also return 4% difference for order-0?

JA?rn

-- 
It does not require a majority to prevail, but rather an irate,
tireless minority keen to set brush fires in people's minds.
-- Samuel Adams

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
