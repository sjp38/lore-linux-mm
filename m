Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1382F6B0044
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 12:46:49 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 53C2482C522
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 12:53:32 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 4wOEle1elPEx for <linux-mm@kvack.org>;
	Thu,  5 Nov 2009 12:53:32 -0500 (EST)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 2D229700390
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 10:11:45 -0500 (EST)
Date: Thu, 5 Nov 2009 10:04:01 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] show per-process swap usage via procfs
In-Reply-To: <20091105082357.54D3.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0911051003060.25718@V090114053VZO-1>
References: <20091104152426.eacc894f.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.1.10.0911041414560.7409@V090114053VZO-1> <20091105082357.54D3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 5 Nov 2009, KOSAKI Motohiro wrote:

> > On Wed, 4 Nov 2009, KAMEZAWA Hiroyuki wrote:
> >
> > > Now, anon_rss and file_rss is counted as RSS and exported via /proc.
> > > RSS usage is important information but one more information which
> > > is often asked by users is "usage of swap".(user support team said.)
> >
> > Hmmm... Could we do some rework of the counters first so that they are per
> > cpu?
>
> per-cpu swap counter?
> It seems overkill effort....

The other alternative is to use atomic ops which are significantly slower
and have an impact on critical sections.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
