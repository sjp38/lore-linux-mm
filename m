Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id 8F3B46B0037
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 17:59:43 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id q59so8976903wes.12
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 14:59:43 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a19si4292944wiw.87.2014.06.30.14.59.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 30 Jun 2014 14:59:42 -0700 (PDT)
Date: Mon, 30 Jun 2014 22:59:38 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/2] mm: replace init_page_accessed by __SetPageReferenced
Message-ID: <20140630215938.GR10819@suse.de>
References: <alpine.LSU.2.11.1406301405230.1096@eggly.anvils>
 <alpine.LSU.2.11.1406301408310.1096@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1406301408310.1096@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jun 30, 2014 at 02:09:49PM -0700, Hugh Dickins wrote:
> Do we really need an exported alias for __SetPageReferenced()?
> Its callers better know what they're doing, in which case the page
> would not be already marked referenced.  Kill init_page_accessed(),
> just __SetPageReferenced() inline.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Ok, fair enough. The context it was written in was that callers should not
need to know the internals of what mark_page_accessed does. Initially I
thought there might be filesystem users that really should not know the
internals but that is not necessary obviously. I still feel that
init_page_accessed shows the intent more clearly and you're certainly
right that the checking PageReferenced is redundant. I don't object to
the patch but I don't think it's obviously better either other than it
avoids the temptation of anyone using __SetPageReferenced incorrectly.

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
