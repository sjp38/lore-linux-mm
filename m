Date: Thu, 5 Aug 2004 01:24:24 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] break out zone free list initialization
Message-Id: <20040805012424.7da14c83.akpm@osdl.org>
In-Reply-To: <1091034585.2871.142.camel@nighthawk>
References: <1091034585.2871.142.camel@nighthawk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: wli@holomorphy.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Dave Hansen <haveblue@us.ibm.com> wrote:
>
> The following patch removes the individual free area initialization from
>  free_area_init_core(), and puts it in a new function
>  zone_init_free_lists().  It also creates pages_to_bitmap_size(), which
>  is then used in zone_init_free_lists() as well as several times in my
>  free area bitmap resizing patch.  

This causes my very ordinary p4 testbox to crash very early in boot.  It's
quite pretty, with nice colourful stripes of blinking text on the display.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
