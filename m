Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 91D9A6B02A5
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 05:04:46 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id x2-v6so11042641pgr.8
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 02:04:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v90-v6sor27078522pfd.49.2018.10.31.02.04.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Oct 2018 02:04:45 -0700 (PDT)
Date: Wed, 31 Oct 2018 12:04:39 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 2/3] mm: add mm_pxd_folded checks to pgtable_bytes
 accounting functions
Message-ID: <20181031090439.5uhyk74g2e3j6lm3@kshutemo-mobl1>
References: <1539621759-5967-1-git-send-email-schwidefsky@de.ibm.com>
 <1539621759-5967-3-git-send-email-schwidefsky@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1539621759-5967-3-git-send-email-schwidefsky@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Li Wang <liwang@redhat.com>, Guenter Roeck <linux@roeck-us.net>, Janosch Frank <frankja@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Mon, Oct 15, 2018 at 06:42:38PM +0200, Martin Schwidefsky wrote:
> The common mm code calls mm_dec_nr_pmds() and mm_dec_nr_puds()
> in free_pgtables() if the address range spans a full pud or pmd.
> If mm_dec_nr_puds/mm_dec_nr_pmds are non-empty due to configuration
> settings they blindly subtract the size of the pmd or pud table from
> pgtable_bytes even if the pud or pmd page table layer is folded.
> 
> Add explicit mm_[pmd|pud]_folded checks to the four pgtable_bytes
> accounting functions mm_inc_nr_puds, mm_inc_nr_pmds, mm_dec_nr_puds
> and mm_dec_nr_pmds. As the check for folded page tables can be
> overwritten by the architecture, this allows to keep a correct
> pgtable_bytes value for platforms that use a dynamic number of
> page table levels.
> 
> Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>

Looks fine to me.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov
