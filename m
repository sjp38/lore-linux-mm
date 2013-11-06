Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 44E296B00CB
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 08:46:24 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id ma3so9011502pbc.18
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 05:46:23 -0800 (PST)
Received: from psmtp.com ([74.125.245.190])
        by mx.google.com with SMTP id yl8si5992275pab.147.2013.11.06.05.46.22
        for <linux-mm@kvack.org>;
        Wed, 06 Nov 2013 05:46:22 -0800 (PST)
Received: by mail-ob0-f178.google.com with SMTP id va2so2317292obc.9
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 05:46:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131028221620.042323B3@viggo.jf.intel.com>
References: <20131028221618.4078637F@viggo.jf.intel.com>
	<20131028221620.042323B3@viggo.jf.intel.com>
Date: Wed, 6 Nov 2013 21:46:20 +0800
Message-ID: <CAJd=RBAFgn=3GvEEdHDARpw_h+6SbYE_35D5QJX7C60cVd4tmA@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: thp: give transparent hugepage code a separate copy_page
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, dave.jiang@intel.com, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Oct 29, 2013 at 6:16 AM, Dave Hansen <dave@sr71.net> wrote:
> +
> +void copy_high_order_page(struct page *newpage,
> +                         struct page *oldpage,
> +                         int order)
> +{
> +       int i;
> +
> +       might_sleep();
> +       for (i = 0; i < (1<<order); i++) {
> +               cond_resched();
> +               copy_highpage(newpage + i, oldpage + i);
> +       }
> +}

Can we make no  use of might_sleep here with cond_resched in loop?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
