Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2A2506B004D
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 14:49:12 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 377B982C421
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 14:56:01 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id aFdHG8FYZ5Ax for <linux-mm@kvack.org>;
	Fri,  6 Nov 2009 14:56:01 -0500 (EST)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 5F2F882C4BF
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 14:55:50 -0500 (EST)
Date: Fri, 6 Nov 2009 14:47:52 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [MM] Make mm counters per cpu instead of atomic V2
In-Reply-To: <ffef0f18fe9ae9948d0db7fb4b0a0341.squirrel@webmail-b.css.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0911061446480.28386@V090114053VZO-1>
References: <alpine.DEB.1.10.0911041409020.7409@V090114053VZO-1>    <20091104234923.GA25306@redhat.com>    <alpine.DEB.1.10.0911051004360.25718@V090114053VZO-1>    <alpine.DEB.1.10.0911051035100.25718@V090114053VZO-1>    <20091106101106.8115e0f1.kamezawa.hiroyu@jp.fujitsu.com>
    <20091106122344.51118116.kamezawa.hiroyu@jp.fujitsu.com>    <alpine.DEB.1.10.0911061231580.5187@V090114053VZO-1>    <da621335371fccd6cfb3d8d7c0c2bf3a.squirrel@webmail-b.css.fujitsu.com>    <alpine.DEB.1.10.0911061409310.15636@V090114053VZO-1>
 <ffef0f18fe9ae9948d0db7fb4b0a0341.squirrel@webmail-b.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Dave Jones <davej@redhat.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

On Sat, 7 Nov 2009, KAMEZAWA Hiroyuki wrote:

> > If we just have one thread: Do we need atomic access at all?
> >
> Unfortunately, kswapd/vmscan touch this.

Right. And those can also occur from another processor that the process
never has run on before. Argh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
