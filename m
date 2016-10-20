Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C66936B0038
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 06:02:39 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id h24so20127335pfh.0
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 03:02:39 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p9si600510pgd.213.2016.10.20.03.02.38
        for <linux-mm@kvack.org>;
        Thu, 20 Oct 2016 03:02:38 -0700 (PDT)
Date: Thu, 20 Oct 2016 11:02:34 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] mm: kmemleak: Ensure that the task stack is not freed
 during scanning
Message-ID: <20161020100234.GD23600@e104818-lin.cambridge.arm.com>
References: <1476266223-14325-1-git-send-email-catalin.marinas@arm.com>
 <20161019113327.3e796893d89333f6ebe65d79@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161019113327.3e796893d89333f6ebe65d79@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, CAI Qian <caiqian@redhat.com>

Hi Andrew,

On Wed, Oct 19, 2016 at 11:33:27AM -0700, Andrew Morton wrote:
> On Wed, 12 Oct 2016 10:57:03 +0100 Catalin Marinas <catalin.marinas@arm.com> wrote:
> > Commit 68f24b08ee89 ("sched/core: Free the stack early if
> > CONFIG_THREAD_INFO_IN_TASK") may cause the task->stack to be freed
> > during kmemleak_scan() execution, leading to either a NULL pointer
> > fault (if task->stack is NULL) or kmemleak accessing already freed
> > memory. This patch uses the new try_get_task_stack() API to ensure that
> > the task stack is not freed during kmemleak stack scanning.
> > 
> > Fixes: 68f24b08ee89 ("sched/core: Free the stack early if CONFIG_THREAD_INFO_IN_TASK")
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Andy Lutomirski <luto@kernel.org>
> > Cc: CAI Qian <caiqian@redhat.com>
> > Reported-by: CAI Qian <caiqian@redhat.com>
> > Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> 
> I'll add
> 
> Cc: <stable@vger.kernel.org>    [4.8.x]

This should be 4.9.x. The commit that introduces try_get_task_stack()
was merged in 4.9-rc1: c6c314a613cd ("sched/core: Add
try_get_task_stack() and put_task_stack()").

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
