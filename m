Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 42F5C6B0071
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 21:02:01 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5B11xmO012695
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 11 Jun 2010 10:01:59 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1141845DE79
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 10:01:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E149545DE60
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 10:01:58 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C4E7A1DB803A
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 10:01:58 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 705AD1DB803F
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 10:01:58 +0900 (JST)
Date: Fri, 11 Jun 2010 09:57:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] Cleanup: use for_each_online_cpu in vmstat
Message-Id: <20100611095738.ff9e5b35.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1276176526-2952-1-git-send-email-minchan.kim@gmail.com>
References: <1276176526-2952-1-git-send-email-minchan.kim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Thu, 10 Jun 2010 22:28:46 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> The sum_vm_events passes cpumask for for_each_cpu.
> But it's useless since we have for_each_online_cpu.
> Althougth it's tirival overhead, it's not good about
> coding consistency.
> 
> Let's use for_each_online_cpu instead of for_each_cpu with
> cpumask argument.
> 
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Christoph Lameter <clameter@sgi.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
