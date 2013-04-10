Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id B66916B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 17:46:09 -0400 (EDT)
Received: by mail-da0-f42.google.com with SMTP id n15so385696dad.29
        for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:46:08 -0700 (PDT)
Date: Wed, 10 Apr 2013 14:46:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RESEND][PATCH v5 1/3] hugetlbfs: stop setting VM_DONTDUMP in
 initializing vma(VM_HUGETLB)
In-Reply-To: <1365610669-16625-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.DEB.2.02.1304101445520.1526@chino.kir.corp.google.com>
References: <1365610669-16625-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1365610669-16625-2-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Michal Hocko <mhocko@suse.cz>, HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 10 Apr 2013, Naoya Horiguchi wrote:

> Currently we fail to include any data on hugepages into coredump,
> because VM_DONTDUMP is set on hugetlbfs's vma. This behavior was recently
> introduced by commit 314e51b98 "mm: kill vma flag VM_RESERVED and
> mm->reserved_vm counter". This looks to me a serious regression,
> so let's fix it.
> 
> ChangeLog v3:
>  - move 'return 0' into a separate patch
> 
> ChangeLog v2:
>  - add 'return 0' in hugepage memory check
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Acked-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> Acked-by: Michal Hocko <mhocko@suse.cz>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: stable@vger.kernel.org

Acked-by: David Rientjes <rientjes@google.com>

Stable for 3.7+.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
