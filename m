Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id 93C716B003B
	for <linux-mm@kvack.org>; Tue, 25 Mar 2014 12:23:23 -0400 (EDT)
Received: by mail-qa0-f51.google.com with SMTP id j7so769561qaq.10
        for <linux-mm@kvack.org>; Tue, 25 Mar 2014 09:23:23 -0700 (PDT)
Received: from e9.ny.us.ibm.com (e9.ny.us.ibm.com. [32.97.182.139])
        by mx.google.com with ESMTPS id c3si1757038qan.201.2014.03.25.09.23.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 25 Mar 2014 09:23:23 -0700 (PDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Tue, 25 Mar 2014 12:23:22 -0400
Received: from b01cxnp23032.gho.pok.ibm.com (b01cxnp23032.gho.pok.ibm.com [9.57.198.27])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 5F1656E803F
	for <linux-mm@kvack.org>; Tue, 25 Mar 2014 12:23:13 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp23032.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2PGNJdx66125958
	for <linux-mm@kvack.org>; Tue, 25 Mar 2014 16:23:19 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2PGNIP2014026
	for <linux-mm@kvack.org>; Tue, 25 Mar 2014 12:23:19 -0400
Date: Tue, 25 Mar 2014 09:23:03 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: Bug in reclaim logic with exhausted nodes?
Message-ID: <20140325162303.GA29977@linux.vnet.ibm.com>
References: <20140311210614.GB946@linux.vnet.ibm.com>
 <20140313170127.GE22247@linux.vnet.ibm.com>
 <20140324230550.GB18778@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1403251116490.16557@nuc>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1403251116490.16557@nuc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, rientjes@google.com, linuxppc-dev@lists.ozlabs.org, anton@samba.org, mgorman@suse.de

On 25.03.2014 [11:17:57 -0500], Christoph Lameter wrote:
> On Mon, 24 Mar 2014, Nishanth Aravamudan wrote:
> 
> > Anyone have any ideas here?
> 
> Dont do that? Check on boot to not allow exhausting a node with huge
> pages?

Gigantic hugepages are allocated by the hypervisor (not the Linux VM),
and we don't control where the allocation occurs. Yes, ideally, they
would be interleaved to avoid this situation, but I can also see reasons
for having them all be from one node so that tasks can be affinitized
and get the guarantee of the 16GB pagesize benefit.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
