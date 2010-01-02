Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BB9DF60021B
	for <linux-mm@kvack.org>; Sat,  2 Jan 2010 10:09:34 -0500 (EST)
Received: by iwn41 with SMTP id 41so9662573iwn.12
        for <linux-mm@kvack.org>; Sat, 02 Jan 2010 07:09:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1262443500.6408.3.camel@laptop>
References: <1262339141-4682-1-git-send-email-kosaki.motohiro@jp.fujitsu.com>
	 <1262387986.16572.234.camel@laptop>
	 <2f11576a1001012121o4f09d30n6dba925e74099da1@mail.gmail.com>
	 <1262429166.32223.32.camel@laptop>
	 <2f11576a1001020529l729caebawc4364690f1df56cb@mail.gmail.com>
	 <1262443500.6408.3.camel@laptop>
Date: Sun, 3 Jan 2010 00:09:32 +0900
Message-ID: <2f11576a1001020709m106b16fcqa15ee41a1a8e22a@mail.gmail.com>
Subject: Re: [PATCH] mm, lockdep: annotate reclaim context to zone reclaim too
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

2010/1/2 Peter Zijlstra <peterz@infradead.org>:
> On Sat, 2010-01-02 at 22:29 +0900, KOSAKI Motohiro wrote:
>
>> When recursive annotation occur?
>
> Dunno, I told you you'd have to make sure it doesn't.

Please see PF_MEMALLOC turning on/off operation points. all
PF_MEMALLOC turing on point prevent recersive already.
(because, otherwise we lost PF_MEMALLOC and makes deadlock...)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
