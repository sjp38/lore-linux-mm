Date: Wed, 2 May 2007 15:06:13 -0700
From: Greg KH <gregkh@suse.de>
Subject: Re: 2.6.21-rc7-mm2 crash: Eeek! page_mapcount(page) went negative!
	(-1)
Message-ID: <20070502220613.GC21015@suse.de>
References: <46338AEB.2070109@imap.cc> <20070428141024.887342bd.akpm@linux-foundation.org> <4636248E.7030309@imap.cc> <20070430112130.b64321d3.akpm@linux-foundation.org> <46364346.6030407@imap.cc> <20070430124638.10611058.akpm@linux-foundation.org> <46383742.9050503@imap.cc> <20070502001000.8460fb31.akpm@linux-foundation.org> <20070502074305.GA7761@suse.de> <1178098882.28231.1187661107@webmail.messagingengine.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1178098882.28231.1187661107@webmail.messagingengine.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tilman Schmidt <tilman@imap.cc>
Cc: Andrew Morton <akpm@linux-foundation.org>, Kay Sievers <kay.sievers@vrfy.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 02, 2007 at 11:41:22AM +0200, Tilman Schmidt wrote:
> On Wed, 2 May 2007 00:43:05 -0700, "Greg KH" <gregkh@suse.de> said:
> 
> > > > And the winner is:
> > > > 
> > > > gregkh-driver-driver-core-make-uevent-environment-available-in-uevent-file.patch
> > > > 
> > > > Reverting only that from 2.6.21-rc7-mm2 gives me a working kernel
> > > > again.
> > 
> > Wait, even though this isn't good, it shouldn't have been hit by anyone,
> > that file used to not be readable, so I doubt userspace would have been
> > trying to read it...
> > 
> > Tilman, what version of HAL and udev do you have on your machine?
> 
> The ones that came with SuSE 10.0:
> 
> hal-0.5.4-6.4
> udev-068git20050831-9

Ah, ok, that explains it, the really old libsysfs walks and opens all
files in sysfs for some odd, strange, and broken reason.  This has been
fixed in newer versions, and explains why you are seeing this happen.

I'll send my fix for this to Linus in a few hours.

thanks for testing and tracking this down, I really appreciate it.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
