Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id ACB9A6B00AC
	for <linux-mm@kvack.org>; Mon,  7 Sep 2009 12:34:31 -0400 (EDT)
Message-ID: <4AA537E9.8030800@redhat.com>
Date: Mon, 07 Sep 2009 19:42:17 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] ksm: unmerge is an origin of OOMs
References: <Pine.LNX.4.64.0909052219580.7381@sister.anvils> <Pine.LNX.4.64.0909052222430.7387@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0909052222430.7387@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> Just as the swapoff system call allocates many pages of RAM to various
> processes, perhaps triggering OOM, so "echo 2 >/sys/kernel/mm/ksm/run"
> (unmerge) is liable to allocate many pages of RAM to various processes,
> perhaps triggering OOM; and each is normally run from a modest admin
> process (swapoff or shell), easily repeated until it succeeds.
>
> So treat unmerge_and_remove_all_rmap_items() in the same way that we
> treat try_to_unuse(): generalize PF_SWAPOFF to PF_OOM_ORIGIN, and
> bracket both with that, to ask the OOM killer to kill them first,
> to prevent them from spawning more and more OOM kills.
>
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> ---
>   

Acked-by: Izik Eidus <ieidus@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
