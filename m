Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 9C5416B003C
	for <linux-mm@kvack.org>; Tue,  6 May 2014 14:54:33 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id a108so3044845qge.8
        for <linux-mm@kvack.org>; Tue, 06 May 2014 11:54:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id u7si3441727qab.259.2014.05.06.11.54.32
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 11:54:33 -0700 (PDT)
Message-ID: <53692FE4.6000905@redhat.com>
Date: Tue, 06 May 2014 14:54:28 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 14/17] mm: Do not use atomic operations when releasing
 pages
References: <1398933888-4940-1-git-send-email-mgorman@suse.de> <1398933888-4940-15-git-send-email-mgorman@suse.de>
In-Reply-To: <1398933888-4940-15-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On 05/01/2014 04:44 AM, Mel Gorman wrote:
> There should be no references to it any more and a parallel mark should
> not be reordered against us. Use non-locked varient to clear page active.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
