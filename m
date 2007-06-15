Date: Sat, 16 Jun 2007 02:03:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] memory unplug v5 [5/6] page unplug
Message-Id: <20070616020348.b4f2aab5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1181922762.28189.30.camel@spirit>
References: <20070614155630.04f8170c.kamezawa.hiroyu@jp.fujitsu.com>
	<20070614160458.62e20cbd.kamezawa.hiroyu@jp.fujitsu.com>
	<1181922762.28189.30.camel@spirit>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <hansendc@us.ibm.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, clameter@sgi.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Fri, 15 Jun 2007 08:52:41 -0700
Dave Hansen <hansendc@us.ibm.com> wrote:

> On Thu, 2007-06-14 at 16:04 +0900, KAMEZAWA Hiroyuki wrote:
> > 
> > +       if (start_pfn & (pageblock_nr_pages - 1))
> > +               return -EINVAL;
> > +       if (end_pfn & (pageblock_nr_pages - 1))
> > +               return -EINVAL; 
> 
> After reading these, I'm still not sure I know what a pageblock is
> supposed to be. :)  Did those come from Mel's patches?
> 
yes.

> In any case, I think it might be helpful to wrap up some of those
> references in functions.  I was always looking at the patches trying to
> find if "pageblock_nr_pages" was a local variable or not.  A function
> would surely tell me.
> 
> static inline int pfn_is_pageblock_aligned(unsigned long pfn)
> {
> 	return pfn & (pageblock_nr_pages - 1)
> }
> 
> and, then you get
> 
> 		BUG_ON(!pfn_is_pageblock_aligned(start_pfn));
> 
> It's pretty obvious what is going on, there. 
> 
Hmm...I'll try that in the next version. But Is there some macro
to do this ? like..
--
#define IS_ALIGNED(val, align)	((val) & (align - 1))
--

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
