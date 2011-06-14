Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4A88A6B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 14:20:29 -0400 (EDT)
Message-ID: <4DF7A658.2010009@redhat.com>
Date: Tue, 14 Jun 2011 14:20:08 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/12] tmpfs: convert from old swap vector to radix tree
References: <alpine.LSU.2.00.1106140327550.29206@sister.anvils> <BANLkTintgwYuUcMjY91gGk8G07wmWyQ1sw@mail.gmail.com>
In-Reply-To: <BANLkTintgwYuUcMjY91gGk8G07wmWyQ1sw@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Miklos Szeredi <miklos@szeredi.hu>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/14/2011 01:29 PM, Linus Torvalds wrote:
> On Tue, Jun 14, 2011 at 3:40 AM, Hugh Dickins<hughd@google.com>  wrote:
>>
>> thus saving memory, and simplifying its code and locking.
>>
>>   13 files changed, 669 insertions(+), 1144 deletions(-)
>
> Hey, I can Ack this just based on the fact that for once "simplifying
> its code" clearly also removes code. Yay! Too many times the code
> becomes "simpler" but bigger.

I looked through Hugh's patches for a while and didn't
see anything wrong with the code.  Consider all patches

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
