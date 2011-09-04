Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id B13EB6B020C
	for <linux-mm@kvack.org>; Sun,  4 Sep 2011 20:06:51 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 6A3943EE0BC
	for <linux-mm@kvack.org>; Mon,  5 Sep 2011 09:06:48 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E86145DF48
	for <linux-mm@kvack.org>; Mon,  5 Sep 2011 09:06:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 36C5D45DF46
	for <linux-mm@kvack.org>; Mon,  5 Sep 2011 09:06:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 258A41DB803B
	for <linux-mm@kvack.org>; Mon,  5 Sep 2011 09:06:48 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E53C41DB802F
	for <linux-mm@kvack.org>; Mon,  5 Sep 2011 09:06:47 +0900 (JST)
Date: Mon, 5 Sep 2011 08:59:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: drain all stocks for the cgroup before read
 usage
Message-Id: <20110905085913.8f84278e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1315098933-29464-1-git-send-email-kirill@shutemov.name>
References: <1315098933-29464-1-git-send-email-kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun,  4 Sep 2011 04:15:33 +0300
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> From: "Kirill A. Shutemov" <kirill@shutemov.name>
> 
> Currently, mem_cgroup_usage() for non-root cgroup returns usage
> including stocks.
> 
> Let's drain all socks before read resource counter value. It makes
> memory{,.memcg}.usage_in_bytes and memory.stat consistent.
> 
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>

Hmm. This seems costly to me. 

If a user chesk usage_in_bytes in a memcg once per 1sec, 
the kernel will call schedule_work on cpus once per 1sec.
So, IMHO, I don't like this.

But if some other guys want this, I'll ack.

BTW, how this affects memory.stat ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
