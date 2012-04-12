Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 8DB576B004A
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 19:55:16 -0400 (EDT)
Date: Fri, 13 Apr 2012 01:54:46 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 1/2] mm: set task exit code before complete_vfork_done()
Message-ID: <20120412235446.GA4815@redhat.com>
References: <20120409200336.8368.63793.stgit@zurg> <20120412080948.26401.23572.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120412080948.26401.23572.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Markus Trippelsdorf <markus@trippelsdorf.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 04/12, Konstantin Khlebnikov wrote:
>
> kthread_stop() uses task->vfork_done for synchronization. The exiting kthread
> shouldn't do complete_vfork_done() until it sets ->exit_code.
>
> fix for mm-correctly-synchronize-rss-counters-at-exit-exec.patch

Yes, this should fix the problem with kthread_stop()...

Damn, Konstantin I have to admit, I'll try to find another technical
reason against mm-correctly-synchronize-rss-counters-at-exit-exec.patch
even with this fix ;)

Most probably I am wrong, but it looks overcomplicated. Somehow I
dislike irrationally the fact you moved mm_release() from exit_mm().

But, once again, it is not that I see the better solution.

2/2 looks fine at first glance... and afaics it is "off-topic".

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
