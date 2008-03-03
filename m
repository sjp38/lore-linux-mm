Received: by gv-out-0910.google.com with SMTP id n8so172645gve.19
        for <linux-mm@kvack.org>; Mon, 03 Mar 2008 11:38:37 -0800 (PST)
Message-ID: <6934efce0803031138g725f0ec4ra683d56615b7dbe0@mail.gmail.com>
Date: Mon, 3 Mar 2008 11:38:35 -0800
From: "Jared Hulbert" <jaredeh@gmail.com>
Subject: Re: [patch 4/6] xip: support non-struct page backed memory
In-Reply-To: <alpine.LFD.1.00.0803031037560.17889@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080118045649.334391000@suse.de>
	 <20080118045755.735923000@suse.de>
	 <6934efce0803010014p2cc9a5edu5fee2029c0104a07@mail.gmail.com>
	 <47CBB44D.7040203@de.ibm.com>
	 <alpine.LFD.1.00.0803031037560.17889@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: carsteno@de.ibm.com, npiggin@suse.de, Andrew Morton <akpm@linux-foundation.org>, mschwid2@linux.vnet.ibm.com, heicars2@linux.vnet.ibm.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>  NO!
>
>  "virt_to_phys()" is about kernel 1:1-mapped virtual addresses, and
>  "fixing" it would be totally wrong.

By 1:1 you mean virtual + offset == physical + offset right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
