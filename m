Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id 35DCB6B0098
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 13:51:38 -0500 (EST)
Received: by mail-qa0-f48.google.com with SMTP id w5so830200qac.0
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 10:51:37 -0800 (PST)
Received: from a9-70.smtp-out.amazonses.com (a9-70.smtp-out.amazonses.com. [54.240.9.70])
        by mx.google.com with ESMTP id u5si32695235qcj.106.2013.12.06.10.51.37
        for <linux-mm@kvack.org>;
        Fri, 06 Dec 2013 10:51:37 -0800 (PST)
Date: Fri, 6 Dec 2013 18:51:36 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/4] mm/migrate: correct return value of
 migrate_pages()
In-Reply-To: <1386355046-jja39cg0-mutt-n-horiguchi@ah.jp.nec.com>
Message-ID: <00000142c9403016-a312eac7-8ca7-4f93-a61d-5b8eccbcb9db-000000@email.amazonses.com>
References: <1386319310-28016-1-git-send-email-iamjoonsoo.kim@lge.com> <52A1E248.1000204@suse.cz> <1386355046-jja39cg0-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 6 Dec 2013, Naoya Horiguchi wrote:

> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Date: Fri, 6 Dec 2013 13:08:15 -0500
> Subject: [PATCH] migrate: add comment about permanent failure path
>
> Let's add a comment about where the failed page goes to, which makes
> code more readable.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
