Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0DE536B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 01:57:37 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 128so185800853pfz.1
        for <linux-mm@kvack.org>; Sun, 16 Oct 2016 22:57:37 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id uk7si12580876pab.97.2016.10.16.22.57.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Oct 2016 22:57:36 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9H5rUjn102970
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 01:57:35 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0a-001b2d01.pphosted.com with ESMTP id 264cnv1a5c-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 01:57:35 -0400
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sun, 16 Oct 2016 23:57:35 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 17/17] dax: remove "depends on BROKEN" from FS_DAX_PMD
In-Reply-To: <20161012225022.15507-18-ross.zwisler@linux.intel.com>
References: <20161012225022.15507-1-ross.zwisler@linux.intel.com> <20161012225022.15507-18-ross.zwisler@linux.intel.com>
Date: Mon, 17 Oct 2016 11:27:24 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87eg3ftt4r.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org
Cc: Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

Ross Zwisler <ross.zwisler@linux.intel.com> writes:

> Now that DAX PMD faults are once again working and are now participating in
> DAX's radix tree locking scheme, allow their config option to be enabled.
>
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---
>  fs/Kconfig | 1 -
>  1 file changed, 1 deletion(-)
>
> diff --git a/fs/Kconfig b/fs/Kconfig
> index 2bc7ad7..b6f0fce 100644
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -55,7 +55,6 @@ config FS_DAX_PMD
>  	depends on FS_DAX
>  	depends on ZONE_DEVICE
>  	depends on TRANSPARENT_HUGEPAGE
> -	depends on BROKEN
>  
>  endif # BLOCK


This series made dax_pmd_fault return VM_FAULT_FALLBACK in [PATCH v6 09/17] dax: remove dax_pmd_fault(). 
That essentially disable dax pmd for ext4. Any plans to fix that ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
