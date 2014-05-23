Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id E19C36B0036
	for <linux-mm@kvack.org>; Fri, 23 May 2014 14:36:30 -0400 (EDT)
Received: by mail-we0-f174.google.com with SMTP id k48so5369714wev.33
        for <linux-mm@kvack.org>; Fri, 23 May 2014 11:36:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id vb5si3338162wjc.37.2014.05.23.11.36.28
        for <linux-mm@kvack.org>;
        Fri, 23 May 2014 11:36:29 -0700 (PDT)
Message-ID: <537F950F.9050906@redhat.com>
Date: Fri, 23 May 2014 14:35:59 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] mm/rmap: share the i_mmap_rwsem
References: <1400816006-3083-1-git-send-email-davidlohr@hp.com> <1400816006-3083-5-git-send-email-davidlohr@hp.com>
In-Reply-To: <1400816006-3083-5-git-send-email-davidlohr@hp.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>, akpm@linux-foundation.org
Cc: mingo@kernel.org, peterz@infradead.org, mgorman@suse.de, aswin@hp.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/22/2014 11:33 PM, Davidlohr Bueso wrote:
> Similarly to rmap_walk_anon() and collect_procs_anon(),
> there is opportunity to share the lock in rmap_walk_file()
> and collect_procs_file() for file backed pages.
> 
> Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>

Acked-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
