Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A28AC6B00D0
	for <linux-mm@kvack.org>; Sat, 30 May 2009 10:13:32 -0400 (EDT)
Message-ID: <4A213EFF.7030101@redhat.com>
Date: Sat, 30 May 2009 10:13:19 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page allocator
References: <20090522073436.GA3612@elte.hu>, <4A211BA8.8585.17B52182@pageexec.freemail.hu>, <1243689707.6645.134.camel@laptop> <4A213AA8.18076.182E39C1@pageexec.freemail.hu>
In-Reply-To: <4A213AA8.18076.182E39C1@pageexec.freemail.hu>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: pageexec@freemail.hu
Cc: Peter Zijlstra <peterz@infradead.org>, "Larry H." <research@subreption.com>, Arjan van de Ven <arjan@infradead.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>
List-ID: <linux-mm.kvack.org>

pageexec@freemail.hu wrote:
> On 30 May 2009 at 15:21, Peter Zijlstra wrote:

>> Can we instead of working around a problem, fix the actual problem?
> 
> finding all use-after-free bugs is not possible, as far as i know.

Not only that, but new ones get introduced all the time.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
