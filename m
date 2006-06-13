Subject: Re: [PATCH]: Adding a counter in vma to indicate the number of
	physical_pages_backing it
From: Rohit Seth <rohitseth@google.com>
Reply-To: rohitseth@google.com
In-Reply-To: <200606130756.52669.ak@suse.de>
References: <787b0d920606122253o4f1a9e18x1ca49c3ce005696f@mail.gmail.com>
	 <200606130756.52669.ak@suse.de>
Content-Type: text/plain
Date: Tue, 13 Jun 2006 10:10:36 -0700
Message-Id: <1150218637.9576.73.camel@galaxy.corp.google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Albert Cahalan <acahalan@gmail.com>, linux-kernel@vger.kernel.org, akpm@osdl.org, Linux-mm@kvack.org, arjan@infradead.org, jengelh@linux01.gwdg.de
List-ID: <linux-mm.kvack.org>

On Tue, 2006-06-13 at 07:56 +0200, Andi Kleen wrote:
> On Tuesday 13 June 2006 07:53, Albert Cahalan wrote:
> > Quoting two different people:
> > 
> > > BTW, what is smaps used for (who uses it), anyway?
> > ...
> > > smaps is only a debugging kludge anyways and it's
> > > not a good idea to we bloat core data structures for it.
> > 
> > I'd be using it in procps for the pmap command if it
> > were not so horribly nasty. I may eventually get around
> > to using it, but maybe it's just too gross to tolerate.
> 
> I agree it's pretty ugly.
> 
> But pmap I would consider a debugging kludge too - it should
> work when someone needs it, but it doesn't need to be particularly
> fast.
> 


Providing useful information about memory consumption is hardly
debugging kludge.  Quite unfortunately the rss part of the col is filled
with dashes at present.  This vma based counter will allow Albert to
print useful information w/o having to traverse the whole set of page
tables.

-rohit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
