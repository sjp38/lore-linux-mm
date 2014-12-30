Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id B2FF86B0038
	for <linux-mm@kvack.org>; Tue, 30 Dec 2014 15:51:32 -0500 (EST)
Received: by mail-qa0-f54.google.com with SMTP id i13so8705932qae.27
        for <linux-mm@kvack.org>; Tue, 30 Dec 2014 12:51:32 -0800 (PST)
Received: from mail-qa0-x22a.google.com (mail-qa0-x22a.google.com. [2607:f8b0:400d:c00::22a])
        by mx.google.com with ESMTPS id t4si44678075qar.11.2014.12.30.12.51.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 30 Dec 2014 12:51:31 -0800 (PST)
Received: by mail-qa0-f42.google.com with SMTP id n8so10786902qaq.29
        for <linux-mm@kvack.org>; Tue, 30 Dec 2014 12:51:31 -0800 (PST)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <1417567367-9298-1-git-send-email-mgorman@suse.de>
References: <1417567367-9298-1-git-send-email-mgorman@suse.de>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Tue, 30 Dec 2014 21:51:11 +0100
Message-ID: <CAKgNAkgX8z=hZofSqkAb9VA_9mMBbRBDHdkX9NUentHSP4Lkog@mail.gmail.com>
Subject: Re: [PATCH 0/2] Improve documentation of FADV_DONTNEED behaviour
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 3, 2014 at 1:42 AM, Mel Gorman <mgorman@suse.de> wrote:
> Partial page discard requests are ignored and the documentation on why this
> is correct behaviour sucks. A readahead patch looked like a "regression" to
> a random IO storage benchmark because posix_fadvise() was used incorrectly
> to force IO requests to go to disk. In reality, the benchmark sucked but
> it was non-obvious why. Patch 1 updates the kernel comment in case someone
> "fixes" either readahead or fadvise for inappropriate reasons. Patch 2
> updates the relevant man page on the rough off chance that application
> developers do not read kernel source comments.

It feels like that last sentence should have made LWN quote of the week :-/.

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
