Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 80B466B0044
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 05:03:51 -0400 (EDT)
Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id n9S93lWD001638
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 02:03:47 -0700
Received: from pwj8 (pwj8.prod.google.com [10.241.219.72])
	by zps37.corp.google.com with ESMTP id n9S93iJt025473
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 02:03:45 -0700
Received: by pwj8 with SMTP id 8so719605pwj.3
        for <linux-mm@kvack.org>; Wed, 28 Oct 2009 02:03:44 -0700 (PDT)
Date: Wed, 28 Oct 2009 02:03:41 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 1/5] mm: add numa node symlink for memory section in
 sysfs
In-Reply-To: <20091028083137.GA24140@osiris.boeblingen.de.ibm.com>
Message-ID: <alpine.DEB.2.00.0910280159380.7122@chino.kir.corp.google.com>
References: <20091022040814.15705.95572.stgit@bob.kio> <20091022041510.15705.5410.stgit@bob.kio> <alpine.DEB.2.00.0910221249030.26631@chino.kir.corp.google.com> <20091027195907.GJ14102@ldl.fc.hp.com> <alpine.DEB.2.00.0910271422090.22335@chino.kir.corp.google.com>
 <20091028083137.GA24140@osiris.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Alex Chiang <achiang@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Gary Hade <garyhade@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Badari Pulavarty <pbadari@us.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Wed, 28 Oct 2009, Heiko Carstens wrote:

> The short answer is: s390 doesn't support NUMA, because the hardware doesn't
> tell us to which node (book in s390 terms) a memory range belongs to.
> 
> Memory layout for a logical partition is striped: first x mbyte belong to
> node 0, next x mbyte belong to node 1, etc...
> 
> Also, since there is always a hypervisor running below Linux I don't think
> it would make too much sense if we would know to which node a piece of
> memory belongs to: if the hypervisor decides to schedule a virtual cpu of
> a logical partition to a different node then what?
> 

Ok, so the patchset is a no-op for s390 since it only utilizes the 
!CONFIG_NUMA code.

Alex, I think the safest thing to do in unregister_mem_sect_under_nodes() 
is to iterate though the section pfns and remove links to the node_device 
kobjs for all the distinct pfn_to_nid()'s that it encounters.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
