Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id B64936B0253
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 06:38:46 -0400 (EDT)
Received: by mail-wm0-f43.google.com with SMTP id 20so64452730wmh.1
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 03:38:46 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id uq5si4297594wjc.43.2016.03.30.03.38.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Mar 2016 03:38:45 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 34EB01C186E
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 11:38:45 +0100 (IST)
Date: Wed, 30 Mar 2016 11:38:39 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] Revert "mm/page_alloc: protect pcp->batch accesses with
 ACCESS_ONCE"
Message-ID: <20160330103839.GA4773@techsingularity.net>
References: <1459333327-89720-1-git-send-email-hekuang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1459333327-89720-1-git-send-email-hekuang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: He Kuang <hekuang@huawei.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, rientjes@google.com, cody@linux.vnet.ibm.com, gilad@benyossef.com, kosaki.motohiro@gmail.com, mgorman@suse.de, penberg@kernel.org, lizefan@huawei.com, wangnan0@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Mar 30, 2016 at 10:22:07AM +0000, He Kuang wrote:
> This reverts commit 998d39cb236fe464af86a3492a24d2f67ee1efc2.
> 
> When local irq is disabled, a percpu variable does not change, so we can
> remove the access macros and let the compiler optimize the code safely.
> 

batch can be changed from other contexts. Why is this safe?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
