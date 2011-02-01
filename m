Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 037D08D004B
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 11:48:29 -0500 (EST)
Message-ID: <4D483954.20600@redhat.com>
Date: Tue, 01 Feb 2011 11:48:20 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] Allow GUP to fail instead of waiting on a page.
References: <1296559307-14637-1-git-send-email-gleb@redhat.com> <1296559307-14637-2-git-send-email-gleb@redhat.com>
In-Reply-To: <1296559307-14637-2-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: avi@redhat.com, mtosatti@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 02/01/2011 06:21 AM, Gleb Natapov wrote:
> GUP user may want to try to acquire a reference to a page if it is already
> in memory, but not if IO, to bring it in, is needed. For example KVM may
> tell vcpu to schedule another guest process if current one is trying to
> access swapped out page. Meanwhile, the page will be swapped in and the
> guest process, that depends on it, will be able to run again.
>
> This patch adds FAULT_FLAG_RETRY_NOWAIT (suggested by Linus) and
> FOLL_NOWAIT follow_page flags. FAULT_FLAG_RETRY_NOWAIT, when used in
> conjunction with VM_FAULT_ALLOW_RETRY, indicates to handle_mm_fault that
> it shouldn't drop mmap_sem and wait on a page, but return VM_FAULT_RETRY
> instead.
>
> Signed-off-by: Gleb Natapov<gleb@redhat.com>
> CC: Linus Torvalds<torvalds@linux-foundation.org>
> CC: Rik van Riel<riel@redhat.com>
> CC: Hugh Dickins<hughd@google.com>
> CC: Andrew Morton<akpm@linux-foundation.org>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
