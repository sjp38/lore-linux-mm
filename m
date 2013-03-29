Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 8DE236B0002
	for <linux-mm@kvack.org>; Fri, 29 Mar 2013 09:57:32 -0400 (EDT)
Date: Fri, 29 Mar 2013 14:57:30 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] hugetlbfs: add swap entry check in
 follow_hugetlb_page()
Message-ID: <20130329135730.GB21879@dhcp22.suse.cz>
References: <1364485358-8745-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1364485358-8745-3-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1364485358-8745-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, stable@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 28-03-13 11:42:38, Naoya Horiguchi wrote:
[...]
> @@ -2968,7 +2968,8 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  		 * first, for the page indexing below to work.
>  		 */
>  		pte = huge_pte_offset(mm, vaddr & huge_page_mask(h));
> -		absent = !pte || huge_pte_none(huge_ptep_get(pte));
> +		absent = !pte || huge_pte_none(huge_ptep_get(pte)) ||
> +			is_swap_pte(huge_ptep_get(pte));

is_swap_pte doesn't seem right. Shouldn't you use is_hugetlb_entry_hwpoisoned
instead?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
