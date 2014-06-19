Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id A937E6B0036
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 10:59:53 -0400 (EDT)
Received: by mail-qg0-f45.google.com with SMTP id 63so2161459qgz.4
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 07:59:53 -0700 (PDT)
Received: from mail-qa0-x229.google.com (mail-qa0-x229.google.com [2607:f8b0:400d:c00::229])
        by mx.google.com with ESMTPS id t5si6560289qga.16.2014.06.19.07.59.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 19 Jun 2014 07:59:53 -0700 (PDT)
Received: by mail-qa0-f41.google.com with SMTP id cm18so2072132qab.28
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 07:59:53 -0700 (PDT)
Date: Thu, 19 Jun 2014 10:59:50 -0400
From: Tejun Heo <htejun@gmail.com>
Subject: Re: Node 0 not necessary for powerpc?
Message-ID: <20140619145950.GG26904@htj.dyndns.org>
References: <20140311195632.GA946@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1403120839110.6865@nuc>
 <20140313164949.GC22247@linux.vnet.ibm.com>
 <20140519182400.GM8941@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1405210915170.7859@gentwo.org>
 <20140521185812.GA5259@htj.dyndns.org>
 <20140521195743.GA5755@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1406091447240.5271@chino.kir.corp.google.com>
 <20140610233157.GB24463@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140610233157.GB24463@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, anton@samba.org, benh@kernel.crashing.org, tony.luck@intel.com

On Tue, Jun 10, 2014 at 04:31:57PM -0700, Nishanth Aravamudan wrote:
> > I think what this really wants to do is NODE_DATA(cpu_to_mem(cpu)) and I 
> > thought ppc had the cpu-to-local-memory-node mappings correct?
> 
> Except cpu_to_mem relies on the mapping being defined, but early in
> boot, specifically, it isn't yet (at least not necessarily).

Can't ppc NODE_DATA simply return dummy generic node_data during early
boot?  Populating it with just enough to make early boot work
shouldn't be too hard, right?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
