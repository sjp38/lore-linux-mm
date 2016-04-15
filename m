Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id A8B846B0253
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 14:47:50 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id hb4so143040439pac.3
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 11:47:50 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id xe1si5381421pab.53.2016.04.15.11.47.49
        for <linux-mm@kvack.org>;
        Fri, 15 Apr 2016 11:47:49 -0700 (PDT)
Date: Fri, 15 Apr 2016 21:47:46 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH] mm: thp: correct split_huge_pages file permission
Message-ID: <20160415184746.GA132492@black.fi.intel.com>
References: <1460743805-2560-1-git-send-email-yang.shi@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1460743805-2560-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linaro.org>
Cc: akpm@linux-foundation.org, aarcange@redhat.com, hughd@google.com, mgorman@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On Fri, Apr 15, 2016 at 11:10:05AM -0700, Yang Shi wrote:
> split_huge_pages doesn't support get method at all, so the read permission
> sounds confusing, change the permission to write only.
> 
> And, add "\n" to the output of set method to make it more readable.
> 
> Signed-off-by: Yang Shi <yang.shi@linaro.org>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
