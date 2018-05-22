Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7E9166B0005
	for <linux-mm@kvack.org>; Tue, 22 May 2018 02:27:08 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id e26-v6so8791747wmh.7
        for <linux-mm@kvack.org>; Mon, 21 May 2018 23:27:08 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g53-v6si1233926edb.149.2018.05.21.23.27.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 21 May 2018 23:27:07 -0700 (PDT)
Date: Tue, 22 May 2018 08:27:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] MAINTAINERS: Change hugetlbfs maintainer and update files
Message-ID: <20180522062705.GD20020@dhcp22.suse.cz>
References: <20180518225236.19079-1-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180518225236.19079-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Jan Kara <jack@suse.cz>

On Fri 18-05-18 15:52:36, Mike Kravetz wrote:
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

Thanks a lot Mike!
Acked-by: Michal Hocko <mhocko@suse.com>

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
> -- 
> 2.13.6

-- 
Michal Hocko
SUSE Labs
