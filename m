Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 775E18299E
	for <linux-mm@kvack.org>; Tue,  6 May 2014 11:09:19 -0400 (EDT)
Received: by mail-qg0-f54.google.com with SMTP id q108so6309298qgd.41
        for <linux-mm@kvack.org>; Tue, 06 May 2014 08:09:19 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id h90si5286425qgh.83.2014.05.06.08.09.18
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 08:09:18 -0700 (PDT)
Message-ID: <5368FB19.4060308@redhat.com>
Date: Tue, 06 May 2014 11:09:13 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/17] mm: page_alloc: Do not treat a zone that cannot
 be used for dirty pages as "full"
References: <1398933888-4940-1-git-send-email-mgorman@suse.de> <1398933888-4940-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1398933888-4940-3-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On 05/01/2014 04:44 AM, Mel Gorman wrote:
> If a zone cannot be used for a dirty page then it gets marked "full"
> which is cached in the zlc and later potentially skipped by allocation
> requests that have nothing to do with dirty zones.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
