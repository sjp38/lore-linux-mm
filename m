Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B7F776B006A
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 13:33:34 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4C34382C4C0
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 13:50:52 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id xtlzEWID4adE for <linux-mm@kvack.org>;
	Wed, 17 Jun 2009 13:50:52 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 20D4782C4CC
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 13:50:46 -0400 (EDT)
Date: Wed, 17 Jun 2009 13:34:26 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: + page_alloc-oops-when-setting-percpu_pagelist_fraction.patch
 added to -mm tree
In-Reply-To: <20090617140053.GB32637@sgi.com>
Message-ID: <alpine.DEB.1.10.0906171331210.1695@gentwo.org>
References: <200906161901.n5GJ1osY026940@imap1.linux-foundation.org> <20090617091040.99BB.A69D9226@jp.fujitsu.com> <20090617140053.GB32637@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Dimitri Sivanich <sivanich@sgi.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, mel@csn.ul.ie, nickpiggin@yahoo.com.au, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Jun 2009, Dimitri Sivanich wrote:

> > pcp is only protected local_irq_save(), not spin lock. it assume
> > each cpu have different own pcp. but this patch break this assumption.
> > Now, we can share boot_pageset by multiple cpus.
> >
>
> I'm not quite understanding what you mean.
>
> Prior to the cpu going down, each unpopulated zone pointed to the boot_pageset (per_cpu_pageset) for it's cpu (it's array element), so things had been set up this way already.  I could be missing something, but am not sure why restoring this would be a risk?

The boot_pageset is supposed to be per cpu and this patch preserves it.

However, all zones for a cpu have just a single boot pageset. Maybe that
was what threw off Kosaki?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
