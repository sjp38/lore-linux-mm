Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id E88BE6B0009
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 05:22:29 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id g62so62237064wme.0
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 02:22:29 -0800 (PST)
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com. [195.75.94.103])
        by mx.google.com with ESMTPS id z65si11914454wmb.85.2016.02.11.02.22.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 Feb 2016 02:22:28 -0800 (PST)
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Thu, 11 Feb 2016 10:22:27 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 41A072190019
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 10:22:11 +0000 (GMT)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1BAMPlG18284656
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 10:22:25 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1BAMOVa021087
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 03:22:25 -0700
Date: Thu, 11 Feb 2016 11:22:23 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH 1/2] mm,thp: refactor generic deposit/withdraw routines
 for wider usage
Message-ID: <20160211112223.0acc8237@mschwide>
In-Reply-To: <1455182907-15445-2-git-send-email-vgupta@synopsys.com>
References: <1455182907-15445-1-git-send-email-vgupta@synopsys.com>
	<1455182907-15445-2-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "David S. Miller" <davem@davemloft.net>, Alex Thorlton <athorlton@sgi.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>

On Thu, 11 Feb 2016 14:58:26 +0530
Vineet Gupta <Vineet.Gupta1@synopsys.com> wrote:

> Generic pgtable_trans_huge_deposit()/pgtable_trans_huge_withdraw()
> assume pgtable_t to be struct page * which is not true for all arches.
> Thus arc, s390, sparch end up with their own copies despite no special
> hardware requirements (unlike powerpc).

s390 does have a special hardware requirement. pgtable_t is an address
for a 2K block of memory. It is *not* equivalent to a struct page *
which refers to a 4K block of memory. That has been the whole point
to introduce pgtable_t.

> It seems massaging the code a bit can make it reusbale.

Imho the new code for asm-generic looks fine, as long as the override
with __HAVE_ARCH_PGTABLE_DEPOSIT/__HAVE_ARCH_PGTABLE_WITHDRAW continues
to work I do not mind.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
