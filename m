Date: Wed, 17 Nov 2004 04:08:52 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] fix spurious OOM kills
Message-ID: <20041117060852.GB19107@logos.cnet>
References: <4193E056.6070100@tebibyte.org> <4194EA45.90800@tebibyte.org> <20041113233740.GA4121@x30.random> <20041114094417.GC29267@logos.cnet> <20041114170339.GB13733@dualathlon.random> <20041114202155.GB2764@logos.cnet> <419A2B3A.80702@tebibyte.org> <419B14F9.7080204@tebibyte.org> <20041117012346.5bfdf7bc.akpm@osdl.org> <20041117060648.GA19107@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041117060648.GA19107@logos.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Chris Ross <chris@tebibyte.org>, andrea@novell.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, piggin@cyberone.com.au, riel@redhat.com, mmokrejs@ribosome.natur.cuni.cz, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

On Wed, Nov 17, 2004 at 04:06:48AM -0200, Marcelo Tosatti wrote:
> On Wed, Nov 17, 2004 at 01:23:46AM -0800, Andrew Morton wrote:
> > Chris Ross <chris@tebibyte.org> wrote:
> > >
> > > As I suspected, like a recalcitrant teenager it was sneakily waiting 
> > >  until everyone was out then it threw a wild party with several ooms and 
> > >  an oops. See below...
> > 
> > That's not an oops - it's just a stack trace.
> > 
> > >  This, obviously is still without Kame's patch, just the same tree as 
> > >  before with the one change you asked for.
> > 
> > Please ignore the previous patch and try the below.  It looks like Rik's
> > analysis is correct: when the caller doesn't have the swap token it just
> > cannot reclaim referenced pages and scans its way into an oom.  Defeating
> > that logic when we've hit the highest scanning priority does seem to fix
> > the problem and those nice qsbench numbers which the thrashing control gave
> > us appear to be unaffected.
> 
> Oh, this fixes my testcase, and was the reason for the hog slow speed.
> 
> Excellent, wasted several days in vain. :(

Before the swap token patches went in you remember spurious OOM reports  
or things were working fine then?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
