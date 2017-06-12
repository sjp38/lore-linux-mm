Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id CA2F26B0343
	for <linux-mm@kvack.org>; Mon, 12 Jun 2017 08:07:28 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t30so52465653pgo.0
        for <linux-mm@kvack.org>; Mon, 12 Jun 2017 05:07:28 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id a33si6793666plc.382.2017.06.12.05.07.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jun 2017 05:07:27 -0700 (PDT)
Date: Mon, 12 Jun 2017 15:07:14 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 2/2] mm: always enable thp for dax mappings
Message-ID: <20170612120714.zypyvp3e4zypqfvf@black.fi.intel.com>
References: <149713136649.17377.3742583729924020371.stgit@dwillia2-desk3.amr.corp.intel.com>
 <149713137723.17377.8854203820807564559.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <149713137723.17377.8854203820807564559.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, hch@lst.de

On Sat, Jun 10, 2017 at 02:49:37PM -0700, Dan Williams wrote:
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index c4706e2c3358..901ed3767d1b 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -1,6 +1,8 @@
>  #ifndef _LINUX_HUGE_MM_H
>  #define _LINUX_HUGE_MM_H
>  
> +#include <linux/fs.h>
> +

It means <linux/mm.h> now depends on <linux/fs.h>. I don't think it's a
good idea.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
