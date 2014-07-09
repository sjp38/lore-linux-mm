Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0E7D66B0036
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 04:55:16 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id hz1so8791967pad.24
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 01:55:16 -0700 (PDT)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id bt6si45515232pad.186.2014.07.09.01.55.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Jul 2014 01:55:15 -0700 (PDT)
Received: by mail-pd0-f173.google.com with SMTP id r10so8655809pdi.18
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 01:55:15 -0700 (PDT)
Date: Wed, 9 Jul 2014 01:53:36 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v3 0/7] File Sealing & memfd_create()
In-Reply-To: <CANq1E4QZ95RmJ7i=6TzEP4e+WREzKtXmmjjDrvz4BgAhVHoeuQ@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1407090136580.7841@eggly.anvils>
References: <1402655819-14325-1-git-send-email-dh.herrmann@gmail.com> <CANq1E4QZ95RmJ7i=6TzEP4e+WREzKtXmmjjDrvz4BgAhVHoeuQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, John Stultz <john.stultz@linaro.org>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, Tony Battersby <tonyb@cybernetics.com>, Andy Lutomirski <luto@amacapital.net>

On Tue, 8 Jul 2014, David Herrmann wrote:
> 
> Hugh, any comments on patch 5, 6 and 7? Those are the last outstanding
> issues with memfd+sealing. Patch 7 (isolating pages) is still my
> favorite and has been running just fine on my machine for the last
> months. I think it'd be nice if we could give it a try in -next. We
> can always fall back to Patch 5 or Patch 5+6. Those will detect any
> racing AIO and just fail or wait for the IO to finish for a short
> period.

It's distressing for both of us how slow I am to review these, sorry.
We have just too many bugs in mm (and yes, some of them mine) for me
to set aside time to get deep enough into new features.

I've been trying for days and weeks to get there, made some progress
today, and hope to continue tomorrow.  I'll send my comments on 1/7
(thumb up) and 7/7 (thumb down) in a moment: 2-6 not tonight.

> 
> Are there any other blockers for this?

Trivia only, I haven't noticed any blocker; though I'm still not quite
convinced by memfd_create() - but happy enough with it if others are.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
