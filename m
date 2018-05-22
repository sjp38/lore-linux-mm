Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id AB37F6B0003
	for <linux-mm@kvack.org>; Tue, 22 May 2018 03:27:58 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id x32-v6so11565845pld.16
        for <linux-mm@kvack.org>; Tue, 22 May 2018 00:27:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h65-v6si12773203pgc.357.2018.05.22.00.27.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 22 May 2018 00:27:57 -0700 (PDT)
Subject: Re: [PATCH] MAINTAINERS: Change hugetlbfs maintainer and update files
References: <20180518225236.19079-1-mike.kravetz@oracle.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <560a5946-ff36-c236-af9f-49ad073f5a9f@suse.cz>
Date: Tue, 22 May 2018 09:27:52 +0200
MIME-Version: 1.0
In-Reply-To: <20180518225236.19079-1-mike.kravetz@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Jan Kara <jack@suse.cz>

On 05/19/2018 12:52 AM, Mike Kravetz wrote:
> The current hugetlbfs maintainer has not been active for more than
> a few years.  I have been been active in this area for more than
> two years and plan to remain active in the foreseeable future.
> 
> Also, update the hugetlbfs entry to include linux-mm mail list and
> additional hugetlbfs related files.  hugetlb.c and hugetlb.h are
> not 100% hugetlbfs, but a majority of their content is hugetlbfs
> related.
> 
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks!

> ---
>  MAINTAINERS | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 9051a9ca24a2..c7a5eb074eb1 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -6564,9 +6564,15 @@ F:	Documentation/networking/hinic.txt
>  F:	drivers/net/ethernet/huawei/hinic/
>  
>  HUGETLB FILESYSTEM
> -M:	Nadia Yvette Chambers <nyc@holomorphy.com>
> +M:	Mike Kravetz <mike.kravetz@oracle.com>
> +L:	linux-mm@kvack.org
>  S:	Maintained
>  F:	fs/hugetlbfs/
> +F:	mm/hugetlb.c
> +F:	include/linux/hugetlb.h
> +F:	Documentation/admin-guide/mm/hugetlbpage.rst
> +F:	Documentation/vm/hugetlbfs_reserv.rst
> +F:	Documentation/ABI/testing/sysfs-kernel-mm-hugepages
>  
>  HVA ST MEDIA DRIVER
>  M:	Jean-Christophe Trotin <jean-christophe.trotin@st.com>
> 
