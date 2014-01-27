Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f52.google.com (mail-bk0-f52.google.com [209.85.214.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8823D6B0031
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 11:16:26 -0500 (EST)
Received: by mail-bk0-f52.google.com with SMTP id e11so2939147bkh.39
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 08:16:26 -0800 (PST)
Received: from qmta09.emeryville.ca.mail.comcast.net (qmta09.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:96])
        by mx.google.com with ESMTP id on6si14874802bkb.143.2014.01.27.08.16.23
        for <linux-mm@kvack.org>;
        Mon, 27 Jan 2014 08:16:25 -0800 (PST)
Date: Mon, 27 Jan 2014 10:16:20 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
In-Reply-To: <alpine.DEB.2.02.1401241543100.18620@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1401271014340.2215@nuc>
References: <20140107132100.5b5ad198@kryten> <20140107074136.GA4011@lge.com> <52dce7fe.e5e6420a.5ff6.ffff84a0SMTPIN_ADDED_BROKEN@mx.google.com> <alpine.DEB.2.10.1401201612340.28048@nuc> <52e1d960.2715420a.3569.1013SMTPIN_ADDED_BROKEN@mx.google.com>
 <52e1da8f.86f7440a.120f.25f3SMTPIN_ADDED_BROKEN@mx.google.com> <alpine.DEB.2.10.1401240946530.12886@nuc> <alpine.DEB.2.02.1401241301120.10968@chino.kir.corp.google.com> <20140124232902.GB30361@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1401241543100.18620@chino.kir.corp.google.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, penberg@kernel.org, linux-mm@kvack.org, Han Pingtian <hanpt@linux.vnet.ibm.com>, paulus@samba.org, Anton Blanchard <anton@samba.org>, mpm@selenic.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Fri, 24 Jan 2014, David Rientjes wrote:

> kmalloc_node(nid) and kmem_cache_alloc_node(nid) should fallback to nodes
> other than nid when memory can't be allocated, these functions only
> indicate a preference.

The nid passed indicated a preference unless __GFP_THIS_NODE is specified.
Then the allocation must occur on that node.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
