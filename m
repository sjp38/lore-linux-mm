Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7C7A46B0038
	for <linux-mm@kvack.org>; Sun, 14 Jun 2015 21:04:40 -0400 (EDT)
Received: by qcej3 with SMTP id j3so3033767qce.3
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 18:04:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z92si11229367qgd.1.2015.06.14.18.04.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Jun 2015 18:04:39 -0700 (PDT)
Message-ID: <557E249B.6070208@redhat.com>
Date: Sun, 14 Jun 2015 21:04:27 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/3] mm: add tracepoint for scanning pages
References: <1434294283-8699-1-git-send-email-ebru.akagunduz@gmail.com> <1434294283-8699-2-git-send-email-ebru.akagunduz@gmail.com>
In-Reply-To: <1434294283-8699-2-git-send-email-ebru.akagunduz@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com

On 06/14/2015 11:04 AM, Ebru Akagunduz wrote:
> Using static tracepoints, data of functions is recorded.
> It is good to automatize debugging without doing a lot
> of changes in the source code.
> 
> This patch adds tracepoint for khugepaged_scan_pmd,
> collapse_huge_page and __collapse_huge_page_isolate.

These trace points seem like a useful set to figure out what
the THP collapse code is doing.

> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
