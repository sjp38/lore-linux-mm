Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 387536B0275
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 18:48:31 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id 5so26745wmk.0
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 15:48:31 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z61si732408wrc.174.2017.11.15.15.48.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Nov 2017 15:48:29 -0800 (PST)
Date: Wed, 15 Nov 2017 15:48:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: use sc->priority for slab shrink targets
Message-Id: <20171115154826.45d70959f630ac7508d8d36e@linux-foundation.org>
In-Reply-To: <1510766070-4772-1-git-send-email-josef@toxicpanda.com>
References: <1510766070-4772-1-git-send-email-josef@toxicpanda.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: kernel-team@fb.com, linux-mm@kvack.org, Josef Bacik <jbacik@fb.com>

On Wed, 15 Nov 2017 12:14:30 -0500 Josef Bacik <josef@toxicpanda.com> wrote:

> Previously we were using the ratio of the number of lru pages scanned to
> the number of eligible lru pages to determine the number of slab objects
> to scan.  The problem with this is that these two things have nothing to
> do with each other, so in slab heavy work loads where there is little to
> no page cache we can end up with the pages scanned being a very low
> number.  This means that we reclaim next to no slab pages and waste a
> lot of time reclaiming small amounts of space.
> 
> ...
>
> Andrew, I noticed you hadn't picked this up yet, so I rebased it on the latest
> linus and updated the ack's, it should be good to go.

I dropped a previous version of this on Oct 3 due to runtime failures
(I think).  What were those and how does this patch fix them (if it
does?)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
