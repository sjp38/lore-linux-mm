Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 119D46B0085
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 17:19:10 -0500 (EST)
Date: Wed, 10 Feb 2010 22:18:47 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Improving OOM killer
Message-ID: <20100210221847.5d7bb3cb@lxorguk.ukuu.org.uk>
In-Reply-To: <4B7320BF.2020800@redhat.com>
References: <201002012302.37380.l.lunak@suse.cz>
	<4B6B4500.3010603@redhat.com>
	<alpine.DEB.2.00.1002041410300.16391@chino.kir.corp.google.com>
	<201002102154.43231.l.lunak@suse.cz>
	<4B7320BF.2020800@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Lubos Lunak <l.lunak@suse.cz>, David Rientjes <rientjes@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Jiri Kosina <jkosina@suse.cz>
List-ID: <linux-mm.kvack.org>

> Killing the system daemon *is* a DoS.
> 
> It would stop eg. the database or the web server, which is
> generally the main task of systems that run a database or
> a web server.

One of the problems with picking on tasks that fork a lot is that
describes apache perfectly. So a high loaded apache will get shot over a
rapid memory eating cgi script.

Any heuristic is going to be iffy - but that isn't IMHO a good one to
work from. If anything "who allocated lots of RAM recently" may be a
better guide but we don't keep stats for that.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
