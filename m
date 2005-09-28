Date: Wed, 28 Sep 2005 09:30:17 +0300
Subject: Re: 2.6.14-rc2 early boot OOPS (mm/slab.c:1767)
Message-ID: <20050928063017.GI1046@vega.lnet.lut.fi>
References: <20050927202858.GG1046@vega.lnet.lut.fi> <Pine.LNX.4.62.0509271630050.11040@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0509271630050.11040@schroedinger.engr.sgi.com>
From: lapinlam@vega.lnet.lut.fi (Tomi Lapinlampi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, alokk@calsoftinc.com
List-ID: <linux-mm.kvack.org>

On Tue, Sep 27, 2005 at 04:35:54PM -0700, Christoph Lameter wrote:
> On Tue, 27 Sep 2005, Tomi Lapinlampi wrote:
> 
> > I'm getting the following OOPS with 2.6.14-rc2 on an Alpha.
> 
> Hmmm. I am not familiar with Alpha. The .config looks as if this is a 
> uniprocessor configuration? No NUMA? 

This is a simple uniprocessor configuration, no NUMA, no SMP. 

> What is the value of MAX_NUMNODES?

I'm not familiar with NUMA, where can I check this (or does this question
even apply since it's not a NUMA system) ?

Plase keep me cc:'d,

Tomi

-- 
You can decide: live with free software or with only one evil company left?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
