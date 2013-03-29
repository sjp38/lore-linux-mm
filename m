Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 2C4B06B0002
	for <linux-mm@kvack.org>; Fri, 29 Mar 2013 12:59:30 -0400 (EDT)
Date: Fri, 29 Mar 2013 12:59:23 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1364576363-e7zsfoo6-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <51558480.7050900@openvz.org>
References: <1364485358-8745-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1364485358-8745-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <515477D4.1060206@openvz.org>
 <1364495358-2gnie765-mutt-n-horiguchi@ah.jp.nec.com>
 <515526EA.3090807@openvz.org>
 <51558480.7050900@openvz.org>
Subject: Re: [PATCH 1/2] hugetlbfs: stop setting VM_DONTDUMP in initializing
 vma(VM_HUGETLB)
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Mar 29, 2013 at 04:09:36PM +0400, Konstantin Khlebnikov wrote:
...
> hugetlb coredump filter also should be fixed in this way:
> 
> --- a/fs/binfmt_elf.c
> +++ b/fs/binfmt_elf.c
> @@ -1154,6 +1154,7 @@ static unsigned long vma_dump_size(struct vm_area_struct *vma,
>                         goto whole;
>                 if (!(vma->vm_flags & VM_SHARED) && FILTER(HUGETLB_PRIVATE))
>                         goto whole;
> +               return 0;
>         }

OK, I'll add it.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
