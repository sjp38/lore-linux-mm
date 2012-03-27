Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id A796D6B00F5
	for <linux-mm@kvack.org>; Tue, 27 Mar 2012 13:06:06 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so633202pbc.14
        for <linux-mm@kvack.org>; Tue, 27 Mar 2012 10:06:05 -0700 (PDT)
Date: Tue, 27 Mar 2012 10:06:00 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] staging: zsmalloc: add user-definable alloc/free funcs
Message-ID: <20120327170600.GA18222@kroah.com>
References: <1331931888-14175-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <20120316213227.GB24556@kroah.com>
 <4F678100.1000707@linux.vnet.ibm.com>
 <20120319233409.GA16124@kroah.com>
 <20120326155018.GA6163@phenom.dumpdata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120326155018.GA6163@phenom.dumpdata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, devel@driverdev.osuosl.org, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

On Mon, Mar 26, 2012 at 11:50:19AM -0400, Konrad Rzeszutek Wilk wrote:
> On Mon, Mar 19, 2012 at 04:34:09PM -0700, Greg Kroah-Hartman wrote:
> > On Mon, Mar 19, 2012 at 01:54:56PM -0500, Seth Jennings wrote:
> > > > I'm sorry, I know this isn't fair for your specific patch, but we have
> > > > to stop this sometime, and as this patch adds code isn't even used by
> > > > anyone, its a good of a time as any.
> > > 
> > > So, this the my first "promotion from staging" rodeo.  I would love to
> > > see this code mainlined ASAP.  How would I/we go about doing that?
> > 
> > What subsystem should this code live in?  The -mm code, I'm guessing,
> > right?  If so, submit it to the linux-mm mailing list for inclusion, you
> > can point them at what is in drivers/staging right now, or probably it's
> > easier if you just make a new patch that adds the code that is in
> > drivers/staging/ to the correct location in the kernel.  That way it's
> > easier to review and change.  When it finally gets accepted, we can then
> > delete the drivers/staging code.
> 
> 
> Hey Greg,
> 
> Little background - for zcache to kick-butts (both Dan and Seth posted some
> pretty awesome benchmark numbers) it depends on the frontswap - which is in
> the #linux-next. Dan made an attempt to post it for a GIT PULL and an interesting
> conversation ensued where folks decided it needs more additions before they were
> comfortable with it. zcache isn't using those additions, but I don't see why
> it couldn't use them.
> 
> The things that bouncing around in my head are:
>  - get a punch-out list (ie todo) of what MM needs for the zcache to get out.
>    I think posting it as a new driver would be right way to do it (And then
>    based on feedback work out the issues in drivers/staging). But what
>    about authorship - there are mulitple authors ?

What does authorship matter here?  To move files out of staging, just
send a patch that does that, all authorship history is preserved.

And as a new driver, that's up to the mm developers, not me.

>  - zcache is a bit different that the normal drivers type - and it is unclear
>    yet what will be required to get it out - and both Seth and Nitin have this
>    hungry look in their eyes of wanting to make it super-duper. So doing
>    the work to do it - is not going to be a problem at all - just some form
>    of clear goals of what we need "now" vs "would love to have".

Again, work with the -mm developers.

>  - folks are using it, which means continued -stable kernel back-porting.

What do you mean by this?

> So with that in mind I was wondering whether you would be up for:
>  - me sending to you before a merge window some updates to the zcache
>    as a git pull - that way you won't have to deal with a bunch of
>    small patches and when there is something you don't like we can fix
>    it up to your liking. The goal would be for us - Dan, Nitin, Seth and me
>    working on promoting the driver out of staging and you won't have to
>    be bugged every time we have a new change that might be perceived
>    as feature, but is in fact a step towards mainstreaming it. I figured
>    that is what you are most annoyed at - handling those uncoordinated
>    requests and not seeing a clear target.

Lots of small patches are fine, as long as they are obviously working
toward getting the code out of staging.  This specific patch was just
adding a new feature, one that no one could even use, so that was not
something that would help it get out of the staging tree.

So no, I don't need patches batched up, and a git pull, I just need to
see that every patch I am sent is working toward getting it out of here.

>  - alongside of that, I work on making those frontswap changes folks
>    have asked for. Since those changes can affect zcache, that means
>    adding them in zcache alongside.

Ok.

> Hopefully, by the time those two items are done, both pieces can go in
> the kernel at the same time-ish.

That would be good to see have happen.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
