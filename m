Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 18A448D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 04:42:48 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id BFF073EE0AE
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 18:42:40 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A7E9B45DE4F
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 18:42:40 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 90ACE45DE50
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 18:42:40 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 81D711DB8037
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 18:42:40 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C7271DB8040
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 18:42:40 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] page-types.c: add a new argument of debugfs path
In-Reply-To: <1299487900-7792-1-git-send-email-gong.chen@linux.intel.com>
References: <1299487900-7792-1-git-send-email-gong.chen@linux.intel.com>
Message-Id: <20110307184133.8A19.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  7 Mar 2011 18:42:39 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gong <gong.chen@linux.intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, fengguang.wu@intel.com, linux-kernel@vger.kernel.orgWu Fengguang <fengguang.wu@intel.com>

> page-types.c doesn't supply a way to specify the debugfs path and
> the original debugfs path is not usual on most machines. Add a
> new argument to set the debugfs path easily.
> 
> Signed-off-by: Chen Gong <gong.chen@linux.intel.com>

Hi

Why do we need to set debugfs path manually? Instead I'd suggested to
read /proc/mount and detect it automatically.

Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
