Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id D71EA6B0031
	for <linux-mm@kvack.org>; Wed, 29 Jan 2014 10:55:03 -0500 (EST)
Received: by mail-qa0-f51.google.com with SMTP id f11so2617075qae.38
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 07:55:03 -0800 (PST)
Received: from qmta11.emeryville.ca.mail.comcast.net (qmta11.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:211])
        by mx.google.com with ESMTP id t3si1963072qas.46.2014.01.29.07.54.52
        for <linux-mm@kvack.org>;
        Wed, 29 Jan 2014 07:55:02 -0800 (PST)
Date: Wed, 29 Jan 2014 09:54:49 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
In-Reply-To: <20140128182947.GA1591@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1401290953270.23856@nuc>
References: <52e1d960.2715420a.3569.1013SMTPIN_ADDED_BROKEN@mx.google.com> <52e1da8f.86f7440a.120f.25f3SMTPIN_ADDED_BROKEN@mx.google.com> <alpine.DEB.2.10.1401240946530.12886@nuc> <alpine.DEB.2.02.1401241301120.10968@chino.kir.corp.google.com>
 <20140124232902.GB30361@linux.vnet.ibm.com> <alpine.DEB.2.02.1401241543100.18620@chino.kir.corp.google.com> <20140125001643.GA25344@linux.vnet.ibm.com> <alpine.DEB.2.02.1401241618500.20466@chino.kir.corp.google.com> <20140125011041.GB25344@linux.vnet.ibm.com>
 <20140127055805.GA2471@lge.com> <20140128182947.GA1591@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, penberg@kernel.org, linux-mm@kvack.org, paulus@samba.org, Anton Blanchard <anton@samba.org>, mpm@selenic.com, linuxppc-dev@lists.ozlabs.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

On Tue, 28 Jan 2014, Nishanth Aravamudan wrote:

> This helps about the same as David's patch -- but I found the reason
> why! ppc64 doesn't set CONFIG_HAVE_MEMORYLESS_NODES :) Expect a patch
> shortly for that and one other case I found.

Oww...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
