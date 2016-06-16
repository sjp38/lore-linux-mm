Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A84826B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 05:32:46 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e189so94171981pfa.2
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 02:32:46 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id x19si5113489pfi.191.2016.06.16.02.32.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 02:32:36 -0700 (PDT)
Date: Thu, 16 Jun 2016 02:32:35 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Revert "mm: rename _count, field of the struct page, to
 _refcount"
Message-ID: <20160616093235.GA14640@infradead.org>
References: <1466068966-24620-1-git-send-email-vkuznets@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1466068966-24620-1-git-send-email-vkuznets@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: linux-mm@kvack.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>

On Thu, Jun 16, 2016 at 11:22:46AM +0200, Vitaly Kuznetsov wrote:
> _count -> _refcount rename in commit 0139aa7b7fa12 ("mm: rename _count,
> field of the struct page, to _refcount") broke kdump. makedumpfile(8) does
> stuff like READ_MEMBER_OFFSET("page._count", page._count) and fails. While
> it is definitely possible to fix this particular tool I'm not sure about
> other tools which might be doing the same.
> 
> I suggest we remember the "we don't break userspace" rule and revert for
> 4.7 while it's not too late.

Err, sorry - this is not "userspace".  It's crazy crap digging into
kernel internal structure.

The rename was absolutely useful, so fix up your stinking pike in kdump.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
