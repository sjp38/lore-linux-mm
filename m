Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1B6758D0048
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 12:58:07 -0500 (EST)
Message-ID: <4D48498A.9040606@redhat.com>
Date: Tue, 01 Feb 2011 12:57:30 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mlock: operate on any regions with protection != PROT_NONE
References: <20110201010341.GA21676@google.com>
In-Reply-To: <20110201010341.GA21676@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tao Ma <tm@tao.ma>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

On 01/31/2011 08:03 PM, Michel Lespinasse wrote:
> As Tao Ma noticed, change 5ecfda0 breaks blktrace. This is because
> blktrace mmaps a file with PROT_WRITE permissions but without PROT_READ,
> so my attempt to not unnecessarity break COW during mlock ended up
> causing mlock to fail with a permission problem.
>
> I am proposing to let mlock ignore vma protection in all cases except
> PROT_NONE. In particular, mlock should not fail for PROT_WRITE regions
> (as in the blktrace case, which broke at 5ecfda0) or for PROT_EXEC
> regions (which seem to me like they were always broken).
>
> Please review. I am proposing this as a candidate for 2.6.38 inclusion,
> because of the behavior change with blktrace.

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
