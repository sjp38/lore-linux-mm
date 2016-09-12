Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id C55306B0038
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 05:59:04 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id s64so92232395lfs.1
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 02:59:04 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id i201si6369196lfe.238.2016.09.12.02.59.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Sep 2016 02:59:03 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id s29so5571072lfg.3
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 02:59:03 -0700 (PDT)
Date: Mon, 12 Sep 2016 12:59:00 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/2] shmem: fix tmpfs to handle the huge= option properly
Message-ID: <20160912095900.GA23346@node.shutemov.name>
References: <1473459863-11287-1-git-send-email-toshi.kani@hpe.com>
 <1473459863-11287-2-git-send-email-toshi.kani@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1473459863-11287-2-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, mawilcox@microsoft.com, hughd@google.com, kirill.shutemov@linux.intel.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Sep 09, 2016 at 04:24:22PM -0600, Toshi Kani wrote:
> shmem_get_unmapped_area() checks SHMEM_SB(sb)->huge incorrectly,
> which leads to a reversed effect of "huge=" mount option.
> 
> Fix the check in shmem_get_unmapped_area().
> 
> Note, the default value of SHMEM_SB(sb)->huge remains as
> SHMEM_HUGE_NEVER.  User will need to specify "huge=" option to
> enable huge page mappings.
> 
> Reported-by: Hillf Danton <hillf.zj@alibaba-inc.com>
> Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Hugh Dickins <hughd@google.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
