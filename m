Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 111FA6B004D
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 09:55:05 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4D2E982C7A1
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 10:14:26 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id nBcKDoj9Md1b for <linux-mm@kvack.org>;
	Thu, 16 Jul 2009 10:14:26 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 325DB82C7A8
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 10:14:20 -0400 (EDT)
Date: Thu, 16 Jul 2009 09:54:49 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] mm: Warn once when a page is freed with PG_mlocked set
 V2
In-Reply-To: <20090716163537.9D3D.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0907160949470.32382@gentwo.org>
References: <alpine.DEB.1.10.0907151027410.23643@gentwo.org> <20090715220445.GA1823@cmpxchg.org> <20090716163537.9D3D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Maxim Levitsky <maximlevitsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Jiri Slaby <jirislaby@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, 16 Jul 2009, KOSAKI Motohiro wrote:

> I like this patch. but can you please separate two following patches?
>   - introduce __TESTCLEARFLAG()
>   - non-atomic test-clear of PG_mlocked on free

That would mean introducing the macro without any use case? It is fine the
way it is I think.

Reviewed-by: Christoph Lameter <cl@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
