Date: Tue, 08 Jul 2003 22:13:12 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [announce, patch] 4G/4G split on x86, 64 GB RAM (and more) support
Message-ID: <55580000.1057727591@[10.10.2.4]>
In-Reply-To: <Pine.LNX.4.44.0307082332450.17252-100000@localhost.localdomain>
References: <Pine.LNX.4.44.0307082332450.17252-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> i'm pleased to announce the first public release of the "4GB/4GB VM split"
> patch, for the 2.5.74 Linux kernel:
> 
>    http://redhat.com/~mingo/4g-patches/4g-2.5.74-F8

I presume this was for -bk something as it applies clean to -bk6, but not
virgin. 

However, it crashes before console_init on NUMA ;-( I'll shove early printk
in there later.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
