Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id C86F96B0031
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 09:05:05 -0500 (EST)
Received: by mail-we0-f170.google.com with SMTP id u57so2588736wes.29
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 06:05:05 -0800 (PST)
Received: from mail-wg0-x22c.google.com (mail-wg0-x22c.google.com [2a00:1450:400c:c00::22c])
        by mx.google.com with ESMTPS id kc5si1382092wjc.145.2014.01.09.06.05.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 09 Jan 2014 06:05:04 -0800 (PST)
Received: by mail-wg0-f44.google.com with SMTP id l18so1862586wgh.23
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 06:05:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <xa1tha9dbk2t.fsf@mina86.com>
References: <1389251087-10224-1-git-send-email-iamjoonsoo.kim@lge.com>
	<xa1tha9dbk2t.fsf@mina86.com>
Date: Thu, 9 Jan 2014 23:05:04 +0900
Message-ID: <CAAmzW4PyCp1Hw1ThHGZV5i1wb9494vgpDhZ4h+Gr3Q=pLOojJA@mail.gmail.com>
Subject: Re: [PATCH 0/7] improve robustness on handling migratetype
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jiang Liu <jiang.liu@huawei.com>, Mel Gorman <mgorman@suse.de>, Cody P Schafer <cody@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Andi Kleen <ak@linux.intel.com>, Wei Yongjun <yongjun_wei@trendmicro.com.cn>, Tang Chen <tangchen@cn.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

2014/1/9 Michal Nazarewicz <mina86@mina86.com>:
> On Thu, Jan 09 2014, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
>> Third, there is the problem on buddy allocator. It doesn't consider
>> migratetype when merging buddy, so pages from cma or isolate region can
>> be moved to other migratetype freelist. It makes CMA failed over and over.
>> To prevent it, the buddy allocator should consider migratetype if
>> CMA/ISOLATE is enabled.
>
> There should never be situation where a CMA page shares a pageblock (or
> a max-order page) with a non-CMA page though, so this should never be an
> issue.

Right... It never happens.
When I ported CMA region reservation code to my own code for testing,
I made a mistake. Sorry for noise.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
