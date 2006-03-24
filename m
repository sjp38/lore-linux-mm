From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] mm: swsusp shrink_all_memory tweaks
Date: Fri, 24 Mar 2006 17:14:48 +0100
References: <200603200231.50666.kernel@kolivas.org> <200603241616.06687.rjw@sisk.pl> <200603250230.08140.kernel@kolivas.org>
In-Reply-To: <200603250230.08140.kernel@kolivas.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200603241714.48909.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux list <linux-kernel@vger.kernel.org>, ck list <ck@vds.kolivas.org>, Andrew Morton <akpm@osdl.org>, Pavel Machek <pavel@ucw.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 24 March 2006 16:30, Con Kolivas wrote:
> On Saturday 25 March 2006 02:16, Rafael J. Wysocki wrote:
> > On Friday 24 March 2006 08:07, Con Kolivas wrote:
> > > On Tuesday 21 March 2006 05:46, Rafael J. Wysocki wrote:
> > > > swsusp_shrink_memory() is still wrong, because it will always fail for
> > > > image_size = 0.  My bad, sorry.
> > > >
> > > > The appended patch (on top of yours) should fix that (hope I did it
> > > > right this time).
> > >
> > > Well I discovered that if all the necessary memory is freed in one call
> > > to shrink_all_memory we don't get the nice updating printout from
> > >  swsusp_shrink_memory telling us we're making progress. So instead of
> > >  modifying the function to call shrink_all_memory with the full amount
> > > (and since we've botched swsusp_shrink_memory a few times between us), we
> > > should limit it to a max of SHRINK_BITEs instead.
> > >
> > >  This patch is fine standalone.
> > >
> > >  Rafael, Pavel what do you think of this one?
> >
> > In principle it looks good to me, but when I tested the previous one I
> > noticed shrink_all_memory() tended to return 0 prematurely (ie. when it was
> > possible to free some more pages).  It only happened if more than 50% of
> > memory was occupied by application data.
> >
> > Unfortunately I couldn't find the reason.
> 
> Perhaps it was just trying to free up too much in one go. There are a number 
> of steps a mapped page needs to go through before being finally swapped and 
> there are a limited number of iterations over it. Limiting it to SHRINK_BITEs 
> at a time will probably improve that.

OK [I'll be testing it for the next couple of days.]

Greetings,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
