Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1415F6B005D
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 16:24:02 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 6A49E82C503
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 17:01:45 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Ll43pn9j7W4g for <linux-mm@kvack.org>;
	Thu,  9 Jul 2009 17:01:40 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 7BA6982C50F
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 17:01:35 -0400 (EDT)
Date: Thu, 9 Jul 2009 16:38:24 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 3/5][resend] Show kernel stack usage to /proc/meminfo
 and OOM log
In-Reply-To: <20090709171122.23C3.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0907091637380.17835@gentwo.org>
References: <20090709165820.23B7.A69D9226@jp.fujitsu.com> <20090709171122.23C3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Thu, 9 Jul 2009, KOSAKI Motohiro wrote:

> Subject: [PATCH] Show kernel stack usage to /proc/meminfo and OOM log

Subject: Show kernel stack usage in /proc/meminfo and OOM log output

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
