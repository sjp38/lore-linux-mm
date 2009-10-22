Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BBCAD6B0071
	for <linux-mm@kvack.org>; Thu, 22 Oct 2009 15:51:34 -0400 (EDT)
Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id n9MJpUjS003921
	for <linux-mm@kvack.org>; Thu, 22 Oct 2009 12:51:30 -0700
Received: from pxi31 (pxi31.prod.google.com [10.243.27.31])
	by zps38.corp.google.com with ESMTP id n9MJpSev003886
	for <linux-mm@kvack.org>; Thu, 22 Oct 2009 12:51:28 -0700
Received: by pxi31 with SMTP id 31so1547191pxi.20
        for <linux-mm@kvack.org>; Thu, 22 Oct 2009 12:51:28 -0700 (PDT)
Date: Thu, 22 Oct 2009 12:51:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 1/5] mm: add numa node symlink for memory section in
 sysfs
In-Reply-To: <20091022041510.15705.5410.stgit@bob.kio>
Message-ID: <alpine.DEB.2.00.0910221249030.26631@chino.kir.corp.google.com>
References: <20091022040814.15705.95572.stgit@bob.kio> <20091022041510.15705.5410.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alex Chiang <achiang@hp.com>
Cc: akpm@linux-foundation.org, Gary Hade <garyhade@us.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Badari Pulavarty <pbadari@us.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Wed, 21 Oct 2009, Alex Chiang wrote:

> Commit c04fc586c (mm: show node to memory section relationship with
> symlinks in sysfs) created symlinks from nodes to memory sections, e.g.
> 
> /sys/devices/system/node/node1/memory135 -> ../../memory/memory135
> 
> If you're examining the memory section though and are wondering what
> node it might belong to, you can find it by grovelling around in
> sysfs, but it's a little cumbersome.
> 
> Add a reverse symlink for each memory section that points back to the
> node to which it belongs.
> 
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Gary Hade <garyhade@us.ibm.com>
> Cc: Badari Pulavarty <pbadari@us.ibm.com>
> Cc: Ingo Molnar <mingo@elte.hu>
> Signed-off-by: Alex Chiang <achiang@hp.com>

Acked-by: David Rientjes <rientjes@google.com>

Very helpful backlinks to memory section nodes even though I have lots of 
memory directories on some of my test machines :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
