Date: Mon, 17 Sep 2007 10:54:59 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Configurable reclaim batch size
In-Reply-To: <1189812002.5826.31.camel@lappy>
Message-ID: <Pine.LNX.4.64.0709171053040.26860@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0709141519230.14894@schroedinger.engr.sgi.com>
 <1189812002.5826.31.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 15 Sep 2007, Peter Zijlstra wrote:

> It increases the lock hold times though. Otoh it might work out with the
> lock placement.

Yeah may be good for NUMA.
 
> Do you have any numbers that show this is worthwhile?

Tried to run AIM7 but the improvements are in the noise. I need a tests 
that really does large memory allocation and stresses the LRU. I could 
code something up but then Lee's patch addresses some of the same issues.
Is there any standard test that shows LRU handling regressions?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
