Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8A48A6B0047
	for <linux-mm@kvack.org>; Fri,  1 Oct 2010 08:08:10 -0400 (EDT)
Message-ID: <4CA5CF17.1090807@redhat.com>
Date: Fri, 01 Oct 2010 08:07:51 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] Reduce mmap_sem hold times during file backed page
 faults
References: <1285909484-30958-1-git-send-email-walken@google.com>
In-Reply-To: <1285909484-30958-1-git-send-email-walken@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Ying Han <yinghan@google.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <peterz@infradead.org>, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

On 10/01/2010 01:04 AM, Michel Lespinasse wrote:
> Linus, I would appreciate your comments on this since you shot down the
> previous proposal. I hope you'll find this approach is sane, but I would
> be interested to hear if you have specific objections.
>
> mmap_sem is very coarse grained (per process) and has long read-hold times
> (disk latencies); this breaks down rapidly for workloads that use both
> read and write mmap_sem acquires. This short patch series tries to reduce
> mmap_sem hold times when faulting in file backed VMAs.

The changes make sense to me, but it would be good to know
what kind of benefits you have seen with these patches.

Especially performance numbers :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
