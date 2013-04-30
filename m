Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 28A336B0123
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 12:48:25 -0400 (EDT)
Date: Tue, 30 Apr 2013 17:48:14 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [RFC PATCH 3/9] mm: hugetlb: Copy general hugetlb code from
 x86 to mm.
Message-ID: <20130430164814.GK29766@arm.com>
References: <1367339448-21727-1-git-send-email-steve.capper@linaro.org>
 <1367339448-21727-4-git-send-email-steve.capper@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1367339448-21727-4-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <Will.Deacon@arm.com>

On Tue, Apr 30, 2013 at 05:30:42PM +0100, Steve Capper wrote:
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 41179b0..e1dc5ae 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
...
> +pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
> +{
> +	pgd_t *pgd;
> +	pud_t *pud;
> +	pmd_t *pmd = NULL;
> +
> +	pgd = pgd_offset(mm, addr);
> +	if (pgd_present(*pgd)) {
> +		pud = pud_offset(pgd, addr);
> +		if (pud_present(*pud)) {
> +			if (pud_large(*pud))

That's more of a question for the x86 guys - can we replace pud_large()
here with pud_huge()? It looks like the former simply checks for present
and huge, so pud_huge() would be enough. This saves an additional
definition.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
