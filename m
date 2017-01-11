Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 286436B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 05:29:31 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id 3so993699740oih.5
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 02:29:31 -0800 (PST)
Received: from mail-oi0-x22e.google.com (mail-oi0-x22e.google.com. [2607:f8b0:4003:c06::22e])
        by mx.google.com with ESMTPS id l55si2112432ote.46.2017.01.11.02.29.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 02:29:29 -0800 (PST)
Received: by mail-oi0-x22e.google.com with SMTP id u143so172490345oif.3
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 02:29:29 -0800 (PST)
MIME-Version: 1.0
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 11 Jan 2017 11:29:28 +0100
Message-ID: <CAJfpegv9EhT4Y3QjTZBHoMKSiVGtfmTGPhJp_rh3a7=rFCHu5A@mail.gmail.com>
Subject: [LSF/MM TOPIC] sharing pages between mappings
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org, lsf-pc@lists.linux-foundation.org

I know there's work on this for xfs, but could this be done in generic mm code?

What are the obstacles?  page->mapping and page->index are the obvious ones.

If that's too difficult is it maybe enough to share mappings between
files while they are completely identical and clone the mapping when
necessary?

All COW filesystems would benefit, as well as layered ones: lots of
fuse fs, and in some cases overlayfs too.

Related:  what can DAX do in the presence of cloned block?

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
