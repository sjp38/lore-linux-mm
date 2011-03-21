Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 39C4F8D0039
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 20:06:09 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 154CC3EE0BC
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 09:06:06 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id F175345DE55
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 09:06:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DBFA345DE4D
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 09:06:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CE2171DB803A
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 09:06:05 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B4781DB802C
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 09:06:05 +0900 (JST)
Date: Tue, 22 Mar 2011 08:59:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] memcg: move page-freeing code outside of lock
Message-Id: <20110322085938.0691f7f4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1300452855-10194-3-git-send-email-namhyung@gmail.com>
References: <1300452855-10194-1-git-send-email-namhyung@gmail.com>
	<1300452855-10194-3-git-send-email-namhyung@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@gmail.com>
Cc: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 18 Mar 2011 21:54:15 +0900
Namhyung Kim <namhyung@gmail.com> wrote:

> Signed-off-by: Namhyung Kim <namhyung@gmail.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

What is the benefit of this patch ?

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
