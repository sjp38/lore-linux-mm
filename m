Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 82AEE6B004F
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 12:35:55 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8223082C551
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 12:55:57 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Ar-aeBjuJJdh for <linux-mm@kvack.org>;
	Tue,  7 Jul 2009 12:55:57 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id F075882C5FC
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 12:55:52 -0400 (EDT)
Date: Tue, 7 Jul 2009 12:37:34 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 3/5] Show kernel stack usage to /proc/meminfo and OOM
 log
In-Reply-To: <20090705182409.08FC.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0907071234070.5124@gentwo.org>
References: <20090705181400.08F1.A69D9226@jp.fujitsu.com> <20090705182409.08FC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, 5 Jul 2009, KOSAKI Motohiro wrote:

> Subject: [PATCH] Show kernel stack usage to /proc/meminfo and OOM log
>
> if the system have a lot of thread, kernel stack consume unignorable large size
> memory. IOW, it make a lot of unaccountable memory.
> Tons unaccountable memory bring to harder analyse memory related trouble.
>
> Then, kernel stack account is useful.

The amount of memory allocated to kernel stacks can become significant and
cause OOM conditions. However, we do not display the amount of memory
consumed by stacks.'

Add code to display the amount of memory used for stacks in /proc/meminfo.

Reviewed-by: <cl@linux-foundation.org>

(It may be useful to also include the stack sizes in the per zone
information displayed when an OOM occurs).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
