Message-ID: <467F6388.7080101@yahoo.com.au>
Date: Mon, 25 Jun 2007 16:41:12 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 10/26] SLUB: Faster more efficient slab determination
 for __kmalloc.
References: <20070618095838.238615343@sgi.com>	<20070618095915.826976488@sgi.com>	<20070619130858.693ae66e.akpm@linux-foundation.org>	<Pine.LNX.4.64.0706191522230.7633@schroedinger.engr.sgi.com>	<20070619152957.a03fbb2c.akpm@linux-foundation.org>	<Pine.LNX.4.64.0706191533580.7633@schroedinger.engr.sgi.com> <20070619154654.218f902c.akpm@linux-foundation.org>
In-Reply-To: <20070619154654.218f902c.akpm@linux-foundation.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Tue, 19 Jun 2007 15:38:01 -0700 (PDT)
> Christoph Lameter <clameter@sgi.com> wrote:
> 
> 
>>Ok and BUILD_BUG_ON really works? Had some bad experiences with it.
> 
> 
> hm, I don't recall any problems, apart from its very obscure error
> reporting.
> 
> But if it breaks, we get an opportunity to fix it ;)

It doesn't work outside function scope, which can be annoying. The
workaround is to just create a dummy function and put the BUILD_BUG_ON
inside that.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
