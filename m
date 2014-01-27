Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f45.google.com (mail-bk0-f45.google.com [209.85.214.45])
	by kanga.kvack.org (Postfix) with ESMTP id C61446B0031
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 11:18:46 -0500 (EST)
Received: by mail-bk0-f45.google.com with SMTP id v16so2956524bkz.32
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 08:18:46 -0800 (PST)
Received: from qmta09.emeryville.ca.mail.comcast.net (qmta09.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:96])
        by mx.google.com with ESMTP id yt2si14848409bkb.134.2014.01.27.08.18.44
        for <linux-mm@kvack.org>;
        Mon, 27 Jan 2014 08:18:45 -0800 (PST)
Date: Mon, 27 Jan 2014 10:18:42 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
In-Reply-To: <20140125011041.GB25344@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1401271016560.2215@nuc>
References: <52dce7fe.e5e6420a.5ff6.ffff84a0SMTPIN_ADDED_BROKEN@mx.google.com> <alpine.DEB.2.10.1401201612340.28048@nuc> <52e1d960.2715420a.3569.1013SMTPIN_ADDED_BROKEN@mx.google.com> <52e1da8f.86f7440a.120f.25f3SMTPIN_ADDED_BROKEN@mx.google.com>
 <alpine.DEB.2.10.1401240946530.12886@nuc> <alpine.DEB.2.02.1401241301120.10968@chino.kir.corp.google.com> <20140124232902.GB30361@linux.vnet.ibm.com> <alpine.DEB.2.02.1401241543100.18620@chino.kir.corp.google.com> <20140125001643.GA25344@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1401241618500.20466@chino.kir.corp.google.com> <20140125011041.GB25344@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, penberg@kernel.org, linux-mm@kvack.org, paulus@samba.org, Anton Blanchard <anton@samba.org>, mpm@selenic.com, linuxppc-dev@lists.ozlabs.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Fri, 24 Jan 2014, Nishanth Aravamudan wrote:

> As to cpu_to_node() being passed to kmalloc_node(), I think an
> appropriate fix is to change that to cpu_to_mem()?

Yup.

> > Yeah, the default policy should be to fallback to local memory if the node
> > passed is memoryless.
>
> Thanks!

I would suggest to use NUMA_NO_NODE instead. That will fit any slab that
we may be currently allocating from or can get a hold of and is mosty
efficient.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
