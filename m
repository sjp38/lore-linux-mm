Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 108526B0253
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 19:03:22 -0400 (EDT)
Received: by ieik3 with SMTP id k3so32877627iei.3
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 16:03:21 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p103si14929251ioi.92.2015.07.13.16.03.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jul 2015 16:03:21 -0700 (PDT)
Date: Mon, 13 Jul 2015 16:03:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4] mm: Increase SWAP_CLUSTER_MAX to batch TLB flushes
Message-Id: <20150713160319.b4cd79d4147679f2e7538cef@linux-foundation.org>
In-Reply-To: <20150709081425.GU6812@suse.de>
References: <1436189996-7220-1-git-send-email-mgorman@suse.de>
	<1436189996-7220-5-git-send-email-mgorman@suse.de>
	<20150707162526.c8a5e49db01a72a6dcdcf84f@linux-foundation.org>
	<20150709081425.GU6812@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 9 Jul 2015 09:14:25 +0100 Mel Gorman <mgorman@suse.de> wrote:

> Overall, I would say that none of these workloads justify the patch on
> its own. Reducing IPIs further is nice but we got the bulk of the
> benefit from the two batching patches and after that other factors
> dominate. Based on the results I have, I'd be ok with the patch being
> dropped. It can be reconsidered for evaluation if someone complains
> about excessive IPIs again on reclaim intensive workloads.

OK, thanks.  The benefit is small and there is some risk of
unanticipated problems.  I think I'll park the patch in -mm for now and
will wait to see if something happens.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
