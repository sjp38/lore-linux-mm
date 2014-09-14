Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 79A1A6B0035
	for <linux-mm@kvack.org>; Sun, 14 Sep 2014 19:24:20 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id ey11so5123925pad.20
        for <linux-mm@kvack.org>; Sun, 14 Sep 2014 16:24:20 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id ha1si19887167pbd.97.2014.09.14.16.24.18
        for <linux-mm@kvack.org>;
        Sun, 14 Sep 2014 16:24:19 -0700 (PDT)
Date: Mon, 15 Sep 2014 08:24:27 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 01/10] zsmalloc: fix init_zspage free obj linking
Message-ID: <20140914232427.GD2160@bbox>
References: <1410468841-320-1-git-send-email-ddstreet@ieee.org>
 <1410468841-320-2-git-send-email-ddstreet@ieee.org>
 <20140912045913.GA2160@bbox>
 <CALZtONAuJhgZLJECxwQOyKPj2n02d+521d+eHCkqLjjc=Ba9FQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CALZtONAuJhgZLJECxwQOyKPj2n02d+521d+eHCkqLjjc=Ba9FQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Sep 12, 2014 at 12:43:22PM -0400, Dan Streetman wrote:
> On Fri, Sep 12, 2014 at 12:59 AM, Minchan Kim <minchan@kernel.org> wrote:
> > On Thu, Sep 11, 2014 at 04:53:52PM -0400, Dan Streetman wrote:
> >> When zsmalloc creates a new zspage, it initializes each object it contains
> >> with a link to the next object, so that the zspage has a singly-linked list
> >> of its free objects.  However, the logic that sets up the links is wrong,
> >> and in the case of objects that are precisely aligned with the page boundries
> >> (e.g. a zspage with objects that are 1/2 PAGE_SIZE) the first object on the
> >> next page is skipped, due to incrementing the offset twice.  The logic can be
> >> simplified, as it doesn't need to calculate how many objects can fit on the
> >> current page; simply checking the offset for each object is enough.
> >
> > If objects are precisely aligned with the page boundary, pages_per_zspage
> > should be 1 so there is no next page.
> 
> ah, ok.  I wonder if it should be changed anyway so it doesn't rely on
> that detail, in case that's ever changed in the future.  It's not
> obvious the existing logic relies on that for correct operation.  And
> this simplifies the logic too.

Correct description and resend if you want.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
