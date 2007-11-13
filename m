Date: Tue, 13 Nov 2007 23:30:53 +0100
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: x86_64: Make sparsemem/vmemmap the default memory model
Message-ID: <20071113223052.GE20167@lazybastard.org>
References: <Pine.LNX.4.64.0711121549370.29178@schroedinger.engr.sgi.com> <200711130059.34346.ak@suse.de> <Pine.LNX.4.64.0711121615120.29328@schroedinger.engr.sgi.com> <200711130149.54852.ak@suse.de> <Pine.LNX.4.64.0711121940410.30269@schroedinger.engr.sgi.com> <2c0942db0711122027m5b11502cveded5705c0bc4f64@mail.gmail.com> <Pine.LNX.4.64.0711122040380.30724@schroedinger.engr.sgi.com> <20071113204100.GB20167@lazybastard.org> <Pine.LNX.4.64.0711131349300.3714@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <Pine.LNX.4.64.0711131349300.3714@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>, Ray Lee <ray-lk@madrabbit.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <ak@suse.de>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Tue, 13 November 2007 13:52:17 -0800, Christoph Lameter wrote:
> 
> Could you run your own test to verify?

You bastard!  You know I'm too lazy to do that. ;)

As long as the order-0 number is stable across multiple runs I don't
mind.  The numbers just looked suspiciously as if they were not stable.
That's all.

JA?rn

-- 
Why do musicians compose symphonies and poets write poems?
They do it because life wouldn't have any meaning for them if they didn't.
That's why I draw cartoons.  It's my life.
-- Charles Shultz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
