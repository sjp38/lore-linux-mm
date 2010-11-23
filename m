Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 22A3D6B0093
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 02:17:04 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAN7H1hh028391
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 23 Nov 2010 16:17:01 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7CF1845DE51
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:17:01 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 622FC45DE53
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:17:01 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C74C1DB8015
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:17:01 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 15C6D1DB8014
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:17:00 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch] oom: document obsolete oom_adj tunable
In-Reply-To: <alpine.DEB.2.00.1011150234530.2986@chino.kir.corp.google.com>
References: <20101115091908.BEEB.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1011150234530.2986@chino.kir.corp.google.com>
Message-Id: <20101123161210.7BA8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Tue, 23 Nov 2010 16:16:59 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Alan Cox <alan@lxorguk.ukuu.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Mon, 15 Nov 2010, KOSAKI Motohiro wrote:
> 
> > > /proc/pid/oom_adj was deprecated in August 2010 with the introduction of
> > > the new oom killer heuristic.
> > > 
> > > This patch copies the Documentation/feature-removal-schedule.txt entry
> > > for this tunable to the Documentation/ABI/obsolete directory so nobody
> > > misses it.
> > > 
> > > Reported-by: Alan Cox <alan@lxorguk.ukuu.org.uk>
> > > Signed-off-by: David Rientjes <rientjes@google.com>
> > 
> > NAK. You seems to think shouting claim makes some effect. but It's incorrect.
> > Your childish shout doesn't solve any real world issue. Only code fix does.
> > 
> 
> The tunable is deprecated.  If you are really that concerned about the 
> existing users who you don't think can convert in the next two years, why 
> don't you help them convert?  That fixes the issue, but you're not 
> interested in that.  I offered to convert any open-source users you can 
> list (the hardest part of the conversion is finding who to send patches to 
> :).  You're only interested in continuing to assert your position as 
> correct even when the kernel is obviously moving in a different direction.

Why don't you change by _your_ hand? 

_Usually_ userland software changed at first _by_ who wanted the change.
Example, we fujitsu changed elf core file format when vma are >65536, but
It was not made any breakage. we changed gdb, binutils, elfutils and etc etc
_at_ first.




> 
> Others may have a different opinion of who is being childish in this whole 
> ordeal.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
