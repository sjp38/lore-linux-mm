Date: Wed, 23 Jul 2008 22:26:28 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: GRU driver feedback
Message-ID: <20080724032627.GA36603@sgi.com>
References: <20080723141229.GB13247@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080723141229.GB13247@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 23, 2008 at 04:12:30PM +0200, Nick Piggin wrote:
> 
> Hi Jack,
> 
> Some review of the GRU driver. Hope it helps. Some trivial.

Thanks for the feedback. I'm at OLS this week & barely reading email.
I'll go thru the comments as soon as I get home next week & will
respond in detail then.


> 
> - I would put all the driver into a single patch. It's a logical change,
>   and splitting them out is not really logical. Unless for example you
>   start with a minimally functional driver and build more things on it,
>   I don't think there is any point avoiding the one big patch. You have to
>   look at the whole thing to understand it properly anyway really.

I would prefer that, too, but was told by one of the more verbose
kernel developers (who will remain nameless) that I should split the code
into multiple patches to make it easier to review. Oh well.....


More responses to follow....


--- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
