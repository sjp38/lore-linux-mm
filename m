Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id BF9346B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 06:07:16 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id y84so32230758lfc.3
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 03:07:16 -0700 (PDT)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id p5si8249419wmd.62.2016.04.27.03.07.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 03:07:15 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id ED6051C17E6
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 11:07:14 +0100 (IST)
Date: Wed, 27 Apr 2016 11:07:13 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 23/28] mm, page_alloc: Check multiple page fields with a
 single branch
Message-ID: <20160427100713.GG2858@techsingularity.net>
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
 <1460711275-1130-11-git-send-email-mgorman@techsingularity.net>
 <571FB66E.80306@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <571FB66E.80306@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 26, 2016 at 08:41:50PM +0200, Vlastimil Babka wrote:
> On 04/15/2016 11:07 AM, Mel Gorman wrote:
> >Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> I wonder, would it be just too ugly to add +1 to
> atomic_read(&page->_mapcount) and OR it with the rest for a truly single
> branch?
> 

Interesting thought. I'm not going to do it as a fix but when I'm doing
the next round of page allocator material, I'll add it to the pile for
evaluation.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
