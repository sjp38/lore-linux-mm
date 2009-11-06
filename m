Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D4A436B0062
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 12:34:17 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 5D6DC82C3EC
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 12:41:06 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 7bOYwxQGduiH for <linux-mm@kvack.org>;
	Fri,  6 Nov 2009 12:41:06 -0500 (EST)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id C872082C48D
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 12:40:56 -0500 (EST)
Date: Fri, 6 Nov 2009 12:32:48 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [MM] Make mm counters per cpu instead of atomic V2
In-Reply-To: <20091106122344.51118116.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0911061231580.5187@V090114053VZO-1>
References: <alpine.DEB.1.10.0911041409020.7409@V090114053VZO-1> <20091104234923.GA25306@redhat.com> <alpine.DEB.1.10.0911051004360.25718@V090114053VZO-1> <alpine.DEB.1.10.0911051035100.25718@V090114053VZO-1> <20091106101106.8115e0f1.kamezawa.hiroyu@jp.fujitsu.com>
 <20091106122344.51118116.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Dave Jones <davej@redhat.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 6 Nov 2009, KAMEZAWA Hiroyuki wrote:

> BTW, can't we have single-thread-mode for this counter ?
> Usual program's read-side will get much benefit.....

Thanks for the measurements.

A single thread mode would be good. Ideas on how to add that would be
appreciated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
