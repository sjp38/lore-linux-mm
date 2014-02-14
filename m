Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f44.google.com (mail-qa0-f44.google.com [209.85.216.44])
	by kanga.kvack.org (Postfix) with ESMTP id 9EF966B0031
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 13:25:13 -0500 (EST)
Received: by mail-qa0-f44.google.com with SMTP id w5so18989282qac.31
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 10:25:13 -0800 (PST)
Received: from qmta09.emeryville.ca.mail.comcast.net (qmta09.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:96])
        by mx.google.com with ESMTP id k45si4349168qgd.142.2014.02.14.10.25.12
        for <linux-mm@kvack.org>;
        Fri, 14 Feb 2014 10:25:13 -0800 (PST)
Date: Fri, 14 Feb 2014 12:25:10 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/9] slab: move up code to get kmem_cache_node in
 free_block()
In-Reply-To: <1392361043-22420-4-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.10.1402141224540.12887@nuc>
References: <1392361043-22420-1-git-send-email-iamjoonsoo.kim@lge.com> <1392361043-22420-4-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On Fri, 14 Feb 2014, Joonsoo Kim wrote:

> node isn't changed, so we don't need to retreive this structure
> everytime we move the object. Maybe compiler do this optimization,
> but making it explicitly is better.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
