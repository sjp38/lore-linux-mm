Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f53.google.com (mail-bk0-f53.google.com [209.85.214.53])
	by kanga.kvack.org (Postfix) with ESMTP id 9F5DC6B0031
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 11:24:35 -0500 (EST)
Received: by mail-bk0-f53.google.com with SMTP id my13so2948530bkb.12
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 08:24:35 -0800 (PST)
Received: from qmta08.emeryville.ca.mail.comcast.net (qmta08.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:80])
        by mx.google.com with ESMTP id dg6si14883176bkc.242.2014.01.27.08.24.33
        for <linux-mm@kvack.org>;
        Mon, 27 Jan 2014 08:24:34 -0800 (PST)
Date: Mon, 27 Jan 2014 10:24:31 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
In-Reply-To: <20140125001643.GA25344@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1401271022510.6125@nuc>
References: <20140107132100.5b5ad198@kryten> <20140107074136.GA4011@lge.com> <52dce7fe.e5e6420a.5ff6.ffff84a0SMTPIN_ADDED_BROKEN@mx.google.com> <alpine.DEB.2.10.1401201612340.28048@nuc> <52e1d960.2715420a.3569.1013SMTPIN_ADDED_BROKEN@mx.google.com>
 <52e1da8f.86f7440a.120f.25f3SMTPIN_ADDED_BROKEN@mx.google.com> <alpine.DEB.2.10.1401240946530.12886@nuc> <alpine.DEB.2.02.1401241301120.10968@chino.kir.corp.google.com> <20140124232902.GB30361@linux.vnet.ibm.com> <alpine.DEB.2.02.1401241543100.18620@chino.kir.corp.google.com>
 <20140125001643.GA25344@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, penberg@kernel.org, linux-mm@kvack.org, paulus@samba.org, Anton Blanchard <anton@samba.org>, mpm@selenic.com, linuxppc-dev@lists.ozlabs.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Fri, 24 Jan 2014, Nishanth Aravamudan wrote:

> What I find odd is that there are only 2 nodes on this system, node 0
> (empty) and node 1. So won't numa_mem_id() always be 1? And every page
> should be coming from node 1 (thus node_match() should always be true?)

Well yes that occurs if you specify the node or just always use the
default memory allocation policy.

In order to spread the allocatios over both node you would have to set the
tasks memory allocation policy to MPOL_INTERLEAVE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
