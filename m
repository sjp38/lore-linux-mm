Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7BC6D6B00A9
	for <linux-mm@kvack.org>; Mon,  7 Sep 2009 12:28:23 -0400 (EDT)
Message-ID: <4AA5367E.6010103@redhat.com>
Date: Mon, 07 Sep 2009 19:36:14 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] ksm: clean up obsolete references
References: <Pine.LNX.4.64.0909052219580.7381@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0909052219580.7381@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> A few cleanups, given the munlock fix: the comment on ksm_test_exit()
> no longer applies, and it can be made private to ksm.c; there's no
> more reference to mmu_gather or tlb.h, and mmap.c doesn't need ksm.h.
>
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> ---
>
>   
Acked-by: Izik Eidus <ieidus@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
