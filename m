Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 85B986B004D
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 14:47:42 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id DF7CB82C5E7
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 15:07:22 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id K-l7IZK+29BJ for <linux-mm@kvack.org>;
	Fri, 10 Jul 2009 15:07:22 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 89B6982C602
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 15:07:18 -0400 (EDT)
Date: Fri, 10 Jul 2009 14:48:37 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 4/5] add isolate pages vmstat
In-Reply-To: <20090710094934.17CA.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0907101447370.14152@gentwo.org>
References: <20090709171247.23C6.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0907091638330.17835@gentwo.org> <20090710094934.17CA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Fri, 10 Jul 2009, KOSAKI Motohiro wrote:

> Plus, current reclaim logic depend on the system have enough much pages on LRU.
> Maybe we don't only need to limit #-of-reclaimer, but also need to limit #-of-migrator.
> I think we can use similar logic.

I think your isolate pages counters can be used in both locations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
