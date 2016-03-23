Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9EEB96B0253
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 12:03:45 -0400 (EDT)
Received: by mail-pf0-f179.google.com with SMTP id n5so33644233pfn.2
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 09:03:45 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0089.outbound.protection.outlook.com. [157.56.112.89])
        by mx.google.com with ESMTPS id t13si5116739pas.225.2016.03.23.09.03.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 23 Mar 2016 09:03:44 -0700 (PDT)
Subject: Re: [PATCH v2 5/6] tile: mm: Use hugetlb_bad_size
References: <1458736627-16155-1-git-send-email-vaishali.thakkar@oracle.com>
From: Chris Metcalf <cmetcalf@mellanox.com>
Message-ID: <56F2BE4C.1010607@mellanox.com>
Date: Wed, 23 Mar 2016 12:03:24 -0400
MIME-Version: 1.0
In-Reply-To: <1458736627-16155-1-git-send-email-vaishali.thakkar@oracle.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vaishali Thakkar <vaishali.thakkar@oracle.com>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Dave Hansen <dave.hansen@linux.intel.com>

On 3/23/2016 8:37 AM, Vaishali Thakkar wrote:
> Update the setup_hugepagesz function to call the routine
> hugetlb_bad_size when unsupported hugepage size is found.
>
> Signed-off-by: Vaishali Thakkar<vaishali.thakkar@oracle.com>
> Reviewed-by: Mike Kravetz<mike.kravetz@oracle.com>
> Reviewed-by: Naoya Horiguchi<n-horiguchi@ah.jp.nec.com>
> Cc: Hillf Danton<hillf.zj@alibaba-inc.com>
> Cc: Michal Hocko<mhocko@suse.com>
> Cc: Yaowei Bai<baiyaowei@cmss.chinamobile.com>
> Cc: Dominik Dingel<dingel@linux.vnet.ibm.com>
> Cc: Kirill A. Shutemov<kirill.shutemov@linux.intel.com>
> Cc: Paul Gortmaker<paul.gortmaker@windriver.com>
> Cc: Dave Hansen<dave.hansen@linux.intel.com>

Acked-by: Chris Metcalf <cmetcalf@mellanox.com>

-- 
Chris Metcalf, Mellanox Technologies
http://www.mellanox.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
