Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 36A5A60021B
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 20:16:59 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBA1Gu7l000841
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 10 Dec 2009 10:16:56 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C867745DE64
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 10:16:55 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 937A345DE62
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 10:16:55 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 75C281DB8048
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 10:16:55 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F9C91DB8041
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 10:16:55 +0900 (JST)
Date: Thu, 10 Dec 2009 10:13:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] [TRIVIAL] memcg: fix memory.memsw.usage_in_bytes for
 root cgroup
Message-Id: <20091210101355.d94988cf.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091209162109.567ff5fa.akpm@linux-foundation.org>
References: <1260373738-17179-1-git-send-email-kirill@shutemov.name>
	<20091210085929.56c63eb2.kamezawa.hiroyu@jp.fujitsu.com>
	<20091209162109.567ff5fa.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, linux-kernel@vger.kernel.org, stable@kernel.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 9 Dec 2009 16:21:09 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Thu, 10 Dec 2009 08:59:29 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Wed,  9 Dec 2009 17:48:58 +0200
> > "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> > 
> > > We really want to take MEM_CGROUP_STAT_SWAPOUT into account.
> > > 
> > > Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> > > Cc: stable@kernel.org
> > 
> > Thanks.
> > 
> > Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> 
> Is this bug sufficiently serious to justify a -stable backport?
> 
I think so.

> If so, why?
> 

memory cgroup has a file memory.memsw.usage_in_bytes file. It shows sum of
the usage of pages and swapents in the cgroup.  Now, root cgroup's 
memsw.usage_in_bytes shows wrong value....the number of swapents are not
added. This patch fixesi it.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
