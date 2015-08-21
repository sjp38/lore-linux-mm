Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id CCE6E6B0254
	for <linux-mm@kvack.org>; Fri, 21 Aug 2015 02:33:04 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so7439547wic.1
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 23:33:04 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com. [209.85.212.179])
        by mx.google.com with ESMTPS id y9si2534344wix.106.2015.08.20.23.33.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Aug 2015 23:33:03 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so10875711wic.1
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 23:33:03 -0700 (PDT)
Date: Fri, 21 Aug 2015 08:33:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5 1/2] mm: hugetlb: proc: add HugetlbPages field to
 /proc/PID/smaps
Message-ID: <20150821063301.GC23723@dhcp22.suse.cz>
References: <20150812000336.GB32192@hori1.linux.bs1.fc.nec.co.jp>
 <1440059182-19798-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1440059182-19798-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20150820104929.GA4632@dhcp22.suse.cz>
 <20150820232011.GA10807@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150820232011.GA10807@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu 20-08-15 23:20:12, Naoya Horiguchi wrote:
[...]
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Date: Fri, 21 Aug 2015 08:13:31 +0900
> Subject: [PATCH] Documentation/filesystems/proc.txt: give additional comment
>  about hugetlb usage
> 
> ---
>  Documentation/filesystems/proc.txt | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
> index f561fc46e41b..b775b6faaeda 100644
> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -446,7 +446,8 @@ indicates the amount of memory currently marked as referenced or accessed.
>  a mapping associated with a file may contain anonymous pages: when MAP_PRIVATE
>  and a page is modified, the file page is replaced by a private anonymous copy.
>  "AnonHugePages" shows the ammount of memory backed by transparent hugepage.
> -"HugetlbPages" shows the ammount of memory backed by hugetlbfs page.
> +"HugetlbPages" shows the ammount of memory backed by hugetlbfs page (which is
> +not counted in "Rss" or "Pss" field for historical reasons.)
>  "Swap" shows how much would-be-anonymous memory is also used, but out on swap.
>  
>  "VmFlags" field deserves a separate description. This member represents the kernel

Thank you!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
