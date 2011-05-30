Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id CCBFD6B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 04:01:46 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id EFF943EE081
	for <linux-mm@kvack.org>; Mon, 30 May 2011 17:01:43 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D9AB445DE94
	for <linux-mm@kvack.org>; Mon, 30 May 2011 17:01:43 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C05F945DE78
	for <linux-mm@kvack.org>; Mon, 30 May 2011 17:01:43 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B474EE08003
	for <linux-mm@kvack.org>; Mon, 30 May 2011 17:01:43 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 814A91DB8038
	for <linux-mm@kvack.org>; Mon, 30 May 2011 17:01:43 +0900 (JST)
Date: Mon, 30 May 2011 16:54:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Bugme-new] [Bug 36192] New: Kernel panic when boot the 2.6.39+
 kernel based off of 2.6.32 kernel
Message-Id: <20110530165453.845bba09.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110530162904.b78bf354.kamezawa.hiroyu@jp.fujitsu.com>
References: <bug-36192-10286@https.bugzilla.kernel.org/>
	<20110529231948.e1439ce5.akpm@linux-foundation.org>
	<20110530160114.5a82e590.kamezawa.hiroyu@jp.fujitsu.com>
	<20110530162904.b78bf354.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, qcui@redhat.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>

On Mon, 30 May 2011 16:29:04 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Mon, 30 May 2011 16:01:14 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> 
> 
> I want to see .config and 2.6.32's boot log (dmesg) and 2.6.39+'s boot log
> if possible.
> 
Ah, sorry. The log was in bugzilla.
==
SRAT: Node 1 PXM 1 0-a0000
SRAT: Node 1 PXM 1 100000-c8000000
SRAT: Node 1 PXM 1 100000000-438000000
SRAT: Node 3 PXM 3 438000000-838000000
SRAT: Node 5 PXM 5 838000000-c38000000
SRAT: Node 7 PXM 7 c38000000-1038000000

Initmem setup node 1 0000000000000000-0000000438000000
  NODE_DATA [0000000437fd9000 - 0000000437ffffff]
Initmem setup node 3 0000000438000000-0000000838000000
  NODE_DATA [0000000837fd9000 - 0000000837ffffff]
Initmem setup node 5 0000000838000000-0000000c38000000
  NODE_DATA [0000000c37fd9000 - 0000000c37ffffff]
Initmem setup node 7 0000000c38000000-0000001038000000
  NODE_DATA [0000001037fd7000 - 0000001037ffdfff]
[ffffea000ec40000-ffffea000edfffff] potential offnode page_structs
[ffffea001cc40000-ffffea001cdfffff] potential offnode page_structs
[ffffea002ac40000-ffffea002adfffff] potential offnode page_structs
==

Hmm..there are four nodes 1,3,5,7 but....no memory on node 0 hmm ?

Could you show 2.6.32's log ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
