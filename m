Date: Thu, 3 Feb 2005 22:50:28 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: A scrub daemon (prezeroing)
In-Reply-To: <1107499403.5461.32.camel@npiggin-nld.site>
Message-ID: <Pine.LNX.4.58.0502032245590.28974@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0501211228430.26068@schroedinger.engr.sgi.com>
 <1106828124.19262.45.camel@hades.cambridge.redhat.com>  <20050202153256.GA19615@logos.cnet>
  <Pine.LNX.4.58.0502021103410.12695@schroedinger.engr.sgi.com>
 <20050202163110.GB23132@logos.cnet>  <Pine.LNX.4.61.0502022204140.2678@chimarrao.boston.redhat.com>
  <16898.46622.108835.631425@cargo.ozlabs.ibm.com>
 <Pine.LNX.4.58.0502031650590.26551@schroedinger.engr.sgi.com>
 <16899.2175.599702.827882@cargo.ozlabs.ibm.com>
 <Pine.LNX.4.58.0502032220430.28851@schroedinger.engr.sgi.com>
 <1107499403.5461.32.camel@npiggin-nld.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Paul Mackerras <paulus@samba.org>, Rik van Riel <riel@redhat.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, David Woodhouse <dwmw2@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Fri, 4 Feb 2005, Nick Piggin wrote:

> If you have got to the stage of doing "real world" tests, I'd be
> interested to see results of tests that best highlight the improvements.

I am trying to figure out which tests to use right now.

> I imagine many general purpose server things wouldn't be helped much,
> because they'll typically have little free memory, and will be
> continually working and turning things over.

These things are helped because zapping memory is very fast. Continual
turning things over results in zapping of large memory areas once in
awhile which even speeds up (a sparsely accessing) benchmark. Read my
earlier posts on the subject.

There is of course an issue if the system is continuously low on memory.
In that case the buddy allocator may not generate large enough orders of
free pages to make it worth to zap them.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
