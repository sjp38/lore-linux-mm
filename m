Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 17F776B0055
	for <linux-mm@kvack.org>; Fri, 24 Jul 2009 07:32:13 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 328B182C429
	for <linux-mm@kvack.org>; Fri, 24 Jul 2009 07:52:14 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id L-XIMcf81VL6 for <linux-mm@kvack.org>;
	Fri, 24 Jul 2009 07:52:09 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 542A982C3A2
	for <linux-mm@kvack.org>; Fri, 24 Jul 2009 07:52:00 -0400 (EDT)
Date: Fri, 24 Jul 2009 07:31:32 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] mm: Warn once when a page is freed with PG_mlocked set
 V2
In-Reply-To: <20090724103656.GA18074@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0907240731010.4073@gentwo.org>
References: <20090715125822.GB29749@csn.ul.ie> <alpine.DEB.1.10.0907151027410.23643@gentwo.org> <20090722160649.61176c61.akpm@linux-foundation.org> <20090723102938.GA27731@csn.ul.ie> <20090723102316.b94a2e4f.akpm@linux-foundation.org>
 <20090724103656.GA18074@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, kosaki.motohiro@jp.fujitsu.com, maximlevitsky@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee.Schermerhorn@hp.com, penberg@cs.helsinki.fi, hannes@cmpxchg.org, jirislaby@gmail.com
List-ID: <linux-mm.kvack.org>

Looks good.

Reviewed-by: Christoph Lameter <cl@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
