Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id ACCAE8299E
	for <linux-mm@kvack.org>; Tue,  6 May 2014 11:11:03 -0400 (EDT)
Received: by mail-qa0-f52.google.com with SMTP id cm18so7479867qab.25
        for <linux-mm@kvack.org>; Tue, 06 May 2014 08:11:03 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id e7si5238326qai.134.2014.05.06.08.11.01
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 08:11:01 -0700 (PDT)
Message-ID: <5368FB80.3010100@redhat.com>
Date: Tue, 06 May 2014 11:10:56 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 03/17] mm: page_alloc: Use jump labels to avoid checking
 number_of_cpusets
References: <1398933888-4940-1-git-send-email-mgorman@suse.de> <1398933888-4940-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1398933888-4940-4-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Linux Kernel <linux-kernel@vger.kernel.org>

On 05/01/2014 04:44 AM, Mel Gorman wrote:
> If cpusets are not in use then we still check a global variable on every
> page allocation. Use jump labels to avoid the overhead.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
