Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f43.google.com (mail-qe0-f43.google.com [209.85.128.43])
	by kanga.kvack.org (Postfix) with ESMTP id E30FD6B0037
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 11:00:59 -0500 (EST)
Received: by mail-qe0-f43.google.com with SMTP id 2so5417652qeb.2
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 08:00:59 -0800 (PST)
Received: from a9-42.smtp-out.amazonses.com (a9-42.smtp-out.amazonses.com. [54.240.9.42])
        by mx.google.com with ESMTP id f1si15857600qar.116.2013.12.11.08.00.57
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 08:00:58 -0800 (PST)
Date: Wed, 11 Dec 2013 16:00:56 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 7/7] mm/migrate: remove result argument on page
 allocation function for migration
In-Reply-To: <20131211084719.GA2043@lge.com>
Message-ID: <00000142e263bbcd-65959fd3-eadc-4580-b55b-065c734a229e-000000@email.amazonses.com>
References: <1386580248-22431-1-git-send-email-iamjoonsoo.kim@lge.com> <1386580248-22431-8-git-send-email-iamjoonsoo.kim@lge.com> <00000142d83adfc7-81b70cc9-c87b-4e7e-bd98-0a97ee21db31-000000@email.amazonses.com> <20131211084719.GA2043@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Wed, 11 Dec 2013, Joonsoo Kim wrote:

> In do_move_pages(), if error occurs, 'goto out_pm' is executed and the
> page status doesn't back to userspace. So we don't need to store err number.

If a page cannot be moved then the error code is containing the number of
pages that could not be migrated. The check there is for err < 0.
So a positive number is not an error.

migrate_pages only returns an error code if we are running out of memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
