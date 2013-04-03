Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 98B8A6B0006
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 15:21:40 -0400 (EDT)
Message-ID: <515C80EB.8070801@redhat.com>
Date: Wed, 03 Apr 2013 15:20:11 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 1/3] hugetlbfs: stop setting VM_DONTDUMP in initializing
 vma(VM_HUGETLB)
References: <1365014138-19589-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1365014138-19589-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1365014138-19589-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Michal Hocko <mhocko@suse.cz>, HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 04/03/2013 02:35 PM, Naoya Horiguchi wrote:
> Currently we fail to include any data on hugepages into coredump,
> because VM_DONTDUMP is set on hugetlbfs's vma. This behavior was recently
> introduced by commit 314e51b98 "mm: kill vma flag VM_RESERVED and
> mm->reserved_vm counter". This looks to me a serious regression,
> so let's fix it.
>
> ChangeLog v3:
>   - move 'return 0' into a separate patch
>
> ChangeLog v2:
>   - add 'return 0' in hugepage memory check
>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Acked-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> Acked-by: Michal Hocko <mhocko@suse.cz>
> Cc: stable@vger.kernel.org

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
