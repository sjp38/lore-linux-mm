Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1FBC160079C
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 19:02:28 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBA02OBI002856
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 10 Dec 2009 09:02:24 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F18445DE53
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 09:02:24 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C2B745DE4D
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 09:02:24 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 016311DB803F
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 09:02:24 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 585DC1DB803E
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 09:02:23 +0900 (JST)
Date: Thu, 10 Dec 2009 08:59:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] [TRIVIAL] memcg: fix memory.memsw.usage_in_bytes for
 root cgroup
Message-Id: <20091210085929.56c63eb2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1260373738-17179-1-git-send-email-kirill@shutemov.name>
References: <1260373738-17179-1-git-send-email-kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, linux-kernel@vger.kernel.org, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Wed,  9 Dec 2009 17:48:58 +0200
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> We really want to take MEM_CGROUP_STAT_SWAPOUT into account.
> 
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> Cc: stable@kernel.org

Thanks.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
