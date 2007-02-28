From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: Remove page flags for software suspend
Date: Wed, 28 Feb 2007 23:23:20 +0100
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0702281315560.28432@schroedinger.engr.sgi.com> <20070228212235.GD4760@ucw.cz>
In-Reply-To: <20070228212235.GD4760@ucw.cz>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200702282323.21902.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Christoph Lameter <clameter@engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday, 28 February 2007 22:22, Pavel Machek wrote:
> On Wed 2007-02-28 13:16:51, Christoph Lameter wrote:
> > On Wed, 28 Feb 2007, Pavel Machek wrote:
> > 
> > > Hmm, can't we just add another word to struct page?
> 
> ?

That would be wasteful, I think, and PageNosaveFree isn't really needed
outside the swsusp code.

> > > Plus we really need PageNosave from boot on...

Yes.

> > 
> > Well it would be great to get the story straight. First I was told that 
> > the bitmaps can be allocated later. Now we dont. The current patch should 
> > do what you want.

Nope.  There are two flags and one of them (PageNosaveFree) can and really
should be allocated later, while the other (PageNosave) is needed from the
start.
 
> PageNosave is set by boot code in some cases, as Rafael told you.
> 
> It may be possible to redo boot processing at suspend time, but it
> would be ugly can of worms, I'm not sure if BIOS data are still
> available, and neccessary functions are probably __init.

Exactly.

Greetings,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
