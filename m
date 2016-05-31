Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4EFB96B0253
	for <linux-mm@kvack.org>; Mon, 30 May 2016 20:00:45 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c84so242918826pfc.3
        for <linux-mm@kvack.org>; Mon, 30 May 2016 17:00:45 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id d63si37802362pfc.180.2016.05.30.17.00.42
        for <linux-mm@kvack.org>;
        Mon, 30 May 2016 17:00:43 -0700 (PDT)
Date: Tue, 31 May 2016 09:01:17 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v6v3 02/12] mm: migrate: support non-lru movable page
 migration
Message-ID: <20160531000117.GB18314@bbox>
References: <1463754225-31311-1-git-send-email-minchan@kernel.org>
 <1463754225-31311-3-git-send-email-minchan@kernel.org>
 <20160530013926.GB8683@bbox>
MIME-Version: 1.0
In-Reply-To: <20160530013926.GB8683@bbox>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rafael Aquini <aquini@redhat.com>, virtualization@lists.linux-foundation.org, Jonathan Corbet <corbet@lwn.net>, John Einar Reitan <john.reitan@foss.arm.com>, dri-devel@lists.freedesktop.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Gioh Kim <gi-oh.kim@profitbricks.com>

Per Vlastimi's review comment.

Thanks for the detail review, Vlastimi!
If you have another concern, feel free to say.
After I resolve all thing, I will send v7 rebased on recent mmotm.
