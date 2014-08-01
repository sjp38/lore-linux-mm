Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8A6136B0035
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 03:02:00 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id mc6so2958712lab.34
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 00:01:59 -0700 (PDT)
Received: from mail-la0-x22b.google.com (mail-la0-x22b.google.com [2a00:1450:4010:c03::22b])
        by mx.google.com with ESMTPS id kr1si12124288lac.15.2014.08.01.00.01.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 01 Aug 2014 00:01:58 -0700 (PDT)
Received: by mail-la0-f43.google.com with SMTP id hr17so2924632lab.30
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 00:01:58 -0700 (PDT)
Date: Fri, 1 Aug 2014 11:01:56 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm: softdirty: respect VM_SOFTDIRTY in PTE holes
Message-ID: <20140801070156.GE17343@moon>
References: <1406846605-12176-1-git-send-email-pfeiner@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1406846605-12176-1-git-send-email-pfeiner@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Feiner <pfeiner@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Jul 31, 2014 at 06:43:25PM -0400, Peter Feiner wrote:
> After a VMA is created with the VM_SOFTDIRTY flag set,
> /proc/pid/pagemap should report that the VMA's virtual pages are
> soft-dirty until VM_SOFTDIRTY is cleared (i.e., by the next write of
> "4" to /proc/pid/clear_refs). However, pagemap ignores the
> VM_SOFTDIRTY flag for virtual addresses that fall in PTE holes (i.e.,
> virtual addresses that don't have a PMD, PUD, or PGD allocated yet).
> 
> To observe this bug, use mmap to create a VMA large enough such that
> there's a good chance that the VMA will occupy an unused PMD, then
> test the soft-dirty bit on its pages. In practice, I found that a VMA
> that covered a PMD's worth of address space was big enough.
> 
> This patch adds the necessary VMA lookup to the PTE hole callback in
> /proc/pid/pagemap's page walk and sets soft-dirty according to the
> VMAs' VM_SOFTDIRTY flag.
> 
> Signed-off-by: Peter Feiner <pfeiner@google.com>
Acked-by: Cyrill Gorcunov <gorcunov@openvz.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
