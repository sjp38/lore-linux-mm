Date: Tue, 5 Aug 2003 17:45:36 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch] real-time enhanced page allocator and throttling
Message-Id: <20030805174536.6cb5fbf0.akpm@osdl.org>
In-Reply-To: <1060130368.4494.166.camel@localhost>
References: <1060121638.4494.111.camel@localhost>
	<20030805170954.59385c78.akpm@osdl.org>
	<1060130368.4494.166.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>
Cc: linux-kernel@vger.kernel.org, Valdis.Kletnieks@vt.edu, piggin@cyberone.com.au, kernel@kolivas.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Robert Love <rml@tech9.net> wrote:
>
> On Tue, 2003-08-05 at 17:09, Andrew Morton wrote:
> 
> > -void balance_dirty_pages(struct address_space *mapping)
> > +static void balance_dirty_pages(struct address_space *mapping)
> 
> Hrm. void? I have this as an int in my tree (test2-mm4), did you change
> something? The function returns stuff.. I made it a 'static int'

ah, I had inserted that patch before the AIO patches, which change that.

> >  		dirty_exceeded = 1;
> > +		if (rt_task(current))
> > +			break;
> 
> OK, this was my other option. I think this is better because, as we have
> both said, it allows us to wake up pdflush.
> 
> Here is what I have right now, now ..

It's testing time.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
