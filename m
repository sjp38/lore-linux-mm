Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 729676B0101
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 16:29:58 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 417B282C8B8
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 16:40:56 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 0rC5kx7V+HJK for <linux-mm@kvack.org>;
	Wed, 22 Apr 2009 16:40:51 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 1624C82C8B0
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 16:40:37 -0400 (EDT)
Date: Wed, 22 Apr 2009 16:20:49 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 02/22] Do not sanity check order in the fast path
In-Reply-To: <alpine.DEB.2.00.0904221244030.14558@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.1.10.0904221620370.18138@qirst.com>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie> <1240408407-21848-3-git-send-email-mel@csn.ul.ie> <1240416791.10627.78.camel@nimitz> <20090422171151.GF15367@csn.ul.ie> <alpine.DEB.2.00.0904221244030.14558@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Pekka Enberg <penberg@cs.helsinki.fi>, Dave Hansen <dave@linux.vnet.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>




Acked-by: Christoph Lameter <cl@linux-foundation.org>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
