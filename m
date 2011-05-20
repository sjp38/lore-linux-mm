Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B924A6B0022
	for <linux-mm@kvack.org>; Fri, 20 May 2011 02:18:29 -0400 (EDT)
Date: Fri, 20 May 2011 16:18:16 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree
Message-Id: <20110520161816.dda6f1fd.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus <torvalds@linux-foundation.org>
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Dipankar Sarma <dipankar@in.ibm.com>

Hi all,

After merging the final tree, today's linux-next build (sparc32 defconfig)
failed like this:

mm/page_alloc.c: In function '__free_pages_bootmem':
mm/page_alloc.c:704: error: implicit declaration of function 'prefetchw'
fs/dcache.c: In function '__d_lookup_rcu':
fs/dcache.c:1810: error: implicit declaration of function 'prefetch'
fs/inode.c: In function 'new_inode':
fs/inode.c:894: error: implicit declaration of function 'spin_lock_prefetch'
net/core/skbuff.c: In function '__alloc_skb':
net/core/skbuff.c:184: error: implicit declaration of function 'prefetchw'
In file included from net/ipv4/ip_forward.c:32:
include/net/udp.h: In function 'udp_csum_outgoing':
include/net/udp.h:141: error: implicit declaration of function 'prefetch'
In file included from net/ipv6/af_inet6.c:48:
include/net/udp.h: In function 'udp_csum_outgoing':
include/net/udp.h:141: error: implicit declaration of function 'prefetch'
net/unix/af_unix.c: In function 'unix_ioctl':
net/unix/af_unix.c:2066: error: implicit declaration of function 'prefetch'
In file included from net/sunrpc/xprtsock.c:44:
include/net/udp.h: In function 'udp_csum_outgoing':
include/net/udp.h:141: error: implicit declaration of function 'prefetch'
kernel/rcutiny.c: In function 'rcu_process_callbacks':
kernel/rcutiny.c:180: error: implicit declaration of function 'prefetch'

Caused by commit e66eed651fd1 ("list: remove prefetching from regular list
iterators").

I added the following patch for today:
