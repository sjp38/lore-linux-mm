Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 930C3900019
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 11:28:54 -0400 (EDT)
Received: by mail-ie0-f178.google.com with SMTP id rl12so1204153iec.9
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 08:28:54 -0700 (PDT)
Received: from relay.sgi.com (relay3.sgi.com. [192.48.152.1])
        by mx.google.com with ESMTP id m4si3119718igx.47.2014.10.23.08.28.53
        for <linux-mm@kvack.org>;
        Thu, 23 Oct 2014 08:28:54 -0700 (PDT)
Date: Thu, 23 Oct 2014 10:29:19 -0500
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: [PATCH] Add pgcollapse controls to task_struct
Message-ID: <20141023152919.GB15104@sgi.com>
References: <1414032567-109765-1-git-send-email-athorlton@sgi.com>
 <1414032567-109765-3-git-send-email-athorlton@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1414032567-109765-3-git-send-email-athorlton@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, athorlton@sgi.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Bob Liu <lliubbo@gmail.com>, David Rientjes <rientjes@google.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, Kees Cook <keescook@chromium.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Vladimir Davydov <vdavydov@parallels.com>, linux-kernel@vger.kernel.org

On Wed, Oct 22, 2014 at 09:49:25PM -0500, Alex Thorlton wrote:
> This patch just adds the necessary bits to the task_struct so that the scans can
> eventually be controlled on a per-mm basis.  As I mentioned previously, we might
> want to add some more counters here.

Just noticed that this one didn't get properly numbered when I split
them out.  This should be patch 2/4 for the first set that I sent. Sorry
about that!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
