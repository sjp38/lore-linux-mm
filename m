Message-ID: <45D12715.4070408@yahoo.com.au>
Date: Tue, 13 Feb 2007 13:48:53 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: build error: allnoconfig fails on mincore/swapper_space
References: <20070212145040.c3aea56e.randy.dunlap@oracle.com> <20070212150802.f240e94f.akpm@linux-foundation.org>
In-Reply-To: <20070212150802.f240e94f.akpm@linux-foundation.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
>>On Mon, 12 Feb 2007 14:50:40 -0800 Randy Dunlap <randy.dunlap@oracle.com> wrote:
>>2.6.20-git8 on x86_64:
>>
>>
>>  LD      init/built-in.o
>>  LD      .tmp_vmlinux1
>>mm/built-in.o: In function `sys_mincore':
>>(.text+0xe584): undefined reference to `swapper_space'
>>make: *** [.tmp_vmlinux1] Error 1
> 
> 
> oops.  CONFIG_SWAP=n,  I assume?
> 

Hmm, OK. Hugh can strip me of my bonus point now...

Hugh, you can strip me of my bonus point now... How about your other
suggestion to just remove the stats from lookup_swap_cache? (and should
we also rename it to find_get_swap_page?)

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
