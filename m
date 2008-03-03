Received: by el-out-1112.google.com with SMTP id y26so85108ele.4
        for <linux-mm@kvack.org>; Mon, 03 Mar 2008 07:44:51 -0800 (PST)
Message-ID: <6934efce0803030744w6946e74an113d359c398415cd@mail.gmail.com>
Date: Mon, 3 Mar 2008 07:44:50 -0800
From: "Jared Hulbert" <jaredeh@gmail.com>
Subject: Re: [patch 4/6] xip: support non-struct page backed memory
In-Reply-To: <47CBB44D.7040203@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080118045649.334391000@suse.de>
	 <20080118045755.735923000@suse.de>
	 <6934efce0803010014p2cc9a5edu5fee2029c0104a07@mail.gmail.com>
	 <47CBB44D.7040203@de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: carsteno@de.ibm.com
Cc: npiggin@suse.de, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, mschwid2@linux.vnet.ibm.com, heicars2@linux.vnet.ibm.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>  Is there a chance virt_to_phys() can be fixed on arm? It looks like a
>  simple page table walk to me.

Are there functions already available for doing a page table walk?  If
so it could be done. I'd like that.  If somebody could point me in the
right direction I'd appreciate it.

It might be a problem because today the simple case for virt_to_phys()
just subtracts 0x20000000 to go from 0xCXXXXXXX to 0xAXXXXXXX.  So it
could have a negative performance if we complicate it.

Is it possible that it might be easier to fix this if we changed
ioremap()?  I got the impression that ioremap() on ARM ends up placing
ioremap()'ed memory in the middle of the 0xCXXXXXXX range that is
valid for RAM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
