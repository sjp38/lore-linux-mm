Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 02E916B0037
	for <linux-mm@kvack.org>; Fri, 23 May 2014 14:37:05 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id cc10so1275960wib.16
        for <linux-mm@kvack.org>; Fri, 23 May 2014 11:37:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id bd1si3354761wjc.5.2014.05.23.11.37.03
        for <linux-mm@kvack.org>;
        Fri, 23 May 2014 11:37:04 -0700 (PDT)
Message-ID: <537F9534.7020603@redhat.com>
Date: Fri, 23 May 2014 14:36:36 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/5] mm: rename leftover i_mmap_mutex
References: <1400816006-3083-1-git-send-email-davidlohr@hp.com> <1400816006-3083-6-git-send-email-davidlohr@hp.com>
In-Reply-To: <1400816006-3083-6-git-send-email-davidlohr@hp.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>, akpm@linux-foundation.org
Cc: mingo@kernel.org, peterz@infradead.org, mgorman@suse.de, aswin@hp.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/22/2014 11:33 PM, Davidlohr Bueso wrote:
> Update the lock to i_mmap_rwsem throughout the kernel.
> All changes are in comments and documentation.
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
