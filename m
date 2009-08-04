Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5F5E36B005C
	for <linux-mm@kvack.org>; Tue,  4 Aug 2009 15:01:49 -0400 (EDT)
Message-ID: <4A788D95.9070107@redhat.com>
Date: Tue, 04 Aug 2009 22:35:49 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 12/12] ksm: remove VM_MERGEABLE_FLAGS
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils> <Pine.LNX.4.64.0908031321380.16754@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0908031321380.16754@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> KSM originally stood for Kernel Shared Memory: but the kernel has long
> supported shared memory, and VM_SHARED and VM_MAYSHARE vmas, and KSM is
> something else.  So we switched to saying "merge" instead of "share".
>
> But Chris Wright points out that this is confusing where mmap.c merges
> adjacent vmas: most especially in the name VM_MERGEABLE_FLAGS, used by
> is_mergeable_vma() to let vmas be merged despite flags being different.
>
> Call it VMA_MERGE_DESPITE_FLAGS?  Perhaps, but at present it consists
> only of VM_CAN_NONLINEAR: so for now it's clearer on all sides to use
> that directly, with a comment on it in is_mergeable_vma().
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
