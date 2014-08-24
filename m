Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id A19F26B0035
	for <linux-mm@kvack.org>; Sat, 23 Aug 2014 20:55:19 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so17847692pde.10
        for <linux-mm@kvack.org>; Sat, 23 Aug 2014 17:55:19 -0700 (PDT)
Received: from mail-pa0-x249.google.com (mail-pa0-x249.google.com [2607:f8b0:400e:c03::249])
        by mx.google.com with ESMTPS id qf5si46619485pdb.178.2014.08.23.17.55.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 23 Aug 2014 17:55:18 -0700 (PDT)
Received: by mail-pa0-f73.google.com with SMTP id kx10so3249769pab.2
        for <linux-mm@kvack.org>; Sat, 23 Aug 2014 17:55:18 -0700 (PDT)
Date: Sat, 23 Aug 2014 20:55:17 -0400
From: Peter Feiner <pfeiner@google.com>
Subject: Re: [PATCH v2 1/3] mm: softdirty: enable write notifications on VMAs
 after VM_SOFTDIRTY cleared
Message-ID: <20140824005517.GB12184@google.com>
References: <1408571182-28750-1-git-send-email-pfeiner@google.com>
 <1408831921-10168-1-git-send-email-pfeiner@google.com>
 <1408831921-10168-2-git-send-email-pfeiner@google.com>
 <20140823230011.GA26483@node.dhcp.inet.fi>
 <20140823235058.GA27234@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140823235058.GA27234@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@parallels.com>, Jamie Liu <jamieliu@google.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>

On Sun, Aug 24, 2014 at 02:50:58AM +0300, Kirill A. Shutemov wrote:
> One more case to consider: mprotect() which doesn't trigger successful
> vma_merge() will not set VM_SOFTDIRTY and will not enable write-protect on
> the vma.
> 
> It's probably better to take VM_SOFTDIRTY into account in
> vma_wants_writenotify() and re-think logic in other corners.

Merge or not, write notifications get disabled! I'll fix this too :-)

Peter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
