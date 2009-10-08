Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8D7626B0055
	for <linux-mm@kvack.org>; Thu,  8 Oct 2009 16:26:43 -0400 (EDT)
Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id n98KQcEp022698
	for <linux-mm@kvack.org>; Thu, 8 Oct 2009 13:26:38 -0700
Received: from pxi36 (pxi36.prod.google.com [10.243.27.36])
	by zps37.corp.google.com with ESMTP id n98KQQUN022297
	for <linux-mm@kvack.org>; Thu, 8 Oct 2009 13:26:35 -0700
Received: by pxi36 with SMTP id 36so5909964pxi.18
        for <linux-mm@kvack.org>; Thu, 08 Oct 2009 13:26:35 -0700 (PDT)
Date: Thu, 8 Oct 2009 13:26:34 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 6/12] hugetlb:  add generic definition of NUMA_NO_NODE
In-Reply-To: <alpine.DEB.1.10.0910081616040.8030@gentwo.org>
Message-ID: <alpine.DEB.1.00.0910081325200.6998@chino.kir.corp.google.com>
References: <20091008162454.23192.91832.sendpatchset@localhost.localdomain> <20091008162533.23192.71981.sendpatchset@localhost.localdomain> <alpine.DEB.1.10.0910081616040.8030@gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, linux-numa@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Andi Kleen <andi@firstfloor.org>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 8 Oct 2009, Christoph Lameter wrote:

> 
> Would it not be good to convert all the uses of -1 to NUMA_NO_NODE as
> well?
> 

An obvious conversion that could immediately be made would be of NID_INVAL 
in the acpi code.  The x86 pci bus affinity handling also uses -1 to 
specify no node-specific affinity, so it sounds like a legitimate use case 
as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
