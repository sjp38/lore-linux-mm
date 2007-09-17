Date: Mon, 17 Sep 2007 21:56:15 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH] Configurable reclaim batch size
Message-ID: <20070917215615.685a5378@lappy>
In-Reply-To: <Pine.LNX.4.64.0709171053040.26860@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0709141519230.14894@schroedinger.engr.sgi.com>
	<1189812002.5826.31.camel@lappy>
	<Pine.LNX.4.64.0709171053040.26860@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

On Mon, 17 Sep 2007 10:54:59 -0700 (PDT) Christoph Lameter
<clameter@sgi.com> wrote:

> On Sat, 15 Sep 2007, Peter Zijlstra wrote:
> 
> > It increases the lock hold times though. Otoh it might work out with the
> > lock placement.
> 
> Yeah may be good for NUMA.

Might, I'd just like a _little_ justification for an extra tunable.

> > Do you have any numbers that show this is worthwhile?
> 
> Tried to run AIM7 but the improvements are in the noise. I need a tests 
> that really does large memory allocation and stresses the LRU. I could 
> code something up but then Lee's patch addresses some of the same issues.
> Is there any standard test that shows LRU handling regressions?

hehe, I wish. I was just hoping you'd done this patch as a result of an
actual problem and not a hunch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
