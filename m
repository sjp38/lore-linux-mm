Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 23F9F6B004A
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 03:53:00 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C172C3EE0BD
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 16:52:53 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A803145DE97
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 16:52:53 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8FE3345DE94
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 16:52:53 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 757A01DB804B
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 16:52:53 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 03D531DB8046
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 16:52:53 +0900 (JST)
Message-ID: <4DF1CD47.10906@jp.fujitsu.com>
Date: Fri, 10 Jun 2011 16:52:39 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Make GFP_DMA allocations w/o ZONE_DMA emit a warning
 instead of failing
References: <1306922672-9012-1-git-send-email-dbaryshkov@gmail.com>	<BANLkTinBkdVd90g3-uiQP41z1S1sXUdRmQ@mail.gmail.com>	<BANLkTikrRRzGLbMD47_xJz+xpgftCm1C2A@mail.gmail.com>	<alpine.DEB.2.00.1106011017260.13089@chino.kir.corp.google.com>	<20110601181918.GO3660@n2100.arm.linux.org.uk>	<alpine.LFD.2.02.1106012043080.3078@ionos>	<alpine.DEB.2.00.1106011205410.17065@chino.kir.corp.google.com>	<alpine.LFD.2.02.1106012134120.3078@ionos>	<4DF1C9DE.4070605@jp.fujitsu.com> <20110610004331.13672278.akpm@linux-foundation.org>
In-Reply-To: <20110610004331.13672278.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: tglx@linutronix.de, rientjes@google.com, linux@arm.linux.org.uk, dbaryshkov@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, pavel@ucw.cz

(2011/06/10 16:43), Andrew Morton wrote:
> On Fri, 10 Jun 2011 16:38:06 +0900 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
>> Subject: [PATCH] Revert "mm: fail GFP_DMA allocations when ZONE_DMA is not configured"
> 
> Confused.  We reverted this over a week ago.

Oh, I'm sorry. I missed it. Please forget my stupid mail.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
