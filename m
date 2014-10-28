Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 87219900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 08:12:35 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id g10so558881pdj.24
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 05:12:35 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id tv2si1245868pac.25.2014.10.28.05.12.33
        for <linux-mm@kvack.org>;
        Tue, 28 Oct 2014 05:12:34 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 0/4] Convert khugepaged to a task_work function
References: <1414032567-109765-1-git-send-email-athorlton@sgi.com>
Date: Tue, 28 Oct 2014 05:12:26 -0700
In-Reply-To: <1414032567-109765-1-git-send-email-athorlton@sgi.com> (Alex
	Thorlton's message of "Wed, 22 Oct 2014 21:49:23 -0500")
Message-ID: <87lho0pf4l.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <lliubbo@gmail.com>, David Rientjes <rientjes@google.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, Kees Cook <keescook@chromium.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Vladimir Davydov <vdavydov@parallels.com>, linux-kernel@vger.kernel.org

Alex Thorlton <athorlton@sgi.com> writes:

> Last week, while discussing possible fixes for some unexpected/unwanted behavior
> from khugepaged (see: https://lkml.org/lkml/2014/10/8/515) several people
> mentioned possibly changing changing khugepaged to work as a task_work function
> instead of a kernel thread.  This will give us finer grained control over the
> page collapse scans, eliminate some unnecessary scans since tasks that are
> relatively inactive will not be scanned often, and eliminate the unwanted
> behavior described in the email thread I mentioned.

With your change, what would happen in a single threaded case?

Previously one core would scan and another would run the workload.
With your change both scanning and running would be on the same
core.

Would seem like a step backwards to me.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
