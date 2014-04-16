Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id 5CB5D6B0075
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 11:49:53 -0400 (EDT)
Received: by mail-qc0-f169.google.com with SMTP id i17so12240435qcy.14
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 08:49:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id z8si696908qar.226.2014.04.16.08.49.52
        for <linux-mm@kvack.org>;
        Wed, 16 Apr 2014 08:49:52 -0700 (PDT)
Message-ID: <534EA699.6040105@redhat.com>
Date: Wed, 16 Apr 2014 11:49:45 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm/compaction: cleanup isolate_freepages()
References: <5342BA34.8050006@suse.cz> <1397553507-15330-1-git-send-email-vbabka@suse.cz> <1397553507-15330-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1397553507-15330-2-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Heesub Shin <heesub.shin@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dongjun Shin <d.j.shin@samsung.com>, Sunghwan Yun <sunghwan.yun@samsung.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>

On 04/15/2014 05:18 AM, Vlastimil Babka wrote:
> isolate_freepages() is currently somewhat hard to follow thanks to many
> different pfn variables. Especially misleading is the name 'high_pfn' which
> looks like it is related to the 'low_pfn' variable, but in fact it is not.
>
> This patch renames the 'high_pfn' variable to a hopefully less confusing name,
> and slightly changes its handling without a functional change. A comment made
> obsolete by recent changes is also updated.
>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
