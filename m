Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id BDC1A6B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 03:00:00 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id n8so10593552wmg.4
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 00:00:00 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f23si2419217edb.350.2017.11.26.23.59.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 26 Nov 2017 23:59:59 -0800 (PST)
Date: Mon, 27 Nov 2017 08:59:57 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,madvise: bugfix of madvise systemcall infinite loop
 under special circumstances.
Message-ID: <20171127075957.4akgtn6bxjupgwgb@dhcp22.suse.cz>
References: <20171124022757.4991-1-guoxuenan@huawei.com>
 <20171124080507.u76g634hucoxmpov@dhcp22.suse.cz>
 <829af987-4d65-382c-dbd4-0c81222ebb51@huawei.com>
 <20171124130803.hafb3zbhy7gdqkvi@dhcp22.suse.cz>
 <52b8bab4-6656-fe76-ed21-ee3c4682a5e3@huawei.com>
 <cef000ae-c74d-f460-64d8-0be23350005b@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <cef000ae-c74d-f460-64d8-0be23350005b@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?6YOt6Zuq5qWg?= <guoxuenan@huawei.com>
Cc: akpm@linux-foundation.org, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rppt@linux.vnet.ibm.com, yi.zhang@huawei.com, miaoxie@huawei.com, aarcange@redhat.com, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, rientjes@google.com, khandual@linux.vnet.ibm.com, riel@redhat.com, hillf.zj@alibaba-inc.com, shli@fb.com

On Mon 27-11-17 10:54:39, e?-e?aaeJPY  wrote:
> Hi,Michal, Whether  need me to modify according your modification and
> resubmit a new patch?

please do
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
