Subject: Re: [PATCH] break out zone free list initialization
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20040805012424.7da14c83.akpm@osdl.org>
References: <1091034585.2871.142.camel@nighthawk>
	 <20040805012424.7da14c83.akpm@osdl.org>
Content-Type: text/plain
Message-Id: <1091727817.27397.8123.camel@nighthawk>
Mime-Version: 1.0
Date: Thu, 05 Aug 2004 10:43:37 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2004-08-05 at 01:24, Andrew Morton wrote:
> Dave Hansen <haveblue@us.ibm.com> wrote:
> >
> > The following patch removes the individual free area initialization from
> >  free_area_init_core(), and puts it in a new function
> >  zone_init_free_lists().  It also creates pages_to_bitmap_size(), which
> >  is then used in zone_init_free_lists() as well as several times in my
> >  free area bitmap resizing patch.  
> 
> This causes my very ordinary p4 testbox to crash very early in boot.  It's
> quite pretty, with nice colourful stripes of blinking text on the display.

Just for a sanity check: are there other machines that it booted on
without any problems for you?

I'll go steal someone's P4 desktop and retest.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
