Date: Mon, 17 Sep 2007 13:05:43 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Configurable reclaim batch size
In-Reply-To: <20070917215615.685a5378@lappy>
Message-ID: <Pine.LNX.4.64.0709171304310.28864@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0709141519230.14894@schroedinger.engr.sgi.com>
 <1189812002.5826.31.camel@lappy> <Pine.LNX.4.64.0709171053040.26860@schroedinger.engr.sgi.com>
 <20070917215615.685a5378@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

On Mon, 17 Sep 2007, Peter Zijlstra wrote:

> > Tried to run AIM7 but the improvements are in the noise. I need a tests 
> > that really does large memory allocation and stresses the LRU. I could 
> > code something up but then Lee's patch addresses some of the same issues.
> > Is there any standard test that shows LRU handling regressions?
> 
> hehe, I wish. I was just hoping you'd done this patch as a result of an
> actual problem and not a hunch.

It was Andrew's hunch. I'd rather see Lee's approach go forward because 
I think it has the potential of solving the issue in a more general way. 
If I get some spare time with a problem system then I will test the patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
