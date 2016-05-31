Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id E75AC6B0263
	for <linux-mm@kvack.org>; Tue, 31 May 2016 03:52:50 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 132so68170246lfz.3
        for <linux-mm@kvack.org>; Tue, 31 May 2016 00:52:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i194si9402757wme.39.2016.05.31.00.52.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 May 2016 00:52:49 -0700 (PDT)
Subject: Re: [PATCH v6v3 02/12] mm: migrate: support non-lru movable page
 migration
References: <1463754225-31311-1-git-send-email-minchan@kernel.org>
 <1463754225-31311-3-git-send-email-minchan@kernel.org>
 <20160530013926.GB8683@bbox> <20160531000117.GB18314@bbox>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <29ae65ef-a4c9-1d45-ce56-70b29d3eacfd@suse.cz>
Date: Tue, 31 May 2016 09:52:48 +0200
MIME-Version: 1.0
In-Reply-To: <20160531000117.GB18314@bbox>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rafael Aquini <aquini@redhat.com>, virtualization@lists.linux-foundation.org, Jonathan Corbet <corbet@lwn.net>, John Einar Reitan <john.reitan@foss.arm.com>, dri-devel@lists.freedesktop.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Gioh Kim <gi-oh.kim@profitbricks.com>

On 05/31/2016 02:01 AM, Minchan Kim wrote:
> Per Vlastimi's review comment.
>
> Thanks for the detail review, Vlastimi!
> If you have another concern, feel free to say.

I don't for now :)

[...]

> Cc: Rik van Riel <riel@redhat.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Rafael Aquini <aquini@redhat.com>
> Cc: virtualization@lists.linux-foundation.org
> Cc: Jonathan Corbet <corbet@lwn.net>
> Cc: John Einar Reitan <john.reitan@foss.arm.com>
> Cc: dri-devel@lists.freedesktop.org
> Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Signed-off-by: Gioh Kim <gi-oh.kim@profitbricks.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
