Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 29BD560021B
	for <linux-mm@kvack.org>; Sat,  2 Jan 2010 09:45:36 -0500 (EST)
Subject: Re: [PATCH] mm, lockdep: annotate reclaim context to zone reclaim
 too
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <2f11576a1001020529l729caebawc4364690f1df56cb@mail.gmail.com>
References: 
	 <1262339141-4682-1-git-send-email-kosaki.motohiro@jp.fujitsu.com>
	 <1262387986.16572.234.camel@laptop>
	 <2f11576a1001012121o4f09d30n6dba925e74099da1@mail.gmail.com>
	 <1262429166.32223.32.camel@laptop>
	 <2f11576a1001020529l729caebawc4364690f1df56cb@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 02 Jan 2010 15:45:00 +0100
Message-ID: <1262443500.6408.3.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Sat, 2010-01-02 at 22:29 +0900, KOSAKI Motohiro wrote:

> When recursive annotation occur?

Dunno, I told you you'd have to make sure it doesn't.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
