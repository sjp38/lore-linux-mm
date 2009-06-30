Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 715EB6B004D
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 10:13:45 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 5996E82C56C
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 10:31:35 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Pwrro5Hq1ELQ for <linux-mm@kvack.org>;
	Tue, 30 Jun 2009 10:31:35 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0256182C56D
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 10:31:32 -0400 (EDT)
Date: Tue, 30 Jun 2009 10:13:34 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] Show kernel stack usage to /proc/meminfo and OOM log
In-Reply-To: <20090630150035.A738.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0906301011210.6124@gentwo.org>
References: <20090630150035.A738.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, David Howells <dhowells@redhat.com>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, 30 Jun 2009, KOSAKI Motohiro wrote:

> +static void account_kernel_stack(struct thread_info *ti, int on)

static inline?

> +{
> +	struct zone* zone = page_zone(virt_to_page(ti));
> +	int sign = on ? 1 : -1;
> +	long acct = sign * (THREAD_SIZE / PAGE_SIZE);

int pages = THREAD_SIZE / PAGE_SIZE;

?

> +
> +	mod_zone_page_state(zone, NR_KERNEL_STACK, acct);

mod_zone_page_state(zone, NR_KERNEL_STACK, on ? pages : -pages);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
