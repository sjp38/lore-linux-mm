Received: from 203-167-152-228.dialup.clear.net.nz
 (203-167-152-228.dialup.clear.net.nz [203.167.152.228])
 by smtp1.clear.net.nz (CLEAR Net Mail)
 with ESMTP id <0HBM0018U2T550@smtp1.clear.net.nz> for linux-mm@kvack.org; Wed,
 12 Mar 2003 14:00:44 +1300 (NZDT)
Date: Wed, 12 Mar 2003 13:50:18 +1300
From: Nigel Cunningham <ncunningham@clear.net.nz>
Subject: Re: Free pages leaking in 2.5.64?
In-reply-to: <20030311162552.7f78e764.akpm@digeo.com>
Message-id: <1047430217.2288.7.camel@laptop-linux.cunninghams>
MIME-version: 1.0
Content-type: text/plain
Content-transfer-encoding: 7bit
References: <1047376995.1692.23.camel@laptop-linux.cunninghams>
 <20030311162552.7f78e764.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi.

Thanks for the reply. I hadn't looked at the hot/cold stuff before. I
sussed it out this morning and added a condition to the test for
refilling the pcp arrays, stopping them from being refilled during a
suspend/resume cycle. Now everything works fine in that area for me.
I'll check that there aren't any other calls to refill the pcp arrays,
so I can be sure it will work with interrupts enabled and whenever smp
support is added to swsusp.

Now I just have to get the image written and read back and switch from
using page flags to dynamically allocated bitmaps, as I said I would.

Thanks again for the reply and regards,

Nigel

On Wed, 2003-03-12 at 13:25, Andrew Morton wrote:
> Nigel Cunningham <ncunningham@clear.net.nz> wrote:
> >
> > Hi all.
> > 
> > I've come across the following problem in 2.5.64. Here's example output.
> > The header is one page - all messages only have a single call to
> > get_zeroed_page between the printings and the same code works as
> 
> nr_free_pages() does not account for the pages in the per-cpu head arrays. 
> 
> You can make the numbers look right via drain_local_pages(), but that is only
> 100% reliable on uniprocessor with interrupts disabled.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
