Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 058246B002C
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 01:45:29 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 827743EE0C8
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 14:45:25 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F37A45DE87
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 14:45:25 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 49CB045DE61
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 14:45:25 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B4931DB803A
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 14:45:25 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E245C1DB803C
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 14:45:24 +0900 (JST)
Date: Thu, 13 Oct 2011 14:44:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v6 1/8] Basic kernel memory functionality for the Memory
 Controller
Message-Id: <20111013144430.636ee7e2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1318242268-2234-2-git-send-email-glommer@parallels.com>
References: <1318242268-2234-1-git-send-email-glommer@parallels.com>
	<1318242268-2234-2-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org

On Mon, 10 Oct 2011 14:24:21 +0400
Glauber Costa <glommer@parallels.com> wrote:

> This patch lays down the foundation for the kernel memory component
> of the Memory Controller.
> 
> As of today, I am only laying down the following files:
> 
>  * memory.independent_kmem_limit
>  * memory.kmem.limit_in_bytes (currently ignored)
>  * memory.kmem.usage_in_bytes (always zero)
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Reviewed-by: Kirill A. Shutemov <kirill@shutemov.name>
> CC: Paul Menage <paul@paulmenage.org>
> CC: Greg Thelen <gthelen@google.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
