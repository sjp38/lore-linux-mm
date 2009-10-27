Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6A0B76B0044
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 17:28:06 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id n9RLS2p3018993
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 14:28:02 -0700
Received: from pxi32 (pxi32.prod.google.com [10.243.27.32])
	by wpaz17.hot.corp.google.com with ESMTP id n9RLRaRu007271
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 14:27:59 -0700
Received: by pxi32 with SMTP id 32so101328pxi.16
        for <linux-mm@kvack.org>; Tue, 27 Oct 2009 14:27:59 -0700 (PDT)
Date: Tue, 27 Oct 2009 14:27:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 1/5] mm: add numa node symlink for memory section in
 sysfs
In-Reply-To: <20091027195907.GJ14102@ldl.fc.hp.com>
Message-ID: <alpine.DEB.2.00.0910271422090.22335@chino.kir.corp.google.com>
References: <20091022040814.15705.95572.stgit@bob.kio> <20091022041510.15705.5410.stgit@bob.kio> <alpine.DEB.2.00.0910221249030.26631@chino.kir.corp.google.com> <20091027195907.GJ14102@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alex Chiang <achiang@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gary Hade <garyhade@us.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Badari Pulavarty <pbadari@us.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, 27 Oct 2009, Alex Chiang wrote:

> Thank you for ACKing, David.
> 
> S390 guys, I cc'ed you on this patch because I heard a rumour
> that your memory sections may belong to more than one NUMA node?
> Is that true? If so, how would you like me to handle that
> situation?
> 

You're referring to how unregister_mem_sect_under_nodes() should be 
handled, right?  register_mem_sect_under_node() already looks supported by 
your patch.

Since the unregister function includes a plural "nodes," I assume that 
it's possible for hotplug to register a memory section to more than one 
node.  That's probably lacking on x86 currently, however, because we lack 
node hotplug.

I'd suggest a similiar iteration through pfn's that the register function 
does checking for multiple nodes and then removing the link from all 
applicable node_devices kobj when unregistering.

Maybe one of the s390 maintainers will test that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
