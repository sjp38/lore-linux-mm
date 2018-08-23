Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id E96EA6B2773
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 21:50:49 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id v129-v6so1522417vke.16
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 18:50:49 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q194-v6sor443357vkf.301.2018.08.22.18.50.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Aug 2018 18:50:49 -0700 (PDT)
MIME-Version: 1.0
From: Luigi Semenzato <semenzato@google.com>
Date: Wed, 22 Aug 2018 18:50:36 -0700
Message-ID: <CAA25o9QLMuDSL6L3+7KQO=NrtohB=dgvLgsusLTy5-qsAK6Org@mail.gmail.com>
Subject: measuring reclaim overhead without NR_PAGES_SCANNED
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>

My apologies for not noticing this earlier, but we're often working
with older kernels.

On May 3, 2017 this patch was merged:

commit c822f6223d03c2c5b026a21da09c6b6d523258cd
Author:     Johannes Weiner <hannes@cmpxchg.org>
AuthorDate: Wed May 3 14:52:10 2017 -0700
Commit:     Linus Torvalds <torvalds@linux-foundation.org>
CommitDate: Wed May 3 15:52:08 2017 -0700

    mm: delete NR_PAGES_SCANNED and pgdat_reclaimable()

I was planning to use this number as a measure of how much work the
kernel was doing trying to reclaim pages (by comparing it, for
instance, to the number of pages actually swapped in).  I am not even
sure how good a metric this would be.  Does anybody have suggestions
for a good (or better) replacement?

Thanks!
