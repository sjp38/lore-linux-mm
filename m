Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id EB6F36B004D
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 16:51:20 -0400 (EDT)
Date: Thu, 17 Sep 2009 22:46:56 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: tracehooks changes && 2.6.32 -mm merge plans
Message-ID: <20090917204656.GC29346@redhat.com>
References: <20090915161535.db0a6904.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090915161535.db0a6904.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Roland McGrath <roland@redhat.com>, "Frank Ch. Eigler" <fche@redhat.com>
List-ID: <linux-mm.kvack.org>

On 09/15, Andrew Morton wrote:
>
> #signals-tracehook_notify_jctl-change.patch: needs changelog folding too
> signals-tracehook_notify_jctl-change.patch
> signals-tracehook_notify_jctl-change-do_signal_stop-do-not-call-tracehook_notify_jctl-in-task_stopped-state.patch
> #signals-introduce-tracehook_finish_jctl-helper.patch: fold into signals-tracehook_notify_jctl-change.patch
> signals-introduce-tracehook_finish_jctl-helper.patch

I think these make sense anyway,

> utrace-core.patch
>
>   utrace.  What's happening with this?

(since Roland didn't reply yet)

I guess this patch should be updated.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
