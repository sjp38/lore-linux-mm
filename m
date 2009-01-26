Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 571D86B0044
	for <linux-mm@kvack.org>; Sun, 25 Jan 2009 22:09:18 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0Q39F28021608
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 26 Jan 2009 12:09:15 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3BDBF45DD7D
	for <linux-mm@kvack.org>; Mon, 26 Jan 2009 12:09:15 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F7B545DD78
	for <linux-mm@kvack.org>; Mon, 26 Jan 2009 12:09:15 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E3E921DB803B
	for <linux-mm@kvack.org>; Mon, 26 Jan 2009 12:09:14 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A0F2F1DB803E
	for <linux-mm@kvack.org>; Mon, 26 Jan 2009 12:09:14 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] x86,mm: fix pte_free()
In-Reply-To: <20090123174543.GA16348@elte.hu>
References: <1232732387.4850.1.camel@laptop> <20090123174543.GA16348@elte.hu>
Message-Id: <20090127120636.1BDF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 26 Jan 2009 12:09:13 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: kosaki.motohiro@jp.fujitsu.com, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, L-K <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Howells <dhowells@redhat.com>
List-ID: <linux-mm.kvack.org>

> 
> * Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > On Fri, 2009-01-23 at 18:34 +0100, Ingo Molnar wrote:
> > 
> > > So i agree with the fix, but the patch does not look right: shouldnt that 
> > > be pgtable_page_dtor(pte), so that we get ->mapping cleared via 
> > > pte_lock_deinit()? (which i guess your intention was here - this probably 
> > > wont even build)
> > 
> > Yeah, I somehow fudged it, already send out a better one. -- One of them
> > days I guess :-(
> 
> no problem - applied to tip/x86/urgent, thanks Peter!

please fix typo. s/nm10300/MN10300/ :)
at first look, I don't understand his intention.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
