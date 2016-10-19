Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 11A346B025E
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 14:33:31 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e6so2361429pfk.2
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 11:33:31 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j5si31195978pax.188.2016.10.19.11.33.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 11:33:30 -0700 (PDT)
Date: Wed, 19 Oct 2016 11:33:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: kmemleak: Ensure that the task stack is not freed
 during scanning
Message-Id: <20161019113327.3e796893d89333f6ebe65d79@linux-foundation.org>
In-Reply-To: <1476266223-14325-1-git-send-email-catalin.marinas@arm.com>
References: <1476266223-14325-1-git-send-email-catalin.marinas@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, CAI Qian <caiqian@redhat.com>

On Wed, 12 Oct 2016 10:57:03 +0100 Catalin Marinas <catalin.marinas@arm.com> wrote:

> Commit 68f24b08ee89 ("sched/core: Free the stack early if
> CONFIG_THREAD_INFO_IN_TASK") may cause the task->stack to be freed
> during kmemleak_scan() execution, leading to either a NULL pointer
> fault (if task->stack is NULL) or kmemleak accessing already freed
> memory. This patch uses the new try_get_task_stack() API to ensure that
> the task stack is not freed during kmemleak stack scanning.
> 
> Fixes: 68f24b08ee89 ("sched/core: Free the stack early if CONFIG_THREAD_INFO_IN_TASK")
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: CAI Qian <caiqian@redhat.com>
> Reported-by: CAI Qian <caiqian@redhat.com>
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>

I'll add

Cc: <stable@vger.kernel.org>    [4.8.x]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
