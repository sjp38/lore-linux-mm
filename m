Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B19A56B0253
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 16:44:55 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 204so167860894pge.5
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 13:44:55 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y96si5209729plh.249.2017.02.07.13.44.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 13:44:55 -0800 (PST)
Date: Tue, 7 Feb 2017 13:44:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mprotect: drop overprotective lock_pte_protection()
Message-Id: <20170207134454.7af755ae379ca9d016b5c15a@linux-foundation.org>
In-Reply-To: <20170207143347.123871-1-kirill.shutemov@linux.intel.com>
References: <20170207143347.123871-1-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue,  7 Feb 2017 17:33:47 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> lock_pte_protection() uses pmd_lock() to make sure that we have stable
> PTE page table before walking pte range.
> 
> That's not necessary. We only need to make sure that PTE page table is
> established. It cannot vanish under us as long as we hold mmap_sem at
> least for read.
> 
> And we already have helper for that -- pmd_trans_unstable().

http://ozlabs.org/~akpm/mmots/broken-out/mm-mprotect-use-pmd_trans_unstable-instead-of-taking-the-pmd_lock.patch
already did this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
