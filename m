Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0EC236B004D
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 06:27:59 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n96ARv69031631
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 6 Oct 2009 19:27:58 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C87945DE56
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 19:27:57 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C46845DE55
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 19:27:57 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C9F2E1800B
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 19:27:57 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A5F4E1801A
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 19:27:56 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH][RFC] add MAP_UNLOCKED mmap flag
In-Reply-To: <20091006102136.GH9832@redhat.com>
References: <20091006190938.126F.A69D9226@jp.fujitsu.com> <20091006102136.GH9832@redhat.com>
Message-Id: <20091006192454.1272.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  6 Oct 2009 19:27:56 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> On Tue, Oct 06, 2009 at 07:11:06PM +0900, KOSAKI Motohiro wrote:
> > Hi
> > 
> > > If application does mlockall(MCL_FUTURE) it is no longer possible to
> > > mmap file bigger than main memory or allocate big area of anonymous
> > > memory. Sometimes it is desirable to lock everything related to program
> > > execution into memory, but still be able to mmap big file or allocate
> > > huge amount of memory and allow OS to swap them on demand. MAP_UNLOCKED
> > > allows to do that.
> > > 
> > > Signed-off-by: Gleb Natapov <gleb@redhat.com>
> > 
> > Why don't you use explicit munlock()?
> Because mmap will fail before I'll have a chance to run munlock on it.
> Actually when I run my process inside memory limited container host dies
> (I suppose trashing, but haven't checked).
> 
> > Plus, Can you please elabrate which workload nedd this feature?
> > 
> I wanted to run kvm with qemu process locked in memory, but guest memory
> unlocked. And guest memory is bigger then host memory in the case I am
> testing. I found out that it is impossible currently.

1. process creation (qemu)
2. load all library
3. mlockall(MCL_CURRENT)
4. load guest OS

is impossible? why?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
