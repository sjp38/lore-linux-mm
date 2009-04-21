Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 045F26B004D
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 11:13:24 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B628282C6C7
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 11:23:58 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id a8FOGJSsUiho for <linux-mm@kvack.org>;
	Tue, 21 Apr 2009 11:23:58 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 939CA82C6CD
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 11:23:52 -0400 (EDT)
Date: Tue, 21 Apr 2009 11:05:34 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 18/25] Do not disable interrupts in free_page_mlock()
In-Reply-To: <20090421085007.GG12713@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0904211104390.19969@qirst.com>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie> <1240266011-11140-19-git-send-email-mel@csn.ul.ie> <1240300507.771.52.camel@penberg-laptop> <20090421085007.GG12713@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Apr 2009, Mel Gorman wrote:

> > Maybe add a VM_BUG_ON(!PageMlocked(page))?
> >
>
> We always check in the caller and I don't see callers to this function
> expanding. I can add it if you insist but I don't think it'll catch
> anything in this case.

Dont add it. Pekka sometimes has this checkeritis that manifest itself
in VM_BUG_ON and BUG_ONs all over the place.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
