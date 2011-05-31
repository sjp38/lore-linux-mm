Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3865D6B0012
	for <linux-mm@kvack.org>; Tue, 31 May 2011 06:01:22 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4EBAB3EE0C1
	for <linux-mm@kvack.org>; Tue, 31 May 2011 19:01:18 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 34AF245DF56
	for <linux-mm@kvack.org>; Tue, 31 May 2011 19:01:18 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1174C45DF4F
	for <linux-mm@kvack.org>; Tue, 31 May 2011 19:01:18 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0547E1DB803A
	for <linux-mm@kvack.org>; Tue, 31 May 2011 19:01:18 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B736C1DB802C
	for <linux-mm@kvack.org>; Tue, 31 May 2011 19:01:17 +0900 (JST)
Message-ID: <4DE4BC64.3040807@jp.fujitsu.com>
Date: Tue, 31 May 2011 19:01:08 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/5] Fix oom killer doesn't work at all if system have
 > gigabytes memory  (aka CAI founded issue)
References: <348391538.318712.1306828778575.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com> <4DE4A2A0.6090704@jp.fujitsu.com>
In-Reply-To: <4DE4A2A0.6090704@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: caiqian@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, rientjes@google.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, oleg@redhat.com

(2011/05/31 17:11), KOSAKI Motohiro wrote:
>>> Then, I believe your distro applying distro specific patch to ssh.
>>> Which distro are you using now?
>> It is a Fedora-like distro.

So, Does this makes sense?
