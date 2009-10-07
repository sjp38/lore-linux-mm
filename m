Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5F19F6B005D
	for <linux-mm@kvack.org>; Wed,  7 Oct 2009 10:32:29 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 6FFC082C268
	for <linux-mm@kvack.org>; Wed,  7 Oct 2009 10:36:14 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id lyv3G0MX3l5G for <linux-mm@kvack.org>;
	Wed,  7 Oct 2009 10:36:09 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 1500482C483
	for <linux-mm@kvack.org>; Wed,  7 Oct 2009 10:35:05 -0400 (EDT)
Date: Wed, 7 Oct 2009 10:25:13 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch] mm: clear node in N_HIGH_MEMORY and stop kswapd when
 all memory is offlined
In-Reply-To: <alpine.DEB.1.00.0910070043140.16136@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.1.10.0910071024390.5671@gentwo.org>
References: <20091006031739.22576.5248.sendpatchset@localhost.localdomain> <20091006031924.22576.35018.sendpatchset@localhost.localdomain> <alpine.DEB.1.00.0910070043140.16136@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-numa@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com, Yasunori Goto <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 7 Oct 2009, David Rientjes wrote:

> The following should fix it.  Christoph?

As far as I can see it looks good. Someone verify the kswapd details
please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
