Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 7166B6B004F
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 01:31:03 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id F1E073EE0BB
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 15:31:01 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BEBCB45DF68
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 15:31:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3BA3845DF61
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 15:31:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 273551DB803F
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 15:31:01 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C6498EF8003
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 15:31:00 +0900 (JST)
Date: Mon, 26 Dec 2011 15:29:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/6] memcg: remove unused variable
Message-Id: <20111226152941.198b6461.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1324695619-5537-3-git-send-email-kirill@shutemov.name>
References: <1324695619-5537-1-git-send-email-kirill@shutemov.name>
	<1324695619-5537-3-git-send-email-kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.linux-foundation.org, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

On Sat, 24 Dec 2011 05:00:16 +0200
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> From: "Kirill A. Shutemov" <kirill@shutemov.name>
> 
> mm/memcontrol.c: In function ‘mc_handle_file_pte’:
> mm/memcontrol.c:5206:16: warning: variable ‘inode’ set but not used [-Wunused-but-set-variable]
> 
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>

nice.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
