Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C07F66B004D
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 10:19:09 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 53FED82C3EA
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 10:20:50 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id blqqOVANiYIo for <linux-mm@kvack.org>;
	Tue,  1 Sep 2009 10:20:45 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 83EF182C791
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 10:20:27 -0400 (EDT)
Date: Tue, 1 Sep 2009 14:18:05 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH mmotm] Fix NUMA accounting in numastat.txt
In-Reply-To: <20090901162937.431a844c.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0909011415570.16313@V090114053VZO-1>
References: <20090901135321.f0da4715.minchan.kim@barrios-desktop> <20090901161721.f104c476.kamezawa.hiroyu@jp.fujitsu.com> <20090901162419.a4a6c80e.minchan.kim@barrios-desktop> <20090901162937.431a844c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 1 Sep 2009, KAMEZAWA Hiroyuki wrote:

> Thanks. Add Christoph to CC:, maybe he can Ack.

Acked-by: Christoph Lameter <cl@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
