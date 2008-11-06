Date: Thu, 6 Nov 2008 13:28:55 +0100
From: Pavel Machek <pavel@suse.cz>
Subject: Re: [PATCH] hibernation should work ok with memory hotplug
Message-ID: <20081106122855.GA1549@ucw.cz>
References: <20081029105956.GA16347@atrey.karlin.mff.cuni.cz> <200810291325.01481.rjw@sisk.pl> <20081103125108.46d0639e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081103125108.46d0639e.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org, linux-pm@lists.osdl.org, Matt Tolentino <matthew.e.tolentino@intel.com>, Dave Hansen <haveblue@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 2008-11-03 12:51:08, Andrew Morton wrote:
> On Wed, 29 Oct 2008 13:25:00 +0100
> "Rafael J. Wysocki" <rjw@sisk.pl> wrote:
> 
> > On Wednesday, 29 of October 2008, Pavel Machek wrote:
> > > 
> > > hibernation + memory hotplug was disabled in kconfig because we could
> > > not handle hibernation + sparse mem at some point. It seems to work
> > > now, so I guess we can enable it.
> > 
> > OK, if "it seems to work now" means that it has been tested and confirmed to
> > work, no objection from me.
> 
> yes, that was not a terribly confidence-inspiring commit message.
> 
> 3947be1969a9ce455ec30f60ef51efb10e4323d1 said "For now, disable memory
> hotplug when swsusp is enabled.  There's a lot of churn there right
> now.  We'll fix it up properly once it calms down." which is also
> rather rubbery.  

I was not terribly confident. Sorry about that.

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
