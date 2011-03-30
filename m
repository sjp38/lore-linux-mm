Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E73838D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 21:51:34 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id C8E583EE0AE
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 10:51:30 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id ABF4145DE95
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 10:51:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9381345DE92
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 10:51:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 86B93E08002
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 10:51:30 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E23DE08007
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 10:51:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] Stack trace dedup
In-Reply-To: <BANLkTinDON4dV9ipZYJsxBW-bENMajw-wA@mail.gmail.com>
References: <20110330102205.E925.A69D9226@jp.fujitsu.com> <BANLkTinDON4dV9ipZYJsxBW-bENMajw-wA@mail.gmail.com>
Message-Id: <20110330105204.E929.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 30 Mar 2011 10:51:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

> On Tue, Mar 29, 2011 at 6:21 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> This doesn't build.
> >> ---
> >
> > This is slightly reticence changelog. Can you please explain a purpose
> > and benefit?
> 
> Hi:
> 
> Sorry about the spam. This is a patch that I was preparing to send
> upstream but not ready yet. I don't know why it got sent out ( must be
> myself did something wrong on my keyboard ) .

No problem. I have a same experience, to be honest. 

> In a short, this eliminate the duplication of task stack trace in dump
> messages. The problem w/ fixed size of dmesg ring buffer limits how
> many task trace to be logged. When the duplication remains high, we
> lose important information. This patch reduces the duplication by
> dumping the first task stack trace only for contiguous duplications.

Seems reasonable.

> 
> I will prepare it later with full commit description.

OK, I'm looking for it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
