Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1559E6B0038
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 05:47:41 -0400 (EDT)
Received: by padcy3 with SMTP id cy3so5012875pad.3
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 02:47:40 -0700 (PDT)
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com. [202.81.31.142])
        by mx.google.com with ESMTPS id ph4si4086609pdb.114.2015.03.17.02.47.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Mar 2015 02:47:40 -0700 (PDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 17 Mar 2015 19:47:35 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 1A5542BB0052
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 20:47:32 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t2H9lN4A41877628
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 20:47:32 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t2H9kwV8024706
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 20:46:58 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC 00/16] Introduce ZONE_CMA
In-Reply-To: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
Date: Tue, 17 Mar 2015 15:16:28 +0530
Message-ID: <873854ard7.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hui Zhu <zhuhui@xiaomi.com>, Gioh Kim <gioh.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Ritesh Harjani <ritesh.list@gmail.com>, Vlastimil Babka <vbabka@suse.cz>

Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:

> I passed boot test on x86, ARM32 and ARM64. I did some stress tests
> on x86 and there is no problem. Feel free to enjoy and please give me
> a feedback. :)

Tested on ppc64 with kvm. (I used the CONFIG_SPARSEMEM_VMEMMAP). I will
check with other sparsemem config and update if I find any issue.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
