Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m6BD5qji305504
	for <linux-mm@kvack.org>; Fri, 11 Jul 2008 13:05:52 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6BD5q94663766
	for <linux-mm@kvack.org>; Fri, 11 Jul 2008 14:05:52 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6BD5pnP027463
	for <linux-mm@kvack.org>; Fri, 11 Jul 2008 14:05:51 +0100
Subject: Re: [PATCH] Make CONFIG_MIGRATION available w/o NUMA
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
In-Reply-To: <48736D0F.5080208@linux-foundation.org>
References: <1215354957.9842.19.camel@localhost.localdomain>
	 <4872319B.9040809@linux-foundation.org>
	 <1215451689.8431.80.camel@localhost.localdomain>
	 <48725480.1060808@linux-foundation.org>
	 <1215455148.8431.108.camel@localhost.localdomain>
	 <48726158.9010308@linux-foundation.org>
	 <1215514245.4832.7.camel@localhost.localdomain>
	 <48736D0F.5080208@linux-foundation.org>
Content-Type: text/plain
Date: Fri, 11 Jul 2008 15:05:50 +0200
Message-Id: <1215781550.4746.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasunori Goto <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-07-08 at 08:35 -0500, Christoph Lameter wrote:
> Acked-by: Christoph Lameter <cl@linux-foundation.org>
> 
> Small nit: It now looks as if the vma_migratable() function belongs into mempolicy.h and not migrate.h

Right, I'll send a new patch that moves vma_migratable() to mempolicy.h

Thanks,
Gerald


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
