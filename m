Date: Thu, 22 Aug 2002 21:48:26 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [Lse-tech] [patch] SImple Topology API v0.3 (1/2)
Message-ID: <20020822214826.A32384@infradead.org>
References: <3D6537D3.3080905@us.ibm.com> <20020822202239.A30036@infradead.org> <3D654C8F.30400@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D654C8F.30400@us.ibm.com>; from colpatch@us.ibm.com on Thu, Aug 22, 2002 at 01:41:51PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: Andrew Morton <akpm@zip.com.au>, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Martin Bligh <mjbligh@us.ibm.com>, Andrea Arcangeli <andrea@suse.de>, Michael Hohnbaum <hohnbaum@us.ibm.com>, lse-tech <lse-tech@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 22, 2002 at 01:41:51PM -0700, Matthew Dobson wrote:
> The file asm/mmzone.h needs to be included in both the CONFIG_DISCONTIGMEM and 
> !CONFIG_DISCONTIGMEM cases (at least after my patch).  This just pulls the 
> #include out of the #ifdefs.

Maybe I've noticed that myself?  But why do you suddenly break every port
of execept of i386,ia64, alpha and mips64?  What is the reason your patch
needs this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
