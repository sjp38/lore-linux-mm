Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2B1756B0292
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 15:33:00 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id w84so4161723vkd.6
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 12:33:00 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id i12si2855564uaf.291.2017.08.30.12.32.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 12:32:59 -0700 (PDT)
Subject: Re: [PATCH 11/13] xen/gntdev: update to new mmu_notifier semantic
References: <20170829235447.10050-1-jglisse@redhat.com>
 <20170829235447.10050-12-jglisse@redhat.com>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Message-ID: <df815f86-aaa2-e82c-5c17-fed3632194b7@oracle.com>
Date: Wed, 30 Aug 2017 15:32:47 -0400
MIME-Version: 1.0
In-Reply-To: <20170829235447.10050-12-jglisse@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, =?UTF-8?Q?Roger_Pau_Monn=c3=a9?= <roger.pau@citrix.com>, xen-devel@lists.xenproject.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>

On 08/29/2017 07:54 PM, JA(C)rA'me Glisse wrote:
> Call to mmu_notifier_invalidate_page() are replaced by call to
> mmu_notifier_invalidate_range() and thus call are bracketed by
> call to mmu_notifier_invalidate_range_start()/end()
>
> Remove now useless invalidate_page callback.
>
> Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
> Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Cc: Roger Pau MonnA(C) <roger.pau@citrix.com>
> Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> Cc: xen-devel@lists.xenproject.org
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  drivers/xen/gntdev.c | 8 --------
>  1 file changed, 8 deletions(-)

Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>

I also ran a bunch of tests (mostly bringing up/tearing down various Xen
guests). Haven't seen any issues.

-boris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
