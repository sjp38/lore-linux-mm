Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id EDD896B00A4
	for <linux-mm@kvack.org>; Wed, 12 Mar 2014 09:41:44 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so1115056pab.22
        for <linux-mm@kvack.org>; Wed, 12 Mar 2014 06:41:44 -0700 (PDT)
Received: from qmta07.emeryville.ca.mail.comcast.net (qmta07.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:64])
        by mx.google.com with ESMTP id a3si2400706pay.78.2014.03.12.06.41.43
        for <linux-mm@kvack.org>;
        Wed, 12 Mar 2014 06:41:43 -0700 (PDT)
Date: Wed, 12 Mar 2014 08:41:40 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Node 0 not necessary for powerpc?
In-Reply-To: <20140311195632.GA946@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1403120839110.6865@nuc>
References: <20140311195632.GA946@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, anton@samba.org, rientjes@google.com, benh@kernel.crashing.org

On Tue, 11 Mar 2014, Nishanth Aravamudan wrote:
> I have a P7 system that has no node0, but a node0 shows up in numactl
> --hardware, which has no cpus and no memory (and no PCI devices):

Well as you see from the code there has been so far the assumption that
node 0 has memory. I have never run a machine that has no node 0 memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
