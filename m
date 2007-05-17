Date: Thu, 17 May 2007 10:59:30 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/5] make slab gfp fair
In-Reply-To: <1179424335.2925.5.camel@lappy>
Message-ID: <Pine.LNX.4.64.0705171057110.18085@schroedinger.engr.sgi.com>
References: <20070514131904.440041502@chello.nl>
 <Pine.LNX.4.64.0705161957440.13458@schroedinger.engr.sgi.com>
 <1179385718.27354.17.camel@twins>  <Pine.LNX.4.64.0705171027390.17245@schroedinger.engr.sgi.com>
 <1179424335.2925.5.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Thu, 17 May 2007, Peter Zijlstra wrote:

> > I am weirdly confused by these patches. Among other things you told me 
> > that the performance does not matter since its never (or rarely) being 
> > used (why do it then?).
> 
> When we are very low on memory and do access the reserves by means of
> ALLOC_NO_WATERMARKS, we want to avoid processed that are not entitled to
> use such memory from running away with the little we have.

For me low memory conditions are node or zone specific and may be 
particular to certain allocation constraints. For some reason you have 
this simplified global picture in mind.

The other statement is weird. It is bad to fail allocation attempts, they 
may lead to a process being terminated. Memory should be reclaimed 
earlier to avoid these situations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
