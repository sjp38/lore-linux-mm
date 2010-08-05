Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id ADE006B02A4
	for <linux-mm@kvack.org>; Wed,  4 Aug 2010 20:19:11 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id o750J8m5012421
	for <linux-mm@kvack.org>; Wed, 4 Aug 2010 17:19:08 -0700
Received: from pvf33 (pvf33.prod.google.com [10.241.210.97])
	by hpaq1.eem.corp.google.com with ESMTP id o750IidR011025
	for <linux-mm@kvack.org>; Wed, 4 Aug 2010 17:19:07 -0700
Received: by pvf33 with SMTP id 33so2575745pvf.36
        for <linux-mm@kvack.org>; Wed, 04 Aug 2010 17:19:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100804150422.c52b308e.akpm@linux-foundation.org>
References: <1280873949-20460-1-git-send-email-mrubin@google.com>
	<20100804150422.c52b308e.akpm@linux-foundation.org>
From: Michael Rubin <mrubin@google.com>
Date: Wed, 4 Aug 2010 17:18:46 -0700
Message-ID: <AANLkTikXWJCde+rQ6W7v8N_HhT62p0wa50Ca+Xez4EoV@mail.gmail.com>
Subject: Re: [PATCH 0/2] Adding four writeback files in /proc/sys/vm
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, jack@suse.cz, david@fromorbit.com, hch@lst.de, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

On Wed, Aug 4, 2010 at 3:04 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> For pages_dirtied and pages_entered_writeback: it's hard to see how any
> reimplementation of writeback would have any problem implementing
> these, so OK.

>
> But dirty_threshold_kbytes and dirty_background_threshold_kbytes are
> closely tied to the implementation-of-the-day and so I don't think they
> should be presented in /proc.

OK I will resend patch without threshold and then look for the write
place in debugfs to put them in a subsequent patch.

Thanks,

mrubin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
