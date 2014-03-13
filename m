Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 500026B0036
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 12:50:11 -0400 (EDT)
Received: by mail-ob0-f175.google.com with SMTP id uy5so1311245obc.34
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 09:50:11 -0700 (PDT)
Received: from e9.ny.us.ibm.com (e9.ny.us.ibm.com. [32.97.182.139])
        by mx.google.com with ESMTPS id iz10si3052008obb.130.2014.03.13.09.50.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 13 Mar 2014 09:50:10 -0700 (PDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Thu, 13 Mar 2014 12:50:09 -0400
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 2C1456E804B
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 12:50:02 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp22035.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2DGo7Bq7012804
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 16:50:07 GMT
Received: from d01av04.pok.ibm.com (localhost [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2DGo72A030720
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 12:50:07 -0400
Date: Thu, 13 Mar 2014 09:49:50 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: Node 0 not necessary for powerpc?
Message-ID: <20140313164949.GC22247@linux.vnet.ibm.com>
References: <20140311195632.GA946@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1403120839110.6865@nuc>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1403120839110.6865@nuc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, anton@samba.org, rientjes@google.com, benh@kernel.crashing.org

On 12.03.2014 [08:41:40 -0500], Christoph Lameter wrote:
> On Tue, 11 Mar 2014, Nishanth Aravamudan wrote:
> > I have a P7 system that has no node0, but a node0 shows up in numactl
> > --hardware, which has no cpus and no memory (and no PCI devices):
> 
> Well as you see from the code there has been so far the assumption that
> node 0 has memory. I have never run a machine that has no node 0 memory.

Do you mean beyond the initialization? I didn't see anything obvious so
far in the code itself that assumes a given node has memory (in the
sense of the nid). What are your thoughts about how best to support
this?

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
