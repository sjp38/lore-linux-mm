Date: Wed, 31 Dec 2003 02:48:55 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.0-rc1-mm1
Message-Id: <20031231024855.0aca5e52.akpm@osdl.org>
In-Reply-To: <20031231101907.GB16860@louise.pinerecords.com>
References: <20031231004725.535a89e4.akpm@osdl.org>
	<20031231101907.GB16860@louise.pinerecords.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tomas Szepe <szepe@pinerecords.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

Tomas Szepe <szepe@pinerecords.com> wrote:
>
> In file included from include/linux/netfilter_bridge/ebtables.h:16,
>                  from net/bridge/netfilter/ebtables.c:25:
> include/linux/netfilter_bridge.h: In function `nf_bridge_maybe_copy_header':
> include/linux/netfilter_bridge.h:74: error: `ETH_P_8021Q' undeclared (first use in this function)

This problem also exists in 2.6.1-rc1.


diff -puN include/linux/netfilter_bridge.h~netfilter_bridge-compile-fix include/linux/netfilter_bridge.h
--- 25/include/linux/netfilter_bridge.h~netfilter_bridge-compile-fix	2003-12-31 02:46:14.000000000 -0800
+++ 25-akpm/include/linux/netfilter_bridge.h	2003-12-31 02:46:33.000000000 -0800
@@ -5,6 +5,7 @@
  */
 
 #include <linux/config.h>
+#include <linux/if_ether.h>
 #include <linux/netfilter.h>
 #if defined(__KERNEL__) && defined(CONFIG_BRIDGE_NETFILTER)
 #include <asm/atomic.h>

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
