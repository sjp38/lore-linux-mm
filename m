Subject: Re: broken VM in 2.4.10-pre9
References: <E15jpRy-0003yt-00@the-village.bc.nu>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 19 Sep 2001 16:26:40 -0600
In-Reply-To: <E15jpRy-0003yt-00@the-village.bc.nu>
Message-ID: <m166aeg6lb.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Daniel Phillips <phillips@bonn-fries.net>, Rob Fuller <rfuller@nsisoftware.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alan Cox <alan@lxorguk.ukuu.org.uk> writes:

> Much of this goes away if you get rid of both the swap and anonymous page
> special cases. Back anonymous pages with the "whoops everything I write here
> vanishes mysteriously" file system and swap with a swapfs

Essentially.  Though that is just the strategy it doesn't cut to the heart of the
problems that need to be addressed.  The trickiest part is to allocate persistent
id's to the pages that don't require us to fragment the VMA's.

> Reverse mappings make linear aging easier to do but are not critical (we
> can walk all physical pages via the page map array).

Agreed.

What I find interesting about the 2.4.x VM is that most of the large
problems people have seen were not stupid designs mistakes in the VM
but small interaction glitches, between various pieces of code.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
