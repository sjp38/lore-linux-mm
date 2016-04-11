Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id D1C4E6B025F
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:19:39 -0400 (EDT)
Received: by mail-wm0-f52.google.com with SMTP id l6so135029448wml.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 01:19:39 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id u6si17121715wmb.7.2016.04.11.01.19.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 01:19:38 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id A50011C1272
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 09:19:38 +0100 (IST)
Date: Mon, 11 Apr 2016 09:18:32 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 00/21] Optimise page alloc/free fast paths
Message-ID: <20160411081832.GA32073@techsingularity.net>
References: <1460362424-26369-1-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1460362424-26369-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Apr 11, 2016 at 09:13:23AM +0100, Mel Gorman wrote:
> Another year, another round of page allocator optimisations focusing this
> time on the alloc and free fast paths. This should be of help to workloads
> that are allocator-intensive from kernel space where the cost of zeroing
> is not nceessraily incurred.
> 

Despite the numbering, there really is 21 patches. I dropped patch 22 last
night because the impact was negligible for a complex patch but didn't
refresh the numbering.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
