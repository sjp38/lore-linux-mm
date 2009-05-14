Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C75D96B005A
	for <linux-mm@kvack.org>; Thu, 14 May 2009 16:30:55 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id EA11482C392
	for <linux-mm@kvack.org>; Thu, 14 May 2009 16:44:10 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id S+fiiDgI3FJJ for <linux-mm@kvack.org>;
	Thu, 14 May 2009 16:44:10 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 38C2B82C3A0
	for <linux-mm@kvack.org>; Thu, 14 May 2009 16:44:04 -0400 (EDT)
Date: Thu, 14 May 2009 16:31:16 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 4/4] zone_reclaim_mode is always 0 by default
In-Reply-To: <4A0C7DB6.6010601@redhat.com>
Message-ID: <alpine.DEB.1.10.0905141629440.15881@qirst.com>
References: <20090513120155.5879.A69D9226@jp.fujitsu.com> <20090513120729.5885.A69D9226@jp.fujitsu.com> <20090513152256.GM7601@sgi.com> <alpine.DEB.1.10.0905141602010.1381@qirst.com> <4A0C7DB6.6010601@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Robin Holt <holt@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 14 May 2009, Rik van Riel wrote:

> I suspect that patches 1/4 through 3/4 will cause the
> system to behave better already, by only reclaiming
> the easiest to reclaim pages from zone reclaim and
> falling back after that - or am overlooking something?

zone reclaims default config has always only reclaimed the easiest
reclaimable pages. Manual configuration is necessary to reclaim other
pages.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
