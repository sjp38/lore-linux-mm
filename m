Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 313FB6B0032
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 02:54:21 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id eu11so22722026pac.11
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 23:54:20 -0800 (PST)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id r11si4476485pdl.210.2015.01.15.23.54.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 Jan 2015 23:54:19 -0800 (PST)
Received: by mail-pa0-f54.google.com with SMTP id fb1so22765931pad.13
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 23:54:18 -0800 (PST)
Date: Thu, 15 Jan 2015 23:54:09 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [LSF/MM ATTEND] Transparent huge pages: huge tmpfs
Message-ID: <alpine.LSU.2.11.1501152301470.7987@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

I would like to attend LSF/MM this year; and most of all would like
to join Kirill Shutemov in his discussion of THP refcounting etc.

I admit that I have not yet studied his refcounting patchset, but
shall have done so by March.  I've been fully occupied these last
few months with an alternative approach to THPage cache, huge tmpfs:
starting from my belief that compound pages were ideal for hugetlbfs,
questionable for anonymous THP, completely unsuited to THPage cache.

We shall try to work out how much we have in common, and where to go
from there.

Huge tmpfs is currently implemented on Google's not-so-modern kernel.
I intend to port it to v3.19 and post before LSF; but if that ends up
like a night-before-the-conference dump of XXX patches, no, I'll spare
you and spend more time looking at other people's work instead.

I haven't checked through the other topic proposals yet: but once I'm
uprooted and there at the conference, expect to be able to engage with
them.  As before, I'd really like to spend some time in the FS room,
but shall find it hard to detach from MM.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
