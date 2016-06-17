Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id AC8806B0253
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 09:20:41 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id l184so39137197lfl.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 06:20:41 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id j17si23566911wmd.23.2016.06.17.06.20.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 06:20:40 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id 187so16694991wmz.1
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 06:20:40 -0700 (PDT)
Date: Fri, 17 Jun 2016 15:20:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: fix account pmd page to the process
Message-ID: <20160617132038.GI21670@dhcp22.suse.cz>
References: <1466169192-18343-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1466169192-18343-1-git-send-email-zhongjiang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: mike.kravetz@oracle.com, kirill@shutemov.name, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 17-06-16 21:13:12, zhongjiang wrote:
> From: zhong jiang <zhongjiang@huawei.com>
> 
> huge_pmd_share accounts the number of pmds incorrectly when it races
> with a parallel pud instantiation. vma_interval_tree_foreach will
> increase the counter but then has to recheck the pud with the pte lock
> held and the back off path should drop the increment. The previous
> code would lead to an elevated pmd count which shouldn't be very
> harmful (check_mm() might complain and oom_badness() might be marginally
> confused) but this is worth fixing.

Kirill has posted a patch which is imho better [1]

[1] http://lkml.kernel.org/r/20160617122506.GC6534@node.shutemov.name
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
