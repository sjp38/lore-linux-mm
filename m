Date: Wed, 31 Dec 2003 11:19:07 +0100
From: Tomas Szepe <szepe@pinerecords.com>
Subject: Re: 2.6.0-rc1-mm1
Message-ID: <20031231101907.GB16860@louise.pinerecords.com>
References: <20031231004725.535a89e4.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20031231004725.535a89e4.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Dec-31 2003, Wed, 00:47 -0800
Andrew Morton <akpm@osdl.org> wrote:

> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.1-rc1/2.6.1-rc1-mm1/
> A few small additions, but mainly a resync with mainline.

In file included from include/linux/netfilter_bridge/ebtables.h:16,
                 from net/bridge/netfilter/ebtables.c:25:
include/linux/netfilter_bridge.h: In function `nf_bridge_maybe_copy_header':
include/linux/netfilter_bridge.h:74: error: `ETH_P_8021Q' undeclared (first use in this function)
include/linux/netfilter_bridge.h:74: error: (Each undeclared identifier is reported only once
include/linux/netfilter_bridge.h:74: error: for each function it appears in.)
include/linux/netfilter_bridge.h: In function `nf_bridge_save_header':
include/linux/netfilter_bridge.h:87: error: `ETH_P_8021Q' undeclared (first use in this function)
make[3]: *** [net/bridge/netfilter/ebtables.o] Error 1
make[2]: *** [net/bridge/netfilter] Error 2
make[1]: *** [net/bridge] Error 2
make: *** [net] Error 2

-- 
Tomas Szepe <szepe@pinerecords.com>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
