Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 35E2B6B0002
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 08:56:33 -0400 (EDT)
Date: Thu, 21 Mar 2013 13:56:28 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC][PATCH 0/9] extend hugepage migration
Message-ID: <20130321125628.GB6051@dhcp22.suse.cz>
References: <1361475708-25991-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <5148F830.3070601@gmail.com>
 <1363815326-urchkyxr-mutt-n-horiguchi@ah.jp.nec.com>
 <514A4B1C.6020201@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <514A4B1C.6020201@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org

On Thu 21-03-13 07:49:48, Simon Jeons wrote:
[...]
> When I hacking arch/x86/mm/hugetlbpage.c like this,
> diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
> index ae1aa71..87f34ee 100644
> --- a/arch/x86/mm/hugetlbpage.c
> +++ b/arch/x86/mm/hugetlbpage.c
> @@ -354,14 +354,13 @@ hugetlb_get_unmapped_area(struct file *file,
> unsigned long addr,
> 
> #endif /*HAVE_ARCH_HUGETLB_UNMAPPED_AREA*/
> 
> -#ifdef CONFIG_X86_64
> static __init int setup_hugepagesz(char *opt)
> {
> unsigned long ps = memparse(opt, &opt);
> if (ps == PMD_SIZE) {
> hugetlb_add_hstate(PMD_SHIFT - PAGE_SHIFT);
> - } else if (ps == PUD_SIZE && cpu_has_gbpages) {
> - hugetlb_add_hstate(PUD_SHIFT - PAGE_SHIFT);
> + } else if (ps == PUD_SIZE) {
> + hugetlb_add_hstate(PMD_SHIFT - PAGE_SHIFT+4);
> } else {
> printk(KERN_ERR "hugepagesz: Unsupported page size %lu M\n",
> ps >> 20);
> 
> I set boot=hugepagesz=1G hugepages=10, then I got 10 32MB huge pages.
> What's the difference between these pages which I hacking and normal
> huge pages?

How is this related to the patch set?
Please _stop_ distracting discussion to unrelated topics!

Nothing personal but this is just wasting our time.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
