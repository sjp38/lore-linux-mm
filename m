Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E773C600473
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 19:12:50 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0J0CmmZ011076
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 19 Jan 2010 09:12:48 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4121745DE52
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 09:12:48 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EFD7545DE50
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 09:12:45 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C288E38001
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 09:12:45 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0847B1DB803C
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 09:12:45 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v6] add MAP_UNLOCKED mmap flag
In-Reply-To: <20100118151405.GD14345@redhat.com>
References: <1263827194.4283.609.camel@laptop> <20100118151405.GD14345@redhat.com>
Message-Id: <20100119091004.5F28.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 19 Jan 2010 09:12:44 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Peter Zijlstra <peterz@infradead.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org, andrew.c.morrow@gmail.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

> On Mon, Jan 18, 2010 at 04:06:34PM +0100, Peter Zijlstra wrote:
> > On Mon, 2010-01-18 at 17:01 +0200, Gleb Natapov wrote:
> > > There are valid uses for mlockall()
> > 
> > That's debatable.
> > 
> Well, I have use for it. You can look at previous thread were I described
> it and suggest alternatives.

Please stop suck.
This is the reviewing. The reviewers shouldn't need to look at all
previous thread. It mean your description isn't enough.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
