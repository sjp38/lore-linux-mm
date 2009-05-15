Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DBD4B6B005D
	for <linux-mm@kvack.org>; Fri, 15 May 2009 14:02:05 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B1F5182C2B0
	for <linux-mm@kvack.org>; Fri, 15 May 2009 14:14:48 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id dDvzsvyNC8+1 for <linux-mm@kvack.org>;
	Fri, 15 May 2009 14:14:44 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9F7FF82C339
	for <linux-mm@kvack.org>; Fri, 15 May 2009 14:14:39 -0400 (EDT)
Date: Fri, 15 May 2009 14:01:45 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 4/4] zone_reclaim_mode is always 0 by default
In-Reply-To: <20090515082836.F5B9.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0905151401040.26559@qirst.com>
References: <20090513152256.GM7601@sgi.com> <alpine.DEB.1.10.0905141602010.1381@qirst.com> <20090515082836.F5B9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Robin Holt <holt@sgi.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 15 May 2009, KOSAKI Motohiro wrote:

> How about this?

Rewiewed-by: Christoph Lameter <cl@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
