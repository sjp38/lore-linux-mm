Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C49FC6B0033
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 10:21:17 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id 80so3554806wmb.7
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 07:21:17 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 4sor2984614edx.50.2017.12.07.07.21.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Dec 2017 07:21:15 -0800 (PST)
Date: Thu, 7 Dec 2017 18:21:13 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm/huge_memory: fix comment in __split_huge_pmd_locked
Message-ID: <20171207152113.emmc63hmehppjdgs@node.shutemov.name>
References: <1512625745-59451-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1512625745-59451-1-git-send-email-xieyisheng1@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 07, 2017 at 01:49:05PM +0800, Yisheng Xie wrote:
> pmd_trans_splitting has been remove after THP refcounting redesign,
> therefore related comment should be updated.
> 
> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>

Looks good to me.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
