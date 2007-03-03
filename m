From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH] free swap space of (re)activated pages
Date: Sat, 3 Mar 2007 14:04:20 +1100
References: <45E88997.4050308@redhat.com> <20070302171818.d271348e.akpm@linux-foundation.org> <45E8CFD8.7050808@redhat.com>
In-Reply-To: <45E8CFD8.7050808@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200703031404.21064.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>, ck list <ck@vds.kolivas.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Saturday 03 March 2007 12:31, Rik van Riel wrote:
> Andrew Morton wrote:
> > On Fri, 02 Mar 2007 15:31:19 -0500
> >
> > Rik van Riel <riel@redhat.com> wrote:
> >> the attached patch frees the swap space of already resident pages
> >> when swap space starts getting tight, instead of only freeing up
> >> the swap space taken up by newly swapped in pages.
> >>
> >> This should result in the swap space of pages that remain resident
> >> in memory being freed, allowing kswapd more chances to actually swap
> >> a page out (instead of rotating it back onto the active list).
> >
> > Fair enough.   How do we work out if this helps things?
>
> I suspect it should mostly help on desktop systems that slowly
> fill up (and run out of) swap.  I'm not sure how to create that
> synthetically.

Ooh you have a vm patch that helps swap on the desktop! I can help you here 
with my experience from swap prefetch.

1. Get it reviewed and have noone show any evidence it harms
2. Find hundreds of users who can testify it helps
3. Find a way of quantifying it.
4. ...
5. Merge into mainline.


There, that should get you as far as 4. 

I haven't figured out what 4 is yet. I believe it may be goto 1;

-- 
-ck

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
