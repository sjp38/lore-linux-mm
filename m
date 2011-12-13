Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 7588B6B028E
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 17:58:53 -0500 (EST)
Date: Tue, 13 Dec 2011 14:58:51 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4] oom: add trace points for debugging.
Message-Id: <20111213145851.c7e5d8fa.akpm@linux-foundation.org>
In-Reply-To: <20111213181225.673e19db.kamezawa.hiroyu@jp.fujitsu.com>
References: <20111213181225.673e19db.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, rientjes@google.com

On Tue, 13 Dec 2011 18:12:25 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Changelog:
>  - devided into oom tracepoint and task tracepoint.
>  - task tracepoint traces fork/rename
>  - oom tracepoint traces modification to oom_score_adj.
> 
> dropped acks because of total design changes.
> 
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Subject: [PATCH] tracepoint: add tracepoints for debugging oom_score_adj.
> 
> oom_score_adj is used for guarding processes from OOM-Killer. One of problem
> is that it's inherited at fork(). When a daemon set oom_score_adj and
> make children, it's hard to know where the value is set.

This sounds like a really thin justification for patching the kernel. 
"Help! I don't know what my code is doing!".

Alternatives would include grepping your source code for
"oom_score_adj", or running "strace -f"!

I suspect you did have a good reason for making this change, but it
wasn't explained very well?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
