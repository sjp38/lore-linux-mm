Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f44.google.com (mail-lf0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 5055C6B0270
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 08:36:38 -0400 (EDT)
Received: by mail-lf0-f44.google.com with SMTP id c62so168384280lfc.1
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 05:36:38 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t19si13192444wme.63.2016.04.04.05.36.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Apr 2016 05:36:37 -0700 (PDT)
Subject: Re: [PATCH] mm/huge_memory: replace VM_NO_THP VM_BUG_ON with actual
 VMA check
References: <145961146490.28194.16019687861681349309.stgit@zurg>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <57025FD3.4060004@suse.cz>
Date: Mon, 4 Apr 2016 14:36:35 +0200
MIME-Version: 1.0
In-Reply-To: <145961146490.28194.16019687861681349309.stgit@zurg>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, stable <stable@vger.kernel.org>

On 04/02/2016 05:37 PM, Konstantin Khlebnikov wrote:
> Khugepaged detects own VMAs by checking vm_file and vm_ops but this
> way it cannot distinguish private /dev/zero mappings from other special
> mappings like /dev/hpet which has no vm_ops and popultes PTEs in mmap.
>
> This fixes false-positive VM_BUG_ON and prevents installing THP where
> they are not expected.
>
> Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Link: http://lkml.kernel.org/r/CACT4Y+ZmuZMV5CjSFOeXviwQdABAgT7T+StKfTqan9YDtgEi5g@mail.gmail.com
> Fixes: 78f11a255749 ("mm: thp: fix /dev/zero MAP_PRIVATE and vm_flags cleanups")
> Cc: stable <stable@vger.kernel.org>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
