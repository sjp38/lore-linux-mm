Message-ID: <47CD1122.6090807@de.ibm.com>
Date: Tue, 04 Mar 2008 10:06:42 +0100
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: carsteno@de.ibm.com
MIME-Version: 1.0
Subject: Re: [patch 4/6] xip: support non-struct page backed memory
References: <20080118045649.334391000@suse.de> <20080118045755.735923000@suse.de> <6934efce0803010014p2cc9a5edu5fee2029c0104a07@mail.gmail.com> <47CBB44D.7040203@de.ibm.com> <alpine.LFD.1.00.0803031037560.17889@woody.linux-foundation.org> <6934efce0803031138g725f0ec4ra683d56615b7dbe0@mail.gmail.com> <alpine.LFD.1.00.0803031152240.17889@woody.linux-foundation.org> <20080303203202.GI8974@wotan.suse.de> <alpine.LFD.1.00.0803031420430.2979@woody.linux-foundation.org>
In-Reply-To: <alpine.LFD.1.00.0803031420430.2979@woody.linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Jared Hulbert <jaredeh@gmail.com>, carsteno@de.ibm.com, Andrew Morton <akpm@linux-foundation.org>, mschwid2@linux.vnet.ibm.com, heicars2@linux.vnet.ibm.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> Implementing a kmap_pfn() sounds like a perfectly sane idea. But why does 
> it need to even be mapped into kernel space? Is it for the ELF header 
> reading or something (not having looked at the patch, just reacting to the 
> wrongness of using virt_to_phys())?
It needs to be mapped into kernel space to do regular file operations 
other than mmap. In mm/filemap_xip.c we do access the xip memory from 
kernel to fulfill sys_read/sys_write and friends [copy_from/to_user to 
user's buffer].

so long,
Carsten

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
