Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id B7F00280300
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 18:26:01 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id t124so6437685oih.11
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 15:26:01 -0700 (PDT)
Received: from mail-io0-x236.google.com (mail-io0-x236.google.com. [2607:f8b0:4001:c06::236])
        by mx.google.com with ESMTPS id x123si3042129oix.455.2017.08.29.15.26.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 15:26:00 -0700 (PDT)
Received: by mail-io0-x236.google.com with SMTP id g33so22139855ioj.3
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 15:26:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170829221522.GE10621@dastard>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
 <1503956111-36652-16-git-send-email-keescook@chromium.org>
 <20170828214957.GJ4757@magnolia> <CAGXu5j+pvxRjASUuBE49+uH34Mw26a4mtcWrZd=CEqcRHjetvA@mail.gmail.com>
 <20170829044707.GP4757@magnolia> <CAGXu5jJX1DA9D1LtrKkNoBXKZEYhbSE148YmUOP=WXsBCFsCyw@mail.gmail.com>
 <20170829221522.GE10621@dastard>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 29 Aug 2017 15:25:59 -0700
Message-ID: <CAGXu5jLh5XKpD3FtJ9Ft25MGziE83f3v7qcRPunh7PWY52YPmA@mail.gmail.com>
Subject: Re: [PATCH v2 15/30] xfs: Define usercopy region in xfs_inode slab cache
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, LKML <linux-kernel@vger.kernel.org>, David Windsor <dave@nullcore.net>, linux-xfs@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Tue, Aug 29, 2017 at 3:15 PM, Dave Chinner <david@fromorbit.com> wrote:
> If you are touching multiple filesystems, you really should cc the
> entire patchset to linux-fsdevel, similar to how you sent the entire
> patchset to lkml. That way the entire series will end up on a list
> that almost all fs developers read. LKML is not a list you can rely
> on all filesystem developers reading (or developers in any other
> subsystem, for that matter)...

Okay, sounds good. Thanks!

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
