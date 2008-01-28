Received: by an-out-0708.google.com with SMTP id d33so453566and.105
        for <linux-mm@kvack.org>; Mon, 28 Jan 2008 04:38:59 -0800 (PST)
Message-ID: <28c262360801280438s59b6957bnffa5f3cf75f93014@mail.gmail.com>
Date: Mon, 28 Jan 2008 21:38:57 +0900
From: "minchan kim" <minchan.kim@gmail.com>
Subject: Re: [PATCH] remove duplicating priority setting in try_to_free_p
In-Reply-To: <20080128010102.8cbcbdda.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <28c262360801252329q7232edc2l2d0e4ed17c054832@mail.gmail.com>
	 <20080127213312.517b8014.akpm@linux-foundation.org>
	 <28c262360801272243h71bf4464s431d1377051c756b@mail.gmail.com>
	 <20080128010102.8cbcbdda.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Bligh <mbligh@mbligh.org>, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

I agree with you.
If you will have a test result, Let me know it.

On Jan 28, 2008 6:01 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Mon, 28 Jan 2008 15:43:56 +0900 "minchan kim" <minchan.kim@gmail.com> wrote:
>
> > > I think this is actually a bugfix.  The code you're removing doesn't do the
> > >
> > >         if (priority < zone->prev_priority)
> > >
> > > thing.
> > >
> >
> > shrink_zones() in try_to_free_pages() already called
> > note_zone_scanning_priority().
> > So, it have done it.
>
> note_zone_scanning_priority() will only permit ->prev_priority to logically
> increase, whereas the code which you've removed will also permit
> ->prev_priority to logically decrease.  So I don't see that they are
> equivalent?
>
>



-- 
Kinds regards,
barrios

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
