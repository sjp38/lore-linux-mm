Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id 28FD96B0037
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 18:06:40 -0500 (EST)
Received: by mail-qc0-f182.google.com with SMTP id c9so4539805qcz.13
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 15:06:40 -0800 (PST)
Received: from qmta08.emeryville.ca.mail.comcast.net (qmta08.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:80])
        by mx.google.com with ESMTP id t101si1071319qge.101.2014.02.06.09.25.32
        for <linux-mm@kvack.org>;
        Thu, 06 Feb 2014 09:26:03 -0800 (PST)
Date: Thu, 6 Feb 2014 11:25:29 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
In-Reply-To: <20140206020833.GD5433@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1402061124540.5348@nuc>
References: <alpine.DEB.2.02.1401241618500.20466@chino.kir.corp.google.com> <20140125011041.GB25344@linux.vnet.ibm.com> <20140127055805.GA2471@lge.com> <20140128182947.GA1591@linux.vnet.ibm.com> <20140203230026.GA15383@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1402032138070.17997@nuc> <20140204072630.GB10101@linux.vnet.ibm.com> <alpine.DEB.2.10.1402041436150.11222@nuc> <20140205001352.GC10101@linux.vnet.ibm.com> <alpine.DEB.2.10.1402051312430.21661@nuc>
 <20140206020833.GD5433@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Han Pingtian <hanpt@linux.vnet.ibm.com>, mpm@selenic.com, penberg@kernel.org, linux-mm@kvack.org, paulus@samba.org, Anton Blanchard <anton@samba.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Wed, 5 Feb 2014, Nishanth Aravamudan wrote:

> > Right so if we are ignoring the node then the simplest thing to do is to
> > not deactivate the current cpu slab but to take an object from it.
>
> Ok, that's what Anton's patch does, I believe. Are you ok with that
> patch as it is?

No. Again his patch only works if the node is memoryless not if there are
other issues that prevent allocation from that node.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
