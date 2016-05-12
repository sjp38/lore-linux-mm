Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2E3606B0005
	for <linux-mm@kvack.org>; Thu, 12 May 2016 07:49:53 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id gw7so102420001pac.0
        for <linux-mm@kvack.org>; Thu, 12 May 2016 04:49:53 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id c68si17056030pfd.116.2016.05.12.04.49.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 May 2016 04:49:52 -0700 (PDT)
Date: Thu, 12 May 2016 04:49:48 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: UBIFS and page migration (take 3)
Message-ID: <20160512114948.GA25113@infradead.org>
References: <1462974823-3168-1-git-send-email-richard@nod.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462974823-3168-1-git-send-email-richard@nod.at>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>
Cc: linux-fsdevel@vger.kernel.org, linux-mtd@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, boris.brezillon@free-electrons.com, maxime.ripard@free-electrons.com, david@sigma-star.at, david@fromorbit.com, dedekind1@gmail.com, alex@nextthing.co, akpm@linux-foundation.org, sasha.levin@oracle.com, iamjoonsoo.kim@lge.com, rvaswani@codeaurora.org, tony.luck@intel.com, shailendra.capricorn@gmail.com, kirill.shutemov@linux.intel.com, hch@infradead.org, hughd@google.com, mgorman@techsingularity.net, vbabka@suse.cz

Hi Richard,

the series looks fine to me, but it fails to address the root cause:
that we have an inherently dangerous default for ->migratepage that
assumes that file systems are implemented a certain way.  I think the
series should also grow a third patch to remove the default and just
wire it up for the known good file systems, although we'd need some
input on what known good is.

Any idea what filesystems do get regular testing with code that's using
CMA? A good approximation might be those that use the bufer_head
based aops from fs/buffer.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
