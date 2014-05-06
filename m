Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id 82FFB6B0037
	for <linux-mm@kvack.org>; Tue,  6 May 2014 14:53:26 -0400 (EDT)
Received: by mail-qc0-f179.google.com with SMTP id x3so6543664qcv.24
        for <linux-mm@kvack.org>; Tue, 06 May 2014 11:53:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id e19si3558158qgd.46.2014.05.06.11.53.25
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 11:53:25 -0700 (PDT)
Message-ID: <53692F9F.1050000@redhat.com>
Date: Tue, 06 May 2014 14:53:19 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 13/17] mm: shmem: Avoid atomic operation during shmem_getpage_gfp
References: <1398933888-4940-1-git-send-email-mgorman@suse.de> <1398933888-4940-14-git-send-email-mgorman@suse.de>
In-Reply-To: <1398933888-4940-14-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On 05/01/2014 04:44 AM, Mel Gorman wrote:
> shmem_getpage_gfp uses an atomic operation to set the SwapBacked field
> before it's even added to the LRU or visible. This is unnecessary as what
> could it possible race against?  Use an unlocked variant.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
