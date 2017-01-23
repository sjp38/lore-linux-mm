Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C62FD6B0038
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 18:04:31 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id c7so29319273wjb.7
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 15:04:31 -0800 (PST)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id q80si15905900wmg.80.2017.01.23.15.04.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 15:04:30 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 485121C12C7
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 23:04:30 +0000 (GMT)
Date: Mon, 23 Jan 2017 23:04:29 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 3/4] mm, page_alloc: Drain per-cpu pages from workqueue
 context
Message-ID: <20170123230429.os7ssxab4mazrkrb@techsingularity.net>
References: <20170117092954.15413-1-mgorman@techsingularity.net>
 <20170117092954.15413-4-mgorman@techsingularity.net>
 <06c39883-eff5-1412-a148-b063aa7bcc5f@suse.cz>
 <20170120152606.w3hb53m2w6thzsqq@techsingularity.net>
 <20170123170329.GA7820@htj.duckdns.org>
 <20170123200412.mkesardc4mckk6df@techsingularity.net>
 <20170123205501.GA25944@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170123205501.GA25944@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Petr Mladek <pmladek@suse.cz>

On Mon, Jan 23, 2017 at 03:55:01PM -0500, Tejun Heo wrote:
> Hello, Mel.
> 
> On Mon, Jan 23, 2017 at 08:04:12PM +0000, Mel Gorman wrote:
> > What is the actual mechanism that does that? It's not something that
> > schedule_on_each_cpu does and one would expect that the core workqueue
> > implementation would get this sort of detail correct. Or is this a proposal
> > on how it should be done?
> 
> If you use schedule_on_each_cpu(), it's all fine as the thing pins
> cpus and waits for all the work items synchronously.  If you wanna do
> it asynchronously, right now, you'll have to manually synchronize work
> items against the offline callback manually.
> 

Is the current implementation and what it does wrong in some way? I ask
because synchronising against the offline callback sounds like it would
be a bit of a maintenance mess for relatively little gain.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
