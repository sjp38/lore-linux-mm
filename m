Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 40E0C900138
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 05:22:36 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 90B823EE0C1
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 18:22:33 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7148745DEB3
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 18:22:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5902A45DE9E
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 18:22:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 478121DB803B
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 18:22:33 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FF3A1DB803E
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 18:22:33 +0900 (JST)
Date: Thu, 8 Sep 2011 18:21:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: drain all stocks for the cgroup before read
 usage
Message-Id: <20110908182155.f4701bbf.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110908004906.GA8499@shutemov.name>
References: <1315098933-29464-1-git-send-email-kirill@shutemov.name>
	<20110905085913.8f84278e.kamezawa.hiroyu@jp.fujitsu.com>
	<20110905101607.cd946a46.nishimura@mxp.nes.nec.co.jp>
	<20110907213340.GA7690@shutemov.name>
	<20110908091914.6daeab1e.kamezawa.hiroyu@jp.fujitsu.com>
	<20110908004906.GA8499@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 8 Sep 2011 03:49:07 +0300
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Thu, Sep 08, 2011 at 09:19:14AM +0900, KAMEZAWA Hiroyuki wrote:
> > > Should we have field 'ram' (or 'memory') for rss+cache in memory.stat?
> > > 
> > 
> > Why do you think so ?
> 
> It may be useful for scripting purpose. Just an idea.
> 

Hmm, if you really want, please post a patch.
(in other thread)
I have no strong objection.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
