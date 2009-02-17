Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 742266B00BE
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 15:14:00 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4049E82C45E
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 15:17:55 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id vgmDlovd4js5 for <linux-mm@kvack.org>;
	Tue, 17 Feb 2009 15:17:54 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 368AA82C4AF
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 15:17:34 -0500 (EST)
Date: Tue, 17 Feb 2009 15:06:12 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch 1/7] slab: introduce kzfree()
In-Reply-To: <20090217184135.747921027@cmpxchg.org>
Message-ID: <alpine.DEB.1.10.0902171505570.24395@qirst.com>
References: <20090217182615.897042724@cmpxchg.org> <20090217184135.747921027@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Chas Williams <chas@cmf.nrl.navy.mil>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>


Acked-by: Christoph Lameter <cl@linux-foundation.org>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
