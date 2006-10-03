Date: Mon, 2 Oct 2006 18:06:03 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: kernel: pageout: orphaned page with reiserfs v3 in data=journal
 mode under 2.6.18
Message-Id: <20061002180603.b19bfbd0.akpm@osdl.org>
In-Reply-To: <20061002170353.GA26816@king.bitgnome.net>
References: <20061002170353.GA26816@king.bitgnome.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Nipper <nipsy@bitgnome.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2 Oct 2006 12:03:54 -0500
Mark Nipper <nipsy@bitgnome.net> wrote:

>         I saw this in my logs earlier today:
> ---
> kernel: pageout: orphaned page
> 
>         It's the first time I've seen it on this box, but I also
> just switched to data=journal mode for all of my reiserfs mounts
> yesterday after a hard drive died in a software RAID-1 volume
> (which incidentally caused some thankfully repairable file system
> damage after a --rebuild-tree seemingly because even though the
> hard drive which was failing was reporting uncorrectable errors
> to the kernel, the software RAID system never failed the drive
> out of the volume but instead kept trying to use it).
> 
>         Anyway, just wondering if the message is bad actually as
> in it indicates some memory leak will bring down my server at
> some point or if it's just a corner case which someone felt the
> need to document whenever it happens.

I think that's a piece of temporary debugging code which I put in there in
a fit of curiosity and which I then promptly forgot about.

It's been in there since March 2005 and you are the first person who has
reported seeing the message...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
