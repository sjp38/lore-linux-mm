Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 009936B0005
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 19:52:17 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id 128-v6so3089708ybd.21
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 16:52:16 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id p124-v6si501665ywc.104.2018.07.03.16.52.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 03 Jul 2018 16:52:15 -0700 (PDT)
Date: Tue, 3 Jul 2018 19:43:31 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH 1/2] fs: ext4: use BUG_ON if writepage call comes from
 direct reclaim
Message-ID: <20180703234331.GA5104@thunk.org>
References: <1530591079-33813-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180703103948.GB27426@thunk.org>
 <6c305241-d502-b8ea-a187-54c33e4ca692@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6c305241-d502-b8ea-a187-54c33e4ca692@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mgorman@techsingularity.net, adilger.kernel@dilger.ca, darrick.wong@oracle.com, dchinner@redhat.com, akpm@linux-foundation.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jul 03, 2018 at 10:05:04AM -0700, Yang Shi wrote:
> I'm not sure if it is a good choice to let filesystem handle such vital VM
> regression. IMHO, writing out filesystem page from direct reclaim context is
> a vital VM bug. It means something is definitely wrong in VM. It should
> never happen.

If it does happen, it should happen reliably; this isn't the sort of
thing where some linked list had gotten corrupted.  This would be a
structural problem in the VM code.

So presumably, if the WARN_ON triggered, it should be be noticed by VM
developers, and they should fix it.

In general, though, BUG_ON's should be avoided unless there really is
no way to recover.

> It sounds ok to have filesystem throw out warning and handle it, but I'm not
> sure if someone will just ignore the warning, but it should *never* be
> ignored.

If a kernel develper (a VM developer in this case) ignores a warning,
that's just simply professional malpractice.  In general WARN_ON's
should only be used as a sign of a kernel bug.  So they should never
be ignored.

						- Ted
