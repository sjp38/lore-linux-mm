Date: Wed, 2 May 2007 11:58:05 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: 2.6.22 -mm merge plans: slub
In-Reply-To: <20070502185201.GA12097@linux-os.sc.intel.com>
Message-ID: <Pine.LNX.4.64.0705021156300.1220@schroedinger.engr.sgi.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705011846590.10660@blonde.wat.veritas.com>
 <20070501125559.9ab42896.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705012101410.26170@blonde.wat.veritas.com>
 <20070501133618.93793687.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705021346170.16517@blonde.wat.veritas.com>
 <20070502185201.GA12097@linux-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2 May 2007, Siddha, Suresh B wrote:

> I have been looking into "slub" recently to avoid some of the NUMA alien
> cache issues that we were encountering on the regular slab.

Yes that is also our main concern.

> I am having some stability issues with slub on an ia64 NUMA platform and
> didn't have time to dig further. I am hoping to look into it soon
> and share the data/findings with  Christoph.

There is at least one patch on top of 2.6.21-rc7-mm2 already in mm that 
may be necessary for you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
