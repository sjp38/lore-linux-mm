Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f43.google.com (mail-yh0-f43.google.com [209.85.213.43])
	by kanga.kvack.org (Postfix) with ESMTP id 7D7106B0036
	for <linux-mm@kvack.org>; Thu, 15 May 2014 18:38:07 -0400 (EDT)
Received: by mail-yh0-f43.google.com with SMTP id v1so3670899yhn.16
        for <linux-mm@kvack.org>; Thu, 15 May 2014 15:38:07 -0700 (PDT)
Received: from g5t1625.atlanta.hp.com (g5t1625.atlanta.hp.com. [15.192.137.8])
        by mx.google.com with ESMTPS id s93si8377553yhp.90.2014.05.15.15.38.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 15 May 2014 15:38:06 -0700 (PDT)
Message-ID: <1400193482.5678.0.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH] mm, hugetlb: move the error handle logic out of normal
 code path
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Thu, 15 May 2014 15:38:02 -0700
In-Reply-To: <1400051459-20578-1-git-send-email-nasa4836@gmail.com>
References: <1400051459-20578-1-git-send-email-nasa4836@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, aneesh.kumar@linux.vnet.ibm.com, n-horiguchi@ah.jp.nec.com, mhocko@suse.cz, aarcange@redhat.com, steve.capper@linaro.org, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 2014-05-14 at 15:10 +0800, Jianyu Zhan wrote:
> alloc_huge_page() now mixes normal code path with error handle logic.
> This patches move out the error handle logic, to make normal code
> path more clean and redue code duplicate.
> 
> Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>

Acked-by: Davidlohr Bueso <davidlohr@hp.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
