From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: Remove page flags for software suspend
Date: Thu, 1 Mar 2007 21:46:37 +0100
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com> <200702281813.04643.rjw@sisk.pl> <45E6EEC5.4060902@yahoo.com.au>
In-Reply-To: <45E6EEC5.4060902@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200703012146.38307.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Pavel Machek <pavel@ucw.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thursday, 1 March 2007 16:18, Nick Piggin wrote:
> Rafael J. Wysocki wrote:
> > On Wednesday, 28 February 2007 16:25, Christoph Lameter wrote:
> > 
> >>On Wed, 28 Feb 2007, Pavel Machek wrote:
> >>
> >>
> >>>I... actually do not like that patch. It adds code... at little or no
> >>>benefit.
> >>
> >>We are looking into saving page flags since we are running out. The two 
> >>page flags used by software suspend are rarely needed and should be taken 
> >>out of the flags. If you can do it a different way then please do.
> > 
> > 
> > As I have already said for a couple of times, I think we can and I'm going to
> > do it, but right now I'm a bit busy with other things that I consider as more
> > urgent.
> 
> I need one bit for lockless pagecache ;)
> 
> Anyway, I guess if you want something done you have to do it yourself.
> 
> This patch still needs work (and I don't know if it even works, because
> I can't make swsusp resume even on a vanilla kernel).

That's interesting, BTW, because recently I've been having problems with
finding a machine on which it doesn't work. ;-)  If you could tell me (in
private) what the problems are, I'd try to help.

> But this is my WIP for removing swsusp page flags.
> 
> This patch adds a simple extent based nosave region tracker, and
> rearranges some of the snapshot code to be a bit simpler and more
> amenable to having dynamically allocated flags (they aren't actually
> dynamically allocated in this patch, however).

I like the idea of using just one bit for marking the allocated pages and the
simplifications it allows us to make, but is it really true that all of the
free pages and only the free pages will have page_count(page) == 0?

Also, the extents-related part is not exactly nice IMHO ...

Greetings,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
