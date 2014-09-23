Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id B78DE6B0035
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 10:28:58 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id z2so7382039wiv.11
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 07:28:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d6si7025846wix.107.2014.09.24.07.28.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Sep 2014 07:28:55 -0700 (PDT)
Date: Tue, 23 Sep 2014 16:20:02 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: mmotm 2014-09-22-16-57 uploaded
Message-ID: <20140923202002.GA22362@nhori>
References: <5420b8b0.9HdYLyyuTikszzH8%akpm@linux-foundation.org>
 <20140923190222.GA4662@roeck-us.net>
 <20140923130128.79f5931ac03dbb31f53be805@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140923130128.79f5931ac03dbb31f53be805@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Guenter Roeck <linux@roeck-us.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz, Sasha Levin <sasha.levin@oracle.com>, Anish Bhatt <anish@chelsio.com>, David Miller <davem@davemloft.net>, Fabio Estevam <fabio.estevam@freescale.com>

On Tue, Sep 23, 2014 at 01:01:28PM -0700, Andrew Morton wrote:
> On Tue, 23 Sep 2014 12:02:22 -0700 Guenter Roeck <linux@roeck-us.net> wrote:
...
> > 
> > arch/powerpc/mm/hugetlbpage.c:710:1: error: conflicting types for 'follow_huge_pud'
> >  follow_huge_pud(struct mm_struct *mm, unsigned long address,
> >   ^
> > In file included from arch/powerpc/mm/hugetlbpage.c:14:0: include/linux/hugetlb.h:103:14:
> > 	note: previous declaration of 'follow_huge_pud' was here
> >    struct page *follow_huge_pud(struct mm_struct *mm, unsigned long address,
>                  ^
> 
> Naoya, please check:
> 
> --- a/arch/powerpc/mm/hugetlbpage.c~mm-hugetlb-reduce-arch-dependent-code-around-follow_huge_-fix
> +++ a/arch/powerpc/mm/hugetlbpage.c
> @@ -708,7 +708,7 @@ follow_huge_pmd(struct mm_struct *mm, un
>  
>  struct page *
>  follow_huge_pud(struct mm_struct *mm, unsigned long address,
> -		pmd_t *pmd, int write)
> +		pud_t *pud, int write)
>  {
>  	BUG();
>  	return NULL;
> _

Yes, this is a right fix. Thanks.

Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
