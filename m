Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 51CB08D0039
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 01:02:56 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 4485B3EE0B6
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 14:02:50 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2774145DE61
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 14:02:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E56E45DE4E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 14:02:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0023C1DB803E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 14:02:50 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C2B151DB8038
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 14:02:49 +0900 (JST)
Date: Tue, 22 Mar 2011 13:56:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] memcg: move page-freeing code outside of lock
Message-Id: <20110322135619.90593f5d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1300763079.1483.21.camel@leonhard>
References: <1300452855-10194-1-git-send-email-namhyung@gmail.com>
	<1300452855-10194-3-git-send-email-namhyung@gmail.com>
	<20110322085938.0691f7f4.kamezawa.hiroyu@jp.fujitsu.com>
	<1300763079.1483.21.camel@leonhard>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@gmail.com>
Cc: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 22 Mar 2011 12:04:39 +0900
Namhyung Kim <namhyung@gmail.com> wrote:

> 2011-03-22 (i??), 08:59 +0900, KAMEZAWA Hiroyuki:
> > On Fri, 18 Mar 2011 21:54:15 +0900
> > Namhyung Kim <namhyung@gmail.com> wrote:
> > 
> > > Signed-off-by: Namhyung Kim <namhyung@gmail.com>
> > > Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > What is the benefit of this patch ?
> > 
> > -Kame
> > 
> 
> Oh, I just thought generally it'd better call such a (potentially)
> costly function outside of locks and it could reduce few of theoretical
> contentions between swapons and/or offs. If it doesn't help any
> realistic cases I don't mind discarding it.
> 

My point is, please write patch description which shows for what this patc is.
All cleanup are okay to me if it reasonable. But without patch description as
"this is just a cleanup, no functional change, and the reason is...."
we cannot maintain patches.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
