Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id F09736B01D7
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 17:27:07 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id o51LR3Ov012038
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 14:27:03 -0700
Received: from pvg4 (pvg4.prod.google.com [10.241.210.132])
	by wpaz5.hot.corp.google.com with ESMTP id o51LR2sw018945
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 14:27:02 -0700
Received: by pvg4 with SMTP id 4so629744pvg.28
        for <linux-mm@kvack.org>; Tue, 01 Jun 2010 14:27:02 -0700 (PDT)
Date: Tue, 1 Jun 2010 14:26:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/5] oom: select_bad_process: check PF_KTHREAD instead
 of !mm to skip kthreads
In-Reply-To: <20100601212023.GA24917@redhat.com>
Message-ID: <alpine.DEB.2.00.1006011424200.16725@chino.kir.corp.google.com>
References: <20100531182526.1843.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006011333470.13136@chino.kir.corp.google.com> <20100601212023.GA24917@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 1 Jun 2010, Oleg Nesterov wrote:

> But yes, I agree, the problem is minor. But nevertheless it is bug,
> the longstanding bug with the simple fix. Why should we "hide" this fix
> inside the long series of non-trivial patches which rewrite oom-killer?
> And it is completely orthogonal to other changes.
> 

Again, the question is whether or not the fix is rc material or not, 
otherwise there's no difference in the route that it gets upstream: the 
patch is duplicated in both series.  If you feel that this minor issue 
(which has never been reported in at least the last three years and 
doesn't have any side effects other than a couple of millisecond delay 
until unuse_mm() when the oom killer will kill something else) should be 
addressed in 2.6.35-rc2, then that's a conversation to be had with Andrew.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
