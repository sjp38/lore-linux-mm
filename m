Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 7F9646B0036
	for <linux-mm@kvack.org>; Fri, 23 May 2014 13:34:06 -0400 (EDT)
Received: by mail-wg0-f42.google.com with SMTP id y10so5022710wgg.25
        for <linux-mm@kvack.org>; Fri, 23 May 2014 10:34:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id hl6si3173750wjb.55.2014.05.23.10.34.04
        for <linux-mm@kvack.org>;
        Fri, 23 May 2014 10:34:05 -0700 (PDT)
Message-ID: <537F8671.9040805@redhat.com>
Date: Fri, 23 May 2014 13:33:37 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] mm: convert i_mmap_mutex to rwsem
References: <1400816006-3083-1-git-send-email-davidlohr@hp.com> <1400816006-3083-4-git-send-email-davidlohr@hp.com>
In-Reply-To: <1400816006-3083-4-git-send-email-davidlohr@hp.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>, akpm@linux-foundation.org
Cc: mingo@kernel.org, peterz@infradead.org, mgorman@suse.de, aswin@hp.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/22/2014 11:33 PM, Davidlohr Bueso wrote:
> The i_mmap_mutex is a close cousin of the anon vma lock,
> both protecting similar data, one for file backed pages
> and the other for anon memory. To this end, this lock can
> also be a rwsem.
> 
> This conversion is straightforward. For now, all users take
> the write lock.
> 
> Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>

Reviewed-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
