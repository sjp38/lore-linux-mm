Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 25BC66B0044
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 20:38:22 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBF1cH0G004065
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 15 Dec 2009 10:38:17 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1BF6C45DE51
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 10:38:17 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E0D7E45DE4E
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 10:38:16 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C93CB1DB803E
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 10:38:16 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7ED0E1DB8038
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 10:38:16 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] oom-kill: fix NUMA consraint check with nodemask v4.2
In-Reply-To: <20091215103202.eacfd64e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091214171632.0b34d833.akpm@linux-foundation.org> <20091215103202.eacfd64e.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20091215103739.CDCA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 15 Dec 2009 10:38:15 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Mon, 14 Dec 2009 17:16:32 -0800
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > 
> > So I have a note-to-self here that these patches:
> > 
> > oom_kill-use-rss-value-instead-of-vm-size-for-badness.patch
> > oom-kill-show-virtual-size-and-rss-information-of-the-killed-process.patch
> > oom-kill-fix-numa-consraint-check-with-nodemask-v42.patch
> > 
> > are tentative and it was unclear whether I should merge them.
> > 
> > What do we think?
> 
> In my view,
>   oom-kill-show-virtual-size-and-rss-information-of-the-killed-process.patch
>   - should be merged.
> 
>   oom-kill-fix-numa-consraint-check-with-nodemask-v42.patch
>   - should be merged.
> 
>   oom_kill-use-rss-value-instead-of-vm-size-for-badness.patch
>   - should not be merged.

all agree.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
