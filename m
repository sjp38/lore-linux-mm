Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6ACF78D003B
	for <linux-mm@kvack.org>; Sun, 24 Apr 2011 22:35:40 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 285743EE0C0
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 11:35:35 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CC7C145DE4E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 11:35:34 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B14C945DE4D
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 11:35:34 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 965DB1DB802F
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 11:35:34 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5CED81DB8037
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 11:35:34 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] trace: Add tracepoints to fs subsystem
In-Reply-To: <1303513209-26436-1-git-send-email-vnagarnaik@google.com>
References: <1303513209-26436-1-git-send-email-vnagarnaik@google.com>
Message-Id: <20110425113723.2666.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 25 Apr 2011 11:35:33 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vaibhav Nagarnaik <vnagarnaik@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Steven Rostedt <rostedt@goodmis.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@redhat.com>, Michael Rubin <mrubin@google.com>, David Sharp <dhsharp@google.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Jiaying Zhang <jiayingz@google.com>

> From: Jiaying Zhang <jiayingz@google.com>
> 
> Many fs tracepoints can now be traced via ftrace, however there are a
> few other tracepoints needed. This patch adds entry and exit tracepoints
> for a few additional functions, viz.:
> wait_on_buffer
> block_write_full_page
> mpage_readpages
> file_read

Zero background description?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
