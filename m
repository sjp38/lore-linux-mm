From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: Remove page flags for software suspend
Date: Fri, 2 Mar 2007 00:10:25 +0100
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com> <45E6EEC5.4060902@yahoo.com.au> <200703011633.54625.rjw@sisk.pl>
In-Reply-To: <200703011633.54625.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200703020010.26069.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Pavel Machek <pavel@ucw.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday, 1 March 2007 16:33, Rafael J. Wysocki wrote:
> On Thursday, 1 March 2007 16:18, Nick Piggin wrote:
> > Rafael J. Wysocki wrote:
> > > On Wednesday, 28 February 2007 16:25, Christoph Lameter wrote:
> > > 
> > >>On Wed, 28 Feb 2007, Pavel Machek wrote:
> > >>
> > >>
> > >>>I... actually do not like that patch. It adds code... at little or no
> > >>>benefit.
> > >>
> > >>We are looking into saving page flags since we are running out. The two 
> > >>page flags used by software suspend are rarely needed and should be taken 
> > >>out of the flags. If you can do it a different way then please do.
> > > 
> > > 
> > > As I have already said for a couple of times, I think we can and I'm going to
> > > do it, but right now I'm a bit busy with other things that I consider as more
> > > urgent.
> > 
> > I need one bit for lockless pagecache ;)
> > 
> > Anyway, I guess if you want something done you have to do it yourself.
> > 
> > This patch still needs work (and I don't know if it even works, because
> > I can't make swsusp resume even on a vanilla kernel). But this is my
> > WIP for removing swsusp page flags.
> > 
> > This patch adds a simple extent based nosave region tracker, and
> > rearranges some of the snapshot code to be a bit simpler and more
> > amenable to having dynamically allocated flags (they aren't actually
> > dynamically allocated in this patch, however).
> 
> Thanks for the patch.
> 
> Probably I'd like to do some things in a different way, I'll think about that
> later today.
> 
> I hope I'll have a working patch that removes the "offending" page flags after
> the weekend.

Well, there is one problem that I think you can help me solve.  Namely, the
arch code that marks the nosave pages runs very early, before the buddy
allocator is set up.  Thus the question is how I can allocate a list of nosave
regions at this stage of initialization, so that it survives to the point at
which swsusp can be activated.

Please advise.

Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
