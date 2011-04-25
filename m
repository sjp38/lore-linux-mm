Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 361298D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 11:39:47 -0400 (EDT)
Subject: Re: [PATCH] trace: Add tracepoints to fs subsystem
From: Steven Rostedt <rostedt@goodmis.org>
In-Reply-To: <20110425113723.2666.A69D9226@jp.fujitsu.com>
References: <1303513209-26436-1-git-send-email-vnagarnaik@google.com>
	 <20110425113723.2666.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-15"
Date: Mon, 25 Apr 2011 11:39:45 -0400
Message-ID: <1303745985.18763.14.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Vaibhav Nagarnaik <vnagarnaik@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@redhat.com>, Michael Rubin <mrubin@google.com>, David Sharp <dhsharp@google.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Jiaying Zhang <jiayingz@google.com>

On Mon, 2011-04-25 at 11:35 +0900, KOSAKI Motohiro wrote:
> > From: Jiaying Zhang <jiayingz@google.com>
> > 
> > Many fs tracepoints can now be traced via ftrace, however there are a
> > few other tracepoints needed. This patch adds entry and exit tracepoints
> > for a few additional functions, viz.:
> > wait_on_buffer
> > block_write_full_page
> > mpage_readpages
> > file_read
> 
> Zero background description?
> 

Good point.

Could you please describe how this is useful, and how one can benefit
from these tracepoints.

-- Steve



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
