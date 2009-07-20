Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 668F86B005A
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 14:11:16 -0400 (EDT)
Message-ID: <4A64B342.8070002@redhat.com>
Date: Mon, 20 Jul 2009 14:11:14 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 05/10] ksm: no debug in page_dup_rmap()
References: <1247851850-4298-1-git-send-email-ieidus@redhat.com> <1247851850-4298-2-git-send-email-ieidus@redhat.com> <1247851850-4298-3-git-send-email-ieidus@redhat.com> <1247851850-4298-4-git-send-email-ieidus@redhat.com> <1247851850-4298-5-git-send-email-ieidus@redhat.com> <1247851850-4298-6-git-send-email-ieidus@redhat.com>
In-Reply-To: <1247851850-4298-6-git-send-email-ieidus@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: akpm@linux-foundation.org, hugh.dickins@tiscali.co.uk, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Izik Eidus wrote:
> From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> 
> page_dup_rmap(), used on each mapped page when forking,  was originally
> just an inline atomic_inc of mapcount.  2.6.22 added CONFIG_DEBUG_VM
> out-of-line checks to it, which would need to be ever-so-slightly
> complicated to allow for the PageKsm() we're about to define.
> 
> But I think these checks never caught anything.  And if it's coding
> errors we're worried about, such checks should be in page_remove_rmap()
> too, not just when forking; whereas if it's pagetable corruption we're
> worried about, then they shouldn't be limited to CONFIG_DEBUG_VM.

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
