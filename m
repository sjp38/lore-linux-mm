Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id 046BC6B0031
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 13:41:49 -0500 (EST)
Received: by mail-qa0-f47.google.com with SMTP id j5so18872522qaq.34
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 10:41:49 -0800 (PST)
Received: from qmta15.emeryville.ca.mail.comcast.net (qmta15.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:228])
        by mx.google.com with ESMTP id c19si4460219qge.117.2014.02.14.10.41.49
        for <linux-mm@kvack.org>;
        Fri, 14 Feb 2014 10:41:49 -0800 (PST)
Date: Fri, 14 Feb 2014 12:41:47 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 5/9] slab: factor out initialization of arracy cache
In-Reply-To: <1392361043-22420-6-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.10.1402141241320.12887@nuc>
References: <1392361043-22420-1-git-send-email-iamjoonsoo.kim@lge.com> <1392361043-22420-6-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On Fri, 14 Feb 2014, Joonsoo Kim wrote:

> Factor out initialization of array cache to use it in following patch.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
