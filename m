Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E1F646B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 18:22:34 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E5E4D82C4A0
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 18:22:33 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 5bRSdKGf+Kfm for <linux-mm@kvack.org>;
	Tue, 10 Nov 2009 18:22:33 -0500 (EST)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 89ACA82C4BD
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 18:22:27 -0500 (EST)
Date: Tue, 10 Nov 2009 18:20:33 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [MM] Make mm counters per cpu instead of atomic V2
In-Reply-To: <20091110144438.dbab0ba8.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.1.10.0911101820030.28336@V090114053VZO-1>
References: <alpine.DEB.1.10.0911041409020.7409@V090114053VZO-1> <20091104234923.GA25306@redhat.com> <alpine.DEB.1.10.0911051004360.25718@V090114053VZO-1> <alpine.DEB.1.10.0911051035100.25718@V090114053VZO-1> <20091106101106.8115e0f1.kamezawa.hiroyu@jp.fujitsu.com>
 <20091110144438.dbab0ba8.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Jones <davej@redhat.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 10 Nov 2009, Andrew Morton wrote:

> Adding a thousand cache misses to the timer interrupt is the sort of
> thing which makes people unhappy?

Obviously I was hoping for new ideas instead of just restatements of the
problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
