Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id E43896B002B
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 15:43:55 -0400 (EDT)
Received: by pbbrq2 with SMTP id rq2so747022pbb.14
        for <linux-mm@kvack.org>; Tue, 25 Sep 2012 12:43:55 -0700 (PDT)
Date: Tue, 25 Sep 2012 12:43:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: mmotm 2012-09-20-17-25 uploaded (fs/bimfmt_elf on uml)
In-Reply-To: <20120922115606.5ca9f599cd88514ddda4831d@canb.auug.org.au>
Message-ID: <alpine.DEB.2.00.1209251243320.31518@chino.kir.corp.google.com>
References: <20120921002638.7859F100047@wpzn3.hot.corp.google.com> <505C865D.5090802@xenotime.net> <20120922115606.5ca9f599cd88514ddda4831d@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Randy Dunlap <rdunlap@xenotime.net>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, Richard Weinberger <richard@nod.at>

On Sat, 22 Sep 2012, Stephen Rothwell wrote:

> > on uml for x86_64 defconfig:
> > 
> > fs/binfmt_elf.c: In function 'fill_files_note':
> > fs/binfmt_elf.c:1419:2: error: implicit declaration of function 'vmalloc'
> > fs/binfmt_elf.c:1419:7: warning: assignment makes pointer from integer without a cast
> > fs/binfmt_elf.c:1437:5: error: implicit declaration of function 'vfree'
> 
> reported in linux-next (offending patch reverted for other
> problems).
> 

This still happens on x86_64 for linux-next as of today's tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
