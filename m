Date: Mon, 28 Jan 2008 01:01:02 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] remove duplicating priority setting in try_to_free_p
Message-Id: <20080128010102.8cbcbdda.akpm@linux-foundation.org>
In-Reply-To: <28c262360801272243h71bf4464s431d1377051c756b@mail.gmail.com>
References: <28c262360801252329q7232edc2l2d0e4ed17c054832@mail.gmail.com>
	<20080127213312.517b8014.akpm@linux-foundation.org>
	<28c262360801272243h71bf4464s431d1377051c756b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: minchan kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Bligh <mbligh@mbligh.org>, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jan 2008 15:43:56 +0900 "minchan kim" <minchan.kim@gmail.com> wrote:

> > I think this is actually a bugfix.  The code you're removing doesn't do the
> >
> >         if (priority < zone->prev_priority)
> >
> > thing.
> >
> 
> shrink_zones() in try_to_free_pages() already called
> note_zone_scanning_priority().
> So, it have done it.

note_zone_scanning_priority() will only permit ->prev_priority to logically
increase, whereas the code which you've removed will also permit
->prev_priority to logically decrease.  So I don't see that they are
equivalent?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
