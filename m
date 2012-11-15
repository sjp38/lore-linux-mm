Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 21F516B0072
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 21:06:44 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 315C43EE0AE
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 11:06:42 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 18FC345DE59
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 11:06:42 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 01BB745DE54
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 11:06:42 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E84D3E08002
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 11:06:41 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A1EC51DB803F
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 11:06:41 +0900 (JST)
Message-ID: <50A44E0F.6030404@jp.fujitsu.com>
Date: Thu, 15 Nov 2012 11:06:07 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] res_counter: delete res_counter_write()
References: <1352938017-32568-1-git-send-email-gthelen@google.com>
In-Reply-To: <1352938017-32568-1-git-send-email-gthelen@google.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Frederic Weisbecker <fweisbec@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

(2012/11/15 9:06), Greg Thelen wrote:
> Since 628f423553 "memcg: limit change shrink usage" both
> res_counter_write() and write_strategy_fn have been unused.  This
> patch deletes them both.
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>

Thank you
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
