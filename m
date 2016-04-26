Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id D7C256B0253
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 15:11:25 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id zy2so34932017pac.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 12:11:25 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g6si5728017pfj.184.2016.04.26.12.11.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 12:11:25 -0700 (PDT)
Date: Tue, 26 Apr 2016 12:11:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 13/28] mm, page_alloc: Remove redundant check for empty
 zonelist
Message-Id: <20160426121124.8c2e000582673cf1fbed7573@linux-foundation.org>
In-Reply-To: <20160426130011.GC2858@techsingularity.net>
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
	<1460711275-1130-1-git-send-email-mgorman@techsingularity.net>
	<571F5963.1000504@suse.cz>
	<20160426130011.GC2858@techsingularity.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 26 Apr 2016 14:00:11 +0100 Mel Gorman <mgorman@techsingularity.net> wrote:

>  If Andrew is watching, please drop this patch if possible.

Thud.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
