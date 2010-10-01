Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7251A6B0047
	for <linux-mm@kvack.org>; Thu, 30 Sep 2010 23:43:33 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o913hSCN006452
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 1 Oct 2010 12:43:29 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A61EE45DE7A
	for <linux-mm@kvack.org>; Fri,  1 Oct 2010 12:43:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 825A445DE70
	for <linux-mm@kvack.org>; Fri,  1 Oct 2010 12:43:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 64A071DB803E
	for <linux-mm@kvack.org>; Fri,  1 Oct 2010 12:43:28 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A4E31DB803A
	for <linux-mm@kvack.org>; Fri,  1 Oct 2010 12:43:28 +0900 (JST)
Date: Fri, 1 Oct 2010 12:38:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH v2] memcg: fix thresholds with use_hierarchy ==
 1
Message-Id: <20101001123814.0b777694.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1285841792-23664-1-git-send-email-kirill@shutemov.name>
References: <1285841792-23664-1-git-send-email-kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutsemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 30 Sep 2010 13:16:32 +0300
"Kirill A. Shutsemov" <kirill@shutemov.name> wrote:

> From: Kirill A. Shutemov <kirill@shutemov.name>
> 
> We need to check parent's thresholds if parent has use_hierarchy == 1 to
> be sure that parent's threshold events will be triggered even if parent
> itself is not active (no MEM_CGROUP_EVENTS).
> 
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
