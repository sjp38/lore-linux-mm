Subject: Re: [ckrm-tech] [PATCH 2/6] CKRM: Core framework support
In-Reply-To: Your message of "Fri, 24 Jun 2005 15:22:44 -0700"
	<1119651764.5105.16.camel@linuxchandra>
References: <1119651764.5105.16.camel@linuxchandra>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Date: Sat, 25 Jun 2005 16:49:26 +0900
Message-Id: <1119685766.986231.2373.nullmailer@yamt.dyndns.org>
From: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: sekharan@us.ibm.com
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> +static inline int
> +class_migrate_pgd(struct mm_struct* mm, struct vm_area_struct* vma,
> +		pgd_t* pgdir, unsigned long address, unsigned long end)
> +{
> +	pmd_t* pmd;
> +	pud_t* pud;
> +	unsigned long pgd_end;
> +
> +	if (pgd_none(*pgdir))
> +		return 0;
> +	BUG_ON(pgd_bad(*pgdir));
> +
> +	pud = pud_offset(pgdir, address);
> +	if (pud_none(*pud))
> +		return 0;
> +	BUG_ON(pud_bad(*pud));
> +	pmd = pmd_offset(pud, address);
> +	pgd_end = (address + PGDIR_SIZE) & PGDIR_MASK;

why didn't you introduce class_migrate_pud?

YAMAMOTO Takashi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
