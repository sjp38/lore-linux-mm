Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AA9866B0005
	for <linux-mm@kvack.org>; Sun,  3 Jul 2016 23:32:27 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 143so370144179pfx.0
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 20:32:27 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id a12si1670846pfc.36.2016.07.03.20.32.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Jul 2016 20:32:26 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id 66so15225349pfy.1
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 20:32:26 -0700 (PDT)
Date: Mon, 4 Jul 2016 11:32:21 +0800
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: Re: [PATCH 6/8] mm/zsmalloc: keep comments consistent with code
Message-ID: <20160704033221.GD9895@leo-test>
References: <1467355266-9735-1-git-send-email-opensource.ganesh@gmail.com>
 <1467355266-9735-6-git-send-email-opensource.ganesh@gmail.com>
 <20160704000516.GE19044@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160704000516.GE19044@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com

On Mon, Jul 04, 2016 at 09:05:16AM +0900, Minchan Kim wrote:
> On Fri, Jul 01, 2016 at 02:41:04PM +0800, Ganesh Mahendran wrote:
> > some minor change of comments:
> > 1). update zs_malloc(),zs_create_pool() function header
> > 2). update "Usage of struct page fields"
> > 
> > Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
> > ---
> >  mm/zsmalloc.c | 7 +++----
> >  1 file changed, 3 insertions(+), 4 deletions(-)
> > 
> > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> > index 2690914..6fc631a 100644
> > --- a/mm/zsmalloc.c
> > +++ b/mm/zsmalloc.c
> > @@ -20,6 +20,7 @@
> >   *	page->freelist(index): links together all component pages of a zspage
> >   *		For the huge page, this is always 0, so we use this field
> >   *		to store handle.
> > + *	page->units: first object index in a subpage of zspage
> 
> Hmm, I want to use offset instead of index.

Yes, it should be offset here. I mixed it with obj index. :)

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
