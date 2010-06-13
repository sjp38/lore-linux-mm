Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 86F456B01B0
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 07:24:53 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5DBOp4j022624
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 13 Jun 2010 20:24:51 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D60AD45DE52
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:50 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B57B045DE51
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:50 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9BDE21DB803F
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:50 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 572A31DB8038
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [mmotm] Cleanup: use for_each_online_cpu in vmstat
In-Reply-To: <1276176751-2990-1-git-send-email-minchan.kim@gmail.com>
References: <1276176751-2990-1-git-send-email-minchan.kim@gmail.com>
Message-Id: <20100613162540.6157.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Sun, 13 Jun 2010 20:24:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>
List-ID: <linux-mm.kvack.org>

> Sorry. It's not [1/2] and I used Chrisopth's old mail address.
> Resend. 
> 
> --
> 
> The sum_vm_events passes cpumask for for_each_cpu.
> But it's useless since we have for_each_online_cpu.
> Althougth it's tirival overhead, it's not good about
> coding consistency.
> 
> Let's use for_each_online_cpu instead of for_each_cpu with
> cpumask argument.
> 
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Christoph Lameter <cl@linux.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

Thank you.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
