Date: Thu, 10 May 2007 16:01:39 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [Bug 8464] New: autoreconf: page allocation failure. order:2,
 mode:0x84020
In-Reply-To: <20070510230044.GB15332@skynet.ie>
Message-ID: <Pine.LNX.4.64.0705101601220.14471@schroedinger.engr.sgi.com>
References: <200705102128.l4ALSI2A017437@fire-2.osdl.org>
 <20070510144319.48d2841a.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705101447120.12874@schroedinger.engr.sgi.com>
 <20070510220657.GA14694@skynet.ie> <Pine.LNX.4.64.0705101510500.13404@schroedinger.engr.sgi.com>
 <20070510221607.GA15084@skynet.ie> <Pine.LNX.4.64.0705101522250.13504@schroedinger.engr.sgi.com>
 <20070510224441.GA15332@skynet.ie> <Pine.LNX.4.64.0705101547020.14064@schroedinger.engr.sgi.com>
 <20070510230044.GB15332@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.skynet.ie>
Cc: Nicolas.Mailhot@LaPoste.net, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "bugme-daemon@kernel-bugs.osdl.org" <bugme-daemon@bugzilla.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 11 May 2007, Mel Gorman wrote:

> Nicholas, could you backout the patch
> dont-group-high-order-atomic-allocations.patch and test again please?
> The following patch has the same effect. Thanks

Great! Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
