Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 4B0CB6B0069
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 14:04:54 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id tr6so1483924ieb.28
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 11:04:54 -0700 (PDT)
Received: from relay.sgi.com (relay3.sgi.com. [192.48.152.1])
        by mx.google.com with ESMTP id em5si3690623icb.55.2014.10.23.11.04.53
        for <linux-mm@kvack.org>;
        Thu, 23 Oct 2014 11:04:53 -0700 (PDT)
Date: Thu, 23 Oct 2014 13:05:19 -0500
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: [PATCH 0/4] Convert khugepaged to a task_work function
Message-ID: <20141023180519.GE15104@sgi.com>
References: <1414032567-109765-1-git-send-email-athorlton@sgi.com>
 <54494101.6010701@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54494101.6010701@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Alex Thorlton <athorlton@sgi.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <lliubbo@gmail.com>, David Rientjes <rientjes@google.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, Kees Cook <keescook@chromium.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Vladimir Davydov <vdavydov@parallels.com>, linux-kernel@vger.kernel.org

On Thu, Oct 23, 2014 at 01:55:13PM -0400, Rik van Riel wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> On 10/22/2014 10:49 PM, Alex Thorlton wrote:
> 
> > Alex Thorlton (4): Disable khugepaged thread Add pgcollapse
> > controls to task_struct Convert khugepaged scan functions to work
> > with task_work Add /proc files to expose per-mm pgcollapse stats
> 
> Is it just me, or did the third patch never show up in other people's
> email either?
> 
> I don't see it in my inbox, my lkml folder, my linux-mm folder, or
> on lkml.org

That's, more than likely, my fault.  I seem to be a pro at messing up
with git send-email :/  Everything showed up properly in my e-mail, but
it does look screwy on lkml.org.  I'll double check everything and do a
resend here shortly.

Sorry about that!

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
