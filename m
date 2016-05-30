Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E370F6B025F
	for <linux-mm@kvack.org>; Sun, 29 May 2016 21:38:56 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c84so199729284pfc.3
        for <linux-mm@kvack.org>; Sun, 29 May 2016 18:38:56 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id b74si32959313pfb.21.2016.05.29.18.38.54
        for <linux-mm@kvack.org>;
        Sun, 29 May 2016 18:38:55 -0700 (PDT)
Date: Mon, 30 May 2016 10:39:26 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: PATCH v6v2 02/12] mm: migrate: support non-lru movable page migration
Message-ID: <20160530013926.GB8683@bbox>
References: <1463754225-31311-1-git-send-email-minchan@kernel.org>
 <1463754225-31311-3-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
In-Reply-To: <1463754225-31311-3-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rafael Aquini <aquini@redhat.com>, virtualization@lists.linux-foundation.org, Jonathan Corbet <corbet@lwn.net>, John Einar Reitan <john.reitan@foss.arm.com>, dri-devel@lists.freedesktop.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Gioh Kim <gi-oh.kim@profitbricks.com>

Per Vlastimil's review comment,

Vlastimil, I updated based on your comment. Please review this.
If everything is done, I will send v7 rebased on recent mmotm.

Thanks for the review!
