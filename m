Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 75BFA6B0033
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 01:24:32 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id u74so315517lff.14
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 22:24:32 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y2sor135483lfd.90.2017.12.12.22.24.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Dec 2017 22:24:30 -0800 (PST)
MIME-Version: 1.0
From: Byungchul Park <max.byungchul.park@gmail.com>
Date: Wed, 13 Dec 2017 15:24:29 +0900
Message-ID: <CANrsvRPQcWz-p_3TYfNf+Waek3bcNNPniXhFzyyS=7qbCqzGyg@mail.gmail.com>
Subject: About the try to remove cross-release feature entirely by Ingo
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, david@fromorbit.com, tytso@mit.edu, willy@infradead.org, Linus Torvalds <torvalds@linux-foundation.org>, Amir Goldstein <amir73il@gmail.com>, byungchul.park@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, oleg@redhat.com

Lockdep works, based on the following:

   (1) Classifying locks properly
   (2) Checking relationship between the classes

If (1) is not good or (2) is not good, then we
might get false positives.

For (1), we don't have to classify locks 100%
properly but need as enough as lockdep works.

For (2), we should have a mechanism w/o
logical defects.

Cross-release added an additional capacity to
(2) and requires (1) to get more precisely classified.

Since the current classification level is too low for
cross-release to work, false positives are being
reported frequently with enabling cross-release.
Yes. It's a obvious problem. It needs to be off by
default until the classification is done by the level
that cross-release requires.

But, the logic (2) is valid and logically true. Please
keep the code, mechanism, and logic.

-- 
Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
