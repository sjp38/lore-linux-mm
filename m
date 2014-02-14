Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f44.google.com (mail-qa0-f44.google.com [209.85.216.44])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2B66B0035
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 13:47:24 -0500 (EST)
Received: by mail-qa0-f44.google.com with SMTP id w5so18579768qac.17
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 10:47:24 -0800 (PST)
Received: from qmta01.emeryville.ca.mail.comcast.net (qmta01.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:16])
        by mx.google.com with ESMTP id 108si4462745qgr.184.2014.02.14.10.47.23
        for <linux-mm@kvack.org>;
        Fri, 14 Feb 2014 10:47:23 -0800 (PST)
Date: Fri, 14 Feb 2014 12:47:21 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 7/9] slab: use the lock on alien_cache, instead of the
 lock on array_cache
In-Reply-To: <1392361043-22420-8-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.10.1402141247070.12887@nuc>
References: <1392361043-22420-1-git-send-email-iamjoonsoo.kim@lge.com> <1392361043-22420-8-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On Fri, 14 Feb 2014, Joonsoo Kim wrote:

> Now, we have separate alien_cache structure, so it'd be better to hold
> the lock on alien_cache while manipulating alien_cache. After that,
> we don't need the lock on array_cache, so remove it.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
