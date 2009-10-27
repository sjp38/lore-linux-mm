Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6811D6B0044
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 15:59:10 -0400 (EDT)
Date: Tue, 27 Oct 2009 13:59:07 -0600
From: Alex Chiang <achiang@hp.com>
Subject: Re: [PATCH v2 1/5] mm: add numa node symlink for memory section in
	sysfs
Message-ID: <20091027195907.GJ14102@ldl.fc.hp.com>
References: <20091022040814.15705.95572.stgit@bob.kio> <20091022041510.15705.5410.stgit@bob.kio> <alpine.DEB.2.00.0910221249030.26631@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0910221249030.26631@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, Gary Hade <garyhade@us.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Badari Pulavarty <pbadari@us.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Thank you for ACKing, David.

S390 guys, I cc'ed you on this patch because I heard a rumour
that your memory sections may belong to more than one NUMA node?
Is that true? If so, how would you like me to handle that
situation?

Any comments on this patch series would be appreciated.

Thanks.
/ac

* David Rientjes <rientjes@google.com>:
> On Wed, 21 Oct 2009, Alex Chiang wrote:
> 
> > Commit c04fc586c (mm: show node to memory section relationship with
> > symlinks in sysfs) created symlinks from nodes to memory sections, e.g.
> > 
> > /sys/devices/system/node/node1/memory135 -> ../../memory/memory135
> > 
> > If you're examining the memory section though and are wondering what
> > node it might belong to, you can find it by grovelling around in
> > sysfs, but it's a little cumbersome.
> > 
> > Add a reverse symlink for each memory section that points back to the
> > node to which it belongs.
> > 
> > Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> > Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> > Cc: Gary Hade <garyhade@us.ibm.com>
> > Cc: Badari Pulavarty <pbadari@us.ibm.com>
> > Cc: Ingo Molnar <mingo@elte.hu>
> > Signed-off-by: Alex Chiang <achiang@hp.com>
> 
> Acked-by: David Rientjes <rientjes@google.com>
> 
> Very helpful backlinks to memory section nodes even though I have lots of 
> memory directories on some of my test machines :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
