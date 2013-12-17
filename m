Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id B51EB6B0035
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 20:07:50 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id q10so5987448pdj.8
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 17:07:50 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id 8si10315577pbe.70.2013.12.16.17.07.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 17:07:49 -0800 (PST)
Message-ID: <52AFA3BB.5070901@huawei.com>
Date: Tue, 17 Dec 2013 09:07:07 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/hugetlb: check for pte NULL pointer in __page_check_address()
References: <52AEC8FD.6050200@huawei.com> <20131216142513.784A8E0090@blue.fi.intel.com>
In-Reply-To: <20131216142513.784A8E0090@blue.fi.intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, qiuxishi <qiuxishi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

Hi Kirill,

On 2013/12/16 22:25, Kirill A. Shutemov wrote:

> Jianguo Wu wrote:
>> In __page_check_address(), if address's pud is not present,
>> huge_pte_offset() will return NULL, we should check the return value.
>>
>> Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
> 
> Looks okay to me.
> 
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> 
> Have you triggered a crash there? Or just spotted by reading the code?
> 


By reading the code.

Thanks,
Jianguo Wu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
