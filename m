Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id CC66B6B0006
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 17:49:09 -0400 (EDT)
Received: by mail-da0-f52.google.com with SMTP id f10so387398dak.25
        for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:49:09 -0700 (PDT)
Date: Wed, 10 Apr 2013 14:49:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RESEND][PATCH v5 2/3] fix hugetlb memory check in
 vma_dump_size()
In-Reply-To: <1365610669-16625-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.DEB.2.02.1304101448390.1526@chino.kir.corp.google.com>
References: <1365610669-16625-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1365610669-16625-3-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Michal Hocko <mhocko@suse.cz>, HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 10 Apr 2013, Naoya Horiguchi wrote:

> Documentation/filesystems/proc.txt says about coredump_filter bitmask,
> 
>   Note bit 0-4 doesn't effect any hugetlb memory. hugetlb memory are only
>   effected by bit 5-6.
> 
> However current code can go into the subsequent flag checks of bit 0-4
> for vma(VM_HUGETLB). So this patch inserts 'return' and makes it work
> as written in the document.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Acked-by: Michal Hocko <mhocko@suse.cz>
> Reviewed-by: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: stable@vger.kernel.org

Acked-by: David Rientjes <rientjes@google.com>

Stable for 2.6.34+.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
