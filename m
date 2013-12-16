Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6F7BF6B0036
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 09:26:11 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id kl14so2977607pab.5
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 06:26:11 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id yd9si9055856pab.89.2013.12.16.06.26.08
        for <linux-mm@kvack.org>;
        Mon, 16 Dec 2013 06:26:08 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <52AEC8FD.6050200@huawei.com>
References: <52AEC8FD.6050200@huawei.com>
Subject: RE: [PATCH] mm/hugetlb: check for pte NULL pointer in
 __page_check_address()
Content-Transfer-Encoding: 7bit
Message-Id: <20131216142513.784A8E0090@blue.fi.intel.com>
Date: Mon, 16 Dec 2013 16:25:13 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, qiuxishi <qiuxishi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

Jianguo Wu wrote:
> In __page_check_address(), if address's pud is not present,
> huge_pte_offset() will return NULL, we should check the return value.
> 
> Signed-off-by: Jianguo Wu <wujianguo@huawei.com>

Looks okay to me.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Have you triggered a crash there? Or just spotted by reading the code?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
