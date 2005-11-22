Date: Tue, 22 Nov 2005 08:54:35 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] properly account readahead file major faults
Message-ID: <20051122105435.GA31300@logos.cnet>
References: <20051121140038.GA27349@logos.cnet> <20051122042443.GA4588@mail.ustc.edu.cn> <20051122062321.GA30413@logos.cnet> <Pine.LNX.4.61.0511221249470.24803@goblin.wat.veritas.com> <20051122080856.GA30761@logos.cnet> <5ad478c0511220805i2fa37ebdi88f64125a549fa9c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5ad478c0511220805i2fa37ebdi88f64125a549fa9c@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Charles Ballowe <cballowe@gmail.com>
Cc: Hugh Dickins <hugh@veritas.com>, Wu Fengguang <wfg@mail.ustc.edu.cn>, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 22, 2005 at 10:05:00AM -0600, Charles Ballowe wrote:
> On 11/22/05, Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
> > Hi Hugh!
> >
> > On Tue, Nov 22, 2005 at 12:55:02PM +0000, Hugh Dickins wrote:
> > > On Tue, 22 Nov 2005, Marcelo Tosatti wrote:
> > > >
> > > > Pages which hit the first time in cache due to readahead _have_ caused
> > > > IO, and as such they should be counted as major faults.
> > >
> > > Have caused IO, or have benefitted from IO which was done earlier?
> >
> > Which caused IO, either synchronously or via (previously read)
> > readahead.
> >
> > > It sounds debatable, each will have their own idea of what's major.
> >
> > I see your point... and I much prefer the "majflt means IO performed"
> > definition :)
> >
> > As a user I want to know how many pages have been read in from disk to
> > service my application requests.
> 
> This is a dangerous line of thought. While the number of pages read in
> does have some meaning, in many cases, fetching one page vs. 1MB worth
> of pages takes about the same time to service. If the page read-ahead
> manages to do larger multi-block reads, then there is only 1 I/O for
> the fault, regardless of the number of pages that are read in by that
> operation.
> 
> > From the "time" manpage:
> >
> > F      Number of major, or I/O-requiring, page faults  that  oc-
> >        curred  while  the process was running.  These are faults
> >        where the page has actually migrated out of primary memo-
> >        ry.
> >
> > > Maybe PageUptodate at the time the entry is found in the page cache
> > > should come into it?  !PageUptodate implying that we'll be waiting
> > > for read to complete.
> >
> > Hum, I still strongly feel that users care about IO performed and not
> > readahead effectiveness (which could be separate information).
> 
> >From a user perspective, I'm far more interested in number of I/O
> operations performed rather than pages read. The first has a far
> larger effect on time spent waiting than the second.

Ok, makes sense, let it be the way it is then.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
