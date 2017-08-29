Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id DEEF66B02B4
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 14:55:22 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id w10so5772006oie.1
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 11:55:22 -0700 (PDT)
Received: from mail-io0-x22d.google.com (mail-io0-x22d.google.com. [2607:f8b0:4001:c06::22d])
        by mx.google.com with ESMTPS id x185si2745265oig.153.2017.08.29.11.55.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 11:55:22 -0700 (PDT)
Received: by mail-io0-x22d.google.com with SMTP id k22so24575640iod.2
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 11:55:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170829081453.GA10196@infradead.org>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
 <1503956111-36652-16-git-send-email-keescook@chromium.org> <20170829081453.GA10196@infradead.org>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 29 Aug 2017 11:55:20 -0700
Message-ID: <CAGXu5j+V-U4OTRoOoJNAQA30Em90j0FEUdd=Jt7UPxWUNxO0xg@mail.gmail.com>
Subject: Re: [PATCH v2 15/30] xfs: Define usercopy region in xfs_inode slab cache
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: LKML <linux-kernel@vger.kernel.org>, David Windsor <dave@nullcore.net>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Tue, Aug 29, 2017 at 1:14 AM, Christoph Hellwig <hch@infradead.org> wrote:
> One thing I've been wondering is wether we should actually just
> get rid of the online area.  Compared to reading an inode from
> disk a single additional kmalloc is negligible, and not having the
> inline data / extent list would allow us to reduce the inode size
> significantly.
>
> Kees/David:  how many of these patches are file systems with some
> sort of inline data?  Given that it's only about 30 patches declaring
> allocations either entirely valid for user copy or not might end up
> being nicer in many ways than these offsets.

9 filesystems use some form of inline data: xfs, vxfs, ufs, orangefs,
exofs, befs, jfs, ext2, and ext4. How much of each slab is whitelisted
varies by filesystem (e.g. ext2/4 uses i_data for other things, but
ufs and orangefs and have a dedicate field for symlink names).

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
