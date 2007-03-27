Date: Mon, 26 Mar 2007 18:45:08 -0700 (PDT)
Message-Id: <20070326.184508.85687849.davem@davemloft.net>
Subject: Re: [QUICKLIST 1/5] Quicklists for page table pages V4
From: David Miller <davem@davemloft.net>
In-Reply-To: <20070327010624.GA2986@holomorphy.com>
References: <Pine.LNX.4.64.0703260938520.3297@schroedinger.engr.sgi.com>
	<20070326102651.6d59207b.akpm@linux-foundation.org>
	<20070327010624.GA2986@holomorphy.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: William Lee Irwin III <wli@holomorphy.com>
Date: Mon, 26 Mar 2007 18:06:24 -0700
Return-Path: <owner-linux-mm@kvack.org>
To: wli@holomorphy.com
Cc: akpm@linux-foundation.org, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> On Mon, Mar 26, 2007 at 10:26:51AM -0800, Andrew Morton wrote:
> > b) we understand why the below simple modification crashes i386.
> 
> Full eager zeroing patches not dependent on quicklist code don't crash,
> so there is no latent use-after-free issue covered up by caching. I'll
> help out more on the i386 front as-needed.

I've looked into this a few times and I am quite mystified as
to why that simple test patch crashes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
