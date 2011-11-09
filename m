Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A1C7B6B0069
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 12:02:56 -0500 (EST)
Received: by pzk6 with SMTP id 6so2196585pzk.6
        for <linux-mm@kvack.org>; Wed, 09 Nov 2011 09:02:53 -0800 (PST)
Date: Wed, 9 Nov 2011 09:02:48 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] thp: reduce khugepaged freezing latency
Message-ID: <20111109170248.GD1260@google.com>
References: <4EB8E969.6010502@suse.cz>
 <1320766151-2619-1-git-send-email-aarcange@redhat.com>
 <1320766151-2619-2-git-send-email-aarcange@redhat.com>
 <4EB98A83.3040101@linux.vnet.ibm.com>
 <4EBA75F2.4080800@linux.vnet.ibm.com>
 <20111109155342.GA1260@google.com>
 <20111109165201.GI5075@redhat.com>
 <20111109165925.GC1260@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111109165925.GC1260@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>
Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, "Rafael J. Wysocki" <rjw@suse.com>, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, Nov 09, 2011 at 08:59:25AM -0800, Tejun Heo wrote:
> Freezer depends on the usual "set_current_state(INTERRUPTIBLE); check
> freezing; schedule(); check freezing" construct and sends
> INTERRUPTIBLE wake up after setting freezing state.  The
> synchronization hasn't been completely clear but recently been cleaned
> up, so as long as freezing condition is tested after INTERRUPTIBLE is
> set before going to sleep, the event won't go missing.

Just in case, it's scheduled for the next merge window but TIF_FREEZE
is gone now.  There is freezing() helper which tests all pending
freezing conditions and the freezer guarantees there's mb between
assertion of freezing() and sending interruptible wakeups to target
tasks.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
