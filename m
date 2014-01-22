Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 625F36B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 15:34:01 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id g10so843263pdj.30
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 12:34:01 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ek3si11145619pbd.235.2014.01.22.12.33.59
        for <linux-mm@kvack.org>;
        Wed, 22 Jan 2014 12:33:59 -0800 (PST)
Date: Wed, 22 Jan 2014 12:33:58 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/zswap: add writethrough option
Message-Id: <20140122123358.a65c42605513fc8466152801@linux-foundation.org>
In-Reply-To: <CALZtONAaPCi8eUhSmdXSxWbeFFN=ChsfL9OurSZUsSPo-_gnfg@mail.gmail.com>
References: <1387459407-29342-1-git-send-email-ddstreet@ieee.org>
	<20140114001115.GU1992@bbox>
	<CALZtONCCrckuHxgHB=GQj0tHszLAYTZZLGzFTnRkj9pvxx0dyg@mail.gmail.com>
	<20140115054208.GL1992@bbox>
	<CALZtONCehE8Td2C2w-fOC596uD54y1-kyc3SiKABBEODMb+a7Q@mail.gmail.com>
	<CALZtONAaPCi8eUhSmdXSxWbeFFN=ChsfL9OurSZUsSPo-_gnfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Weijie Yang <weijie.yang@samsung.com>, Shirish Pargaonkar <spargaonkar@suse.com>, Mel Gorman <mgorman@suse.de>

On Wed, 22 Jan 2014 09:19:58 -0500 Dan Streetman <ddstreet@ieee.org> wrote:

> >>> > Acutally, I really don't know how much benefit we have that in-memory
> >>> > swap overcomming to the real storage but if you want, zRAM with dm-cache
> >>> > is another option rather than invent new wheel by "just having is better".
> >>>
> >>> I'm not sure if this patch is related to the zswap vs. zram discussions.  This
> >>> only adds the option of using writethrough to zswap.  It's a first
> >>> step to possibly
> >>> making zswap work more efficiently using writeback and/or writethrough
> >>> depending on
> >>> the system and conditions.
> >>
> >> The patch size is small. Okay I don't want to be a party-pooper
> >> but at least, I should say my thought for Andrew to help judging.
> >
> > Sure, I'm glad to have your suggestions.
> 
> To give this a bump - Andrew do you have any concerns about this
> patch?  Or can you pick this up?

I don't pay much attention to new features during the merge window,
preferring to shove them into a folder to look at later.  Often they
have bitrotted by the time -rc1 comes around.

I'm not sure that this review discussion has played out yet - is
Minchan happy?

Please update the changelog so that it reflects the questions Minchan
asked (any reviewer question should be regarded as an inadequacy in
either the code commenting or the changelog - people shouldn't need to
ask the programmer why he did something!) and resend for -rc1?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
