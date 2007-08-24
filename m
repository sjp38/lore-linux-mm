Date: Fri, 24 Aug 2007 11:56:16 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 9/9] pagemap: export swap ptes
Message-ID: <20070824165616.GP21720@waste.org>
References: <20070822231804.1132556D@kernel> <20070822231814.8F5F37A0@kernel> <20070824002945.GE21720@waste.org> <1187972362.16177.3614.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1187972362.16177.3614.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 24, 2007 at 09:19:22AM -0700, Dave Hansen wrote:
> On Thu, 2007-08-23 at 19:29 -0500, Matt Mackall wrote:
> > On Wed, Aug 22, 2007 at 04:18:14PM -0700, Dave Hansen wrote:
> > > 
> > > In addition to understanding which physical pages are
> > > used by a process, it would also be very nice to
> > > enumerate how much swap space a process is using.
> > > 
> > > This patch enables /proc/<pid>/pagemap to display
> > > swap ptes.  In the process, it also changes the
> > > constant that we used to indicate non-present ptes
> > > before.
> > > 
> > > Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
> > 
> > I suspect you missed a quilt add here, as is_swap_pte is not in any
> > header file and is thus implicitly declared.
> 
> Yeah, I have another patch that was declared waaaaaaay earlier in my
> series that does this.

I moved it from mm/migrate.c to include/linux/swapops.h here.

>  I'm not completely confident in the way that I
> formatted the swap pte, so let's hold off on just this patch for now.
> I'll rework it and send it your way again in a few days.

Yeah, that bit is a little tricky. I'm going to be off the net for the
next week or so, so I can pick this up in September. I should just
need a resend of this patch.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
