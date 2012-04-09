Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id E4FEF6B0044
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 03:53:42 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4CE063EE081
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 16:53:41 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 346C745DD78
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 16:53:41 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1DEBE45DE4D
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 16:53:41 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 113E71DB802C
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 16:53:41 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BF7461DB8038
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 16:53:40 +0900 (JST)
Message-ID: <4F8294D0.4000507@jp.fujitsu.com>
Date: Mon, 09 Apr 2012 16:50:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: Allow using fast mm counters from other files
References: <1333202997-19550-1-git-send-email-andi@firstfloor.org> <1333202997-19550-2-git-send-email-andi@firstfloor.org>
In-Reply-To: <1333202997-19550-2-git-send-email-andi@firstfloor.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, tim.c.chen@linux.intel.com, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>

(2012/03/31 23:09), Andi Kleen wrote:

> From: Andi Kleen <ak@linux.intel.com>
> 
> Allow calling inc/dec_mm_counter_fast() from other files, not just memory.c
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>


Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
