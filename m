Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3799B6B0073
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 13:16:03 -0400 (EDT)
Date: Wed, 28 Oct 2009 11:15:58 -0600
From: Alex Chiang <achiang@hp.com>
Subject: Re: [PATCH v2 1/5] mm: add numa node symlink for memory section in
	sysfs
Message-ID: <20091028171558.GB22743@ldl.fc.hp.com>
References: <20091022040814.15705.95572.stgit@bob.kio> <20091022041510.15705.5410.stgit@bob.kio> <alpine.DEB.2.00.0910221249030.26631@chino.kir.corp.google.com> <20091027195907.GJ14102@ldl.fc.hp.com> <alpine.DEB.2.00.0910271422090.22335@chino.kir.corp.google.com> <20091028083137.GA24140@osiris.boeblingen.de.ibm.com> <alpine.DEB.2.00.0910280159380.7122@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0910280159380.7122@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Gary Hade <garyhade@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Badari Pulavarty <pbadari@us.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

* David Rientjes <rientjes@google.com>:
> On Wed, 28 Oct 2009, Heiko Carstens wrote:
> 
> > The short answer is: s390 doesn't support NUMA, because the hardware doesn't
> > tell us to which node (book in s390 terms) a memory range belongs to.
> > 
> > Memory layout for a logical partition is striped: first x mbyte belong to
> > node 0, next x mbyte belong to node 1, etc...
> > 
> > Also, since there is always a hypervisor running below Linux I don't think
> > it would make too much sense if we would know to which node a piece of
> > memory belongs to: if the hypervisor decides to schedule a virtual cpu of
> > a logical partition to a different node then what?
> > 
> 
> Ok, so the patchset is a no-op for s390 since it only utilizes the 
> !CONFIG_NUMA code.

Sounds good.

> Alex, I think the safest thing to do in unregister_mem_sect_under_nodes() 
> is to iterate though the section pfns and remove links to the node_device 
> kobjs for all the distinct pfn_to_nid()'s that it encounters.

Ok, I will respin.

Thanks!
/ac

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
