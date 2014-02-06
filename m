Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f41.google.com (mail-yh0-f41.google.com [209.85.213.41])
	by kanga.kvack.org (Postfix) with ESMTP id ACF476B0038
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 18:00:26 -0500 (EST)
Received: by mail-yh0-f41.google.com with SMTP id f73so2398341yha.28
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 15:00:26 -0800 (PST)
Received: from qmta12.emeryville.ca.mail.comcast.net (qmta12.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:227])
        by mx.google.com with ESMTP id j4si1086992qao.24.2014.02.06.09.31.42
        for <linux-mm@kvack.org>;
        Thu, 06 Feb 2014 09:32:13 -0800 (PST)
Date: Thu, 6 Feb 2014 11:31:40 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 1/3] slub: search partial list on numa_mem_id(),
 instead of numa_node_id()
In-Reply-To: <alpine.DEB.2.02.1402060037210.21148@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1402061131070.5348@nuc>
References: <20140206020757.GC5433@linux.vnet.ibm.com> <1391674026-20092-1-git-send-email-iamjoonsoo.kim@lge.com> <alpine.DEB.2.02.1402060037210.21148@chino.kir.corp.google.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, penberg@kernel.org, linux-mm@kvack.org, paulus@samba.org, Anton Blanchard <anton@samba.org>, mpm@selenic.com, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Thu, 6 Feb 2014, David Rientjes wrote:

> I think you'll need to send these to Andrew since he appears to be picking
> up slub patches these days.

I can start managing merges again if Pekka no longer has the time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
