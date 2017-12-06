Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7CE246B0038
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 13:26:27 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 3so3249958pfo.1
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 10:26:27 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id j9si2280957pgp.46.2017.12.06.10.26.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Dec 2017 10:26:17 -0800 (PST)
Date: Wed, 6 Dec 2017 11:26:15 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v3] mm: Add unmap_mapping_pages
Message-ID: <20171206182615.GA22533@linux.intel.com>
References: <20171205154453.GD28760@bombadil.infradead.org>
 <20171206142627.GD32044@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171206142627.GD32044@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, "zhangyi (F)" <yi.zhang@huawei.com>, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>

On Wed, Dec 06, 2017 at 06:26:27AM -0800, Matthew Wilcox wrote:
> v3:
>  - Fix compilation
>    (I forgot to git commit --amend)
>  - Added Ross' Reviewed-by
> v2:
>  - Fix inverted mask in dax.c
>  - Pass 'false' instead of '0' for 'only_cows'
>  - nommu definition
> 
> --- 8< ---
> 
> From df142c51e111f7c386f594d5443530ea17abba5f Mon Sep 17 00:00:00 2001
> From: Matthew Wilcox <mawilcox@microsoft.com>
> Date: Tue, 5 Dec 2017 00:15:54 -0500
> Subject: [PATCH v3] mm: Add unmap_mapping_pages

Just FYI, the above scissors doesn't allow me to apply the patch using git
version 2.14.3:

  $ git am --scissors  ~/patch/out.patch
  Patch is empty.
  When you have resolved this problem, run "git am --continue".
  If you prefer to skip this patch, run "git am --skip" instead.
  To restore the original branch and stop patching, run "git am --abort".

It's mad about the second set of mail headers in the body of your mail, and
tries to separate into a second patch.

You can get around this either by a) not having the second set of headers
(From:, Date:, Subject:), or by including the extra info in a separate block
below the --- line, i.e.:

  ...
  Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
  Reported-by: "zhangyi (F)" <yi.zhang@huawei.com>
  Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
  ---
  
  v3:
   - Fix compilation
     (I forgot to git commit --amend)
   - Added Ross' Reviewed-by
  v2:
   - Fix inverted mask in dax.c
   - Pass 'false' instead of '0' for 'only_cows'
   - nommu definition
  
  ---
   fs/dax.c           | 19 ++++++-------------
   include/linux/mm.h | 26 ++++++++++++++++----------
  ...

- Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
