Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id 678486B00BD
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 11:20:15 -0500 (EST)
Received: by mail-qa0-f48.google.com with SMTP id w5so2761995qac.14
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 08:20:15 -0800 (PST)
Received: from a9-50.smtp-out.amazonses.com (a9-50.smtp-out.amazonses.com. [54.240.9.50])
        by mx.google.com with ESMTP id il3si8622849qab.111.2013.12.09.08.20.14
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 08:20:14 -0800 (PST)
Date: Mon, 9 Dec 2013 16:20:13 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 6/7] mm/migrate: remove unused function,
 fail_migrate_page()
In-Reply-To: <1386580248-22431-7-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <00000142d828aafc-37d556c5-558d-4c78-86bf-006921ad6dae-000000@email.amazonses.com>
References: <1386580248-22431-1-git-send-email-iamjoonsoo.kim@lge.com> <1386580248-22431-7-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Mon, 9 Dec 2013, Joonsoo Kim wrote:

> fail_migrate_page() isn't used anywhere, so remove it.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
