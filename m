Date: Sat, 3 May 2003 01:35:25 +1000
From: Anton Blanchard <anton@samba.org>
Subject: Re: 2.5.68-mm4
Message-ID: <20030502153525.GA11939@krispykreme>
References: <20030502020149.1ec3e54f.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030502020149.1ec3e54f.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

> . Included the `kexec' patch - load Linux from Linux.  Various people want
>   this for various reasons.  I like the idea of going from a login prompt to
>   "Calibrating delay loop" in 0.5 seconds.

One thing that bothers me about kexec is how we grab low pages in
kimage_alloc_page(). On a partitioned ppc64 box I will need to grab
memory in the low 256MB and the machine might have 500GB of memory
free. Thats going to take some time :)

Id hate to introduce a separate zone just for this sort of stuff (we
currently throw all memory in the DMA zone). Could we add a hint to
the page allocator where it makes a best effort to grab memory below
a threshold?

Anton
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
