Date: Mon, 12 Feb 2007 15:08:02 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: build error: allnoconfig fails on mincore/swapper_space
Message-Id: <20070212150802.f240e94f.akpm@linux-foundation.org>
In-Reply-To: <20070212145040.c3aea56e.randy.dunlap@oracle.com>
References: <20070212145040.c3aea56e.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

> On Mon, 12 Feb 2007 14:50:40 -0800 Randy Dunlap <randy.dunlap@oracle.com> wrote:
> 2.6.20-git8 on x86_64:
> 
> 
>   LD      init/built-in.o
>   LD      .tmp_vmlinux1
> mm/built-in.o: In function `sys_mincore':
> (.text+0xe584): undefined reference to `swapper_space'
> make: *** [.tmp_vmlinux1] Error 1

oops.  CONFIG_SWAP=n,  I assume?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
