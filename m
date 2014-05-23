Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id A6BFC6B0037
	for <linux-mm@kvack.org>; Fri, 23 May 2014 13:17:06 -0400 (EDT)
Received: by mail-ee0-f53.google.com with SMTP id c13so3921997eek.12
        for <linux-mm@kvack.org>; Fri, 23 May 2014 10:17:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id z11si8092511eev.162.2014.05.23.10.17.04
        for <linux-mm@kvack.org>;
        Fri, 23 May 2014 10:17:05 -0700 (PDT)
Message-ID: <537F8276.60902@redhat.com>
Date: Fri, 23 May 2014 13:16:38 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/5] mm: use new helper functions around the i_mmap_mutex
References: <1400816006-3083-1-git-send-email-davidlohr@hp.com> <1400816006-3083-3-git-send-email-davidlohr@hp.com>
In-Reply-To: <1400816006-3083-3-git-send-email-davidlohr@hp.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>, akpm@linux-foundation.org
Cc: mingo@kernel.org, peterz@infradead.org, mgorman@suse.de, aswin@hp.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/22/2014 11:33 PM, Davidlohr Bueso wrote:
> Convert all open coded mutex_lock/unlock calls to the
> i_mmap_[lock/unlock]_write() helpers.
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
