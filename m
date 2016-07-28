Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7C6566B0253
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 12:42:40 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ag5so57993964pad.2
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 09:42:40 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id z3si13096576pav.257.2016.07.28.09.42.39
        for <linux-mm@kvack.org>;
        Thu, 28 Jul 2016 09:42:39 -0700 (PDT)
Subject: Re: [PATCH V2] mm/hugetlb: Avoid soft lockup in set_max_huge_pages()
References: <1469674442-14848-1-git-send-email-hejianet@gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <579A35FF.6050606@linux.intel.com>
Date: Thu, 28 Jul 2016 09:42:39 -0700
MIME-Version: 1.0
In-Reply-To: <1469674442-14848-1-git-send-email-hejianet@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Paul Gortmaker <paul.gortmaker@windriver.com>

Looks fine to me.

Acked-by: Dave Hansen <dave.hansen@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
