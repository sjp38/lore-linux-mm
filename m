Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 7D2B06B0032
	for <linux-mm@kvack.org>; Tue, 27 Jan 2015 02:35:24 -0500 (EST)
Received: by mail-we0-f180.google.com with SMTP id m14so13232502wev.11
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 23:35:23 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p5si665697wjp.121.2015.01.26.23.35.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 26 Jan 2015 23:35:22 -0800 (PST)
Message-ID: <54C73FB5.30000@suse.cz>
Date: Tue, 27 Jan 2015 08:35:17 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] mm/page_alloc: expands broken freepage to proper
 buddy list when steal
References: <1418022980-4584-1-git-send-email-iamjoonsoo.kim@lge.com> <1418022980-4584-3-git-send-email-iamjoonsoo.kim@lge.com> <54856F88.8090300@suse.cz> <20141210063840.GC13371@js1304-P5Q-DELUXE>
In-Reply-To: <20141210063840.GC13371@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/10/2014 07:38 AM, Joonsoo Kim wrote:
> After your patch is merged, I will resubmit these on top of it.

Hi Joonsoo,

my page stealing patches are now in -mm so are you planning to resubmit this? At
least patch 1 is an obvious bugfix, and patch 4 a clear compaction overhead
reduction. Those don't need to wait for the rest of the series. If you are busy
with other stuff, I can also resend those two myself if you want.

Thanks,
Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
