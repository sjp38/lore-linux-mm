Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9373B6B025F
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 07:35:52 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id w141so939915wme.1
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 04:35:52 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 65si5251022edm.326.2017.12.01.04.35.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Dec 2017 04:35:51 -0800 (PST)
Date: Fri, 1 Dec 2017 13:35:46 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: stalled MM patches
Message-ID: <20171201123546.GE8365@quack2.suse.cz>
References: <20171130141423.600101bcef07ab2900286865@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171130141423.600101bcef07ab2900286865@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexandru Moise <00moses.alexander00@gmail.com>, Andi Kleen <ak@linux.intel.com>, Andrey Vagin <avagin@openvz.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Anton Vorontsov <anton.vorontsov@linaro.org>, "Artem S. Tashkinov" <t.artem@lycos.com>, Balbir Singh <bsingharora@gmail.com>, Chris Salls <salls@cs.ucsb.edu>, Christopher Lameter <cl@linux.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Glauber Costa <glommer@openvz.org>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Ingo Molnar <mingo@kernel.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, Maxim Patlasov <MPatlasov@parallels.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Punit Agrawal <punit.agrawal@arm.com>, Rik van Riel <riel@redhat.com>, Shiraz Hashim <shashim@codeaurora.org>, Tan Xiaojun <tanxiaojun@huawei.com>, Theodore Ts'o <tytso@mit.edu>, Vinayak Menon <vinmenon@codeaurora.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Yisheng Xie <xieyisheng1@huawei.com>, zhong jiang <zhongjiang@huawei.com>, linux-mm@kvack.org

On Thu 30-11-17 14:14:23, Andrew Morton wrote:
> Subject: mm: readahead: increase maximum readahead window
> 
>   Darrick said he was going to do some testing.

How I understood Darrick's comment was that he was surprised by XFS numbers
we measured and he'd be interested if we see them also with the latest
kernel.  Nothing against the patch as such. And I wrote him that I can
queue XFS runs on current kernel (which didn't happen - my bad). I guess
time for me to really queue a test with the latest kernel.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
