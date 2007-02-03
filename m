Date: Sat, 3 Feb 2007 03:28:51 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/9] fs: libfs buffered write leak fix
Message-ID: <20070203022851.GA16887@wotan.suse.de>
References: <20070129081905.23584.97878.sendpatchset@linux.site> <20070129081914.23584.23886.sendpatchset@linux.site> <20070202155236.dae54aa2.akpm@linux-foundation.org> <20070203013316.GB27300@wotan.suse.de> <20070202175801.3f97f79b.akpm@linux-foundation.org> <20070203020926.GD27300@wotan.suse.de> <20070202181955.a48d5b3c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070202181955.a48d5b3c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Feb 02, 2007 at 06:19:55PM -0800, Andrew Morton wrote:
> On Sat, 3 Feb 2007 03:09:26 +0100
> Nick Piggin <npiggin@suse.de> wrote:
> 
> > From: Nick Piggin <npiggin@suse.de>
> > To: Andrew Morton <akpm@osdl.org>
> 
> argh.  Yesterday all my emails were getting a mysterious
> s/osdl/linux-foundation/ done to them at the server, so I switched everything
> over.  Now it would appear that they are getting an equally mysterious
> s/linux-foundation/osdl/ done to them.  I assume you sent this to
> akpm@linux-foundation.org?

No. Your first reply I got to this patch came as linux-foundantion, and
that's what I replied to. Your subsequent reply back to me ("Yes, the page
just isn't uptodate yet..."), came from osdl.org, which is what I replied
to.

> > Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
> > Subject: Re: [patch 1/9] fs: libfs buffered write leak fix
> > Date: Sat, 3 Feb 2007 03:09:26 +0100
> > User-Agent: Mutt/1.5.9i
> > 
> > On Fri, Feb 02, 2007 at 05:58:01PM -0800, Andrew Morton wrote:
> > > On Sat, 3 Feb 2007 02:33:16 +0100
> > > Nick Piggin <npiggin@suse.de> wrote:
> > > 
> > > > I think just setting page uptodate in commit_write might do the
> > > > trick? (and getting rid of the set_page_dirty there).
> > > 
> > > Yes, the page just isn't uptodate yet in prepare_write() - moving things
> > > to commti_write() sounds sane.
> > > 
> > > But please, can we have sufficient changelogs and comments in the next version?
> > 
> > You're right, sorry. Is this any better?
> 
> yup, thanks.
> 
> > (warning: nobh code is untested)
> 
> ow.

I'll get a chance to do that later today. I have to fire up the old test
case and see if I can reproduce the problem with nobh on a real fs...
Will get back to you when I do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
