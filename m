Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B12FE6B0055
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 17:09:46 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 1F41F82C2E6
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 17:47:44 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id nrByHh2DXlpy for <linux-mm@kvack.org>;
	Thu,  9 Jul 2009 17:47:38 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 57E7982C50A
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 17:47:21 -0400 (EDT)
Date: Thu, 9 Jul 2009 17:00:41 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 3/5] Show kernel stack usage to /proc/meminfo and OOM
 log
In-Reply-To: <20090709110952.2389.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0907091700150.17835@gentwo.org>
References: <20090705182409.08FC.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0907071234070.5124@gentwo.org> <20090709110952.2389.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 9 Jul 2009, KOSAKI Motohiro wrote:

> following code in this patch mean display per-zone stack size, no?

Right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
