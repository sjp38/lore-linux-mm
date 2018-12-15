Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2F9D48E0002
	for <linux-mm@kvack.org>; Sat, 15 Dec 2018 05:51:15 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id y85so3081926wmc.7
        for <linux-mm@kvack.org>; Sat, 15 Dec 2018 02:51:15 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id b1si4883554wrj.176.2018.12.15.02.51.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Dec 2018 02:51:13 -0800 (PST)
Date: Sat, 15 Dec 2018 11:51:12 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] fix page_count in ->iomap_migrate_page()
Message-ID: <20181215105112.GC1575@lst.de>
References: <1544766961-3492-1-git-send-email-openzhangj@gmail.com> <1618433.IpySj692Hd@blindfold>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1618433.IpySj692Hd@blindfold>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>
Cc: zhangjun <openzhangj@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, hch@lst.de, bfoster@redhat.com, Dave Chinner <david@fromorbit.com>, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, n-horiguchi@ah.jp.nec.com, mgorman@techsingularity.net, aarcange@redhat.com, willy@infradead.org, linux@dominikbrodowski.net, linux-mm@kvack.org, Gao Xiang <gaoxiang25@huawei.com>

FYI, for iomap we got a patch to just increment the page count when
setting the private data, and it finally got merged into mainline after
a while.

Not that it totally makes sense to me, but it is what it is.  It would
just be nice if set_page_private took care of it and we had a
clear_page_private to undo it, making the whole scheme at lot more
obvious.
