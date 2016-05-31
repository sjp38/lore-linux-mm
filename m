Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7F6A76B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 19:04:27 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id g83so4378512oib.0
        for <linux-mm@kvack.org>; Tue, 31 May 2016 16:04:27 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 2si60474147pax.199.2016.05.31.16.04.26
        for <linux-mm@kvack.org>;
        Tue, 31 May 2016 16:04:26 -0700 (PDT)
Date: Wed, 1 Jun 2016 08:05:06 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6v3 02/12] mm: migrate: support non-lru movable page
 migration
Message-ID: <20160531230506.GB19976@bbox>
References: <1463754225-31311-1-git-send-email-minchan@kernel.org>
 <1463754225-31311-3-git-send-email-minchan@kernel.org>
 <20160530013926.GB8683@bbox>
 <20160531000117.GB18314@bbox>
 <29ae65ef-a4c9-1d45-ce56-70b29d3eacfd@suse.cz>
MIME-Version: 1.0
In-Reply-To: <29ae65ef-a4c9-1d45-ce56-70b29d3eacfd@suse.cz>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rafael Aquini <aquini@redhat.com>, virtualization@lists.linux-foundation.org, Jonathan Corbet <corbet@lwn.net>, John Einar Reitan <john.reitan@foss.arm.com>, dri-devel@lists.freedesktop.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Gioh Kim <gi-oh.kim@profitbricks.com>

On Tue, May 31, 2016 at 09:52:48AM +0200, Vlastimil Babka wrote:
> On 05/31/2016 02:01 AM, Minchan Kim wrote:
> >Per Vlastimi's review comment.
> >
> >Thanks for the detail review, Vlastimi!
> >If you have another concern, feel free to say.
> 
> I don't for now :)
> 
> [...]
> 
> >Cc: Rik van Riel <riel@redhat.com>
> >Cc: Vlastimil Babka <vbabka@suse.cz>
> >Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >Cc: Mel Gorman <mgorman@suse.de>
> >Cc: Hugh Dickins <hughd@google.com>
> >Cc: Rafael Aquini <aquini@redhat.com>
> >Cc: virtualization@lists.linux-foundation.org
> >Cc: Jonathan Corbet <corbet@lwn.net>
> >Cc: John Einar Reitan <john.reitan@foss.arm.com>
> >Cc: dri-devel@lists.freedesktop.org
> >Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> >Signed-off-by: Gioh Kim <gi-oh.kim@profitbricks.com>
> >Signed-off-by: Minchan Kim <minchan@kernel.org>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks for the review, Vlastimil!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
