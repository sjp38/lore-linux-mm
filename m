Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 115436B009D
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 03:42:13 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 32BCB3EE0C0
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 17:42:11 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 161F845DEBA
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 17:42:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F1D1045DEB2
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 17:42:10 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E4A111DB803C
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 17:42:10 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C74A1DB8038
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 17:42:10 +0900 (JST)
Message-ID: <50A4AAD1.3030901@jp.fujitsu.com>
Date: Thu, 15 Nov 2012 17:41:53 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch 1/4] mm, oom: ensure sysrq+f always passes valid zonelist
References: <alpine.DEB.2.00.1211140111190.32125@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1211140111190.32125@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

(2012/11/14 18:15), David Rientjes wrote:
> With hotpluggable and memoryless nodes, it's possible that node 0 will
> not be online, so use the first online node's zonelist rather than
> hardcoding node 0 to pass a zonelist with all zones to the oom killer.
>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Signed-off-by: David Rientjes <rientjes@google.com>

Thank you.
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
