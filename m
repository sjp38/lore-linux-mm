Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id EF8C56B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 12:29:56 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B191F82C43F
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 12:29:56 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Cvy5binEJ+qq for <linux-mm@kvack.org>;
	Tue, 17 Nov 2009 12:29:56 -0500 (EST)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 1B8B582C603
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 12:28:56 -0500 (EST)
Date: Tue, 17 Nov 2009 12:25:37 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [MM] Make mm counters per cpu instead of atomic
In-Reply-To: <1258450465.11321.36.camel@localhost>
Message-ID: <alpine.DEB.1.10.0911171223460.20360@V090114053VZO-1>
References: <alpine.DEB.1.10.0911041409020.7409@V090114053VZO-1>  <1258440521.11321.32.camel@localhost> <1258443101.11321.33.camel@localhost> <1258450465.11321.36.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Tejun Heo <tj@kernel.org>, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Nov 2009, Zhang, Yanmin wrote:

> The right change above should be:
>  struct mm_counter *m = per_cpu_ptr(mm->rss, cpu);

Right.

> With the change, command 'make oldconfig' and a boot command still
> hangs.

Not sure if its worth spending more time on this but if you want I will
consolidate the fixes so far and put out another patchset.

Where does it hang during boot?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
