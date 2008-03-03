Received: by gv-out-0910.google.com with SMTP id n8so266976gve.19
        for <linux-mm@kvack.org>; Mon, 03 Mar 2008 15:25:17 -0800 (PST)
Message-ID: <6934efce0803031525s3d95f429g2b5a0ed742f6230d@mail.gmail.com>
Date: Mon, 3 Mar 2008 15:25:15 -0800
From: "Jared Hulbert" <jaredeh@gmail.com>
Subject: Re: [patch 4/6] xip: support non-struct page backed memory
In-Reply-To: <alpine.LFD.1.00.0803031420430.2979@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080118045649.334391000@suse.de>
	 <20080118045755.735923000@suse.de>
	 <6934efce0803010014p2cc9a5edu5fee2029c0104a07@mail.gmail.com>
	 <47CBB44D.7040203@de.ibm.com>
	 <alpine.LFD.1.00.0803031037560.17889@woody.linux-foundation.org>
	 <6934efce0803031138g725f0ec4ra683d56615b7dbe0@mail.gmail.com>
	 <alpine.LFD.1.00.0803031152240.17889@woody.linux-foundation.org>
	 <20080303203202.GI8974@wotan.suse.de>
	 <alpine.LFD.1.00.0803031420430.2979@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, carsteno@de.ibm.com, Andrew Morton <akpm@linux-foundation.org>, mschwid2@linux.vnet.ibm.com, heicars2@linux.vnet.ibm.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>  Implementing a kmap_pfn() sounds like a perfectly sane idea. But why does
>  it need to even be mapped into kernel space? Is it for the ELF header
>  reading or something (not having looked at the patch, just reacting to the
>  wrongness of using virt_to_phys())?

Right.

My AXFS prefers the filesystem image to be in memory like Flash.  So
it also uses the kaddr to read it's data structures and to fetch data
for the readpage().  In fact, the MTD doesn't provide access to the
physical address of a given partition without a patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
