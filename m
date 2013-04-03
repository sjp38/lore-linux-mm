Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 944F46B0005
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 16:03:22 -0400 (EDT)
Message-ID: <515C8AB1.7060003@redhat.com>
Date: Wed, 03 Apr 2013 16:01:53 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 3/3] hugetlbfs: add swap entry check in follow_hugetlb_page()
References: <1365014138-19589-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1365014138-19589-4-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1365014138-19589-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Michal Hocko <mhocko@suse.cz>, HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 04/03/2013 02:35 PM, Naoya Horiguchi wrote:
> With applying the previous patch "hugetlbfs: stop setting VM_DONTDUMP in
> initializing vma(VM_HUGETLB)" to reenable hugepage coredump, if a memory
> error happens on a hugepage and the affected processes try to access
> the error hugepage, we hit VM_BUG_ON(atomic_read(&page->_count) <= 0)
> in get_page().
>
> The reason for this bug is that coredump-related code doesn't recognise
> "hugepage hwpoison entry" with which a pmd entry is replaced when a memory
> error occurs on a hugepage.
> In other words, physical address information is stored in different bit layout
> between hugepage hwpoison entry and pmd entry, so follow_hugetlb_page()
> which is called in get_dump_page() returns a wrong page from a given address.
>
> We need to filter out only hwpoison hugepages to have data on healthy
> hugepages in coredump. So this patch makes follow_hugetlb_page() avoid
> trying to get page when a pmd is in swap entry like format.
>
> ChangeLog v3:
>   - add comment about using is_swap_pte()
>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Reviewed-by: Michal Hocko <mhocko@suse.cz>
> Acked-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> Cc: stable@vger.kernel.org

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
