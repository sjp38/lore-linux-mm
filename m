Date: Wed, 31 Dec 2003 12:00:19 +0100
From: Tomas Szepe <szepe@pinerecords.com>
Subject: Re: 2.6.0-rc1-mm1
Message-ID: <20031231110019.GE16860@louise.pinerecords.com>
References: <20031231004725.535a89e4.akpm@osdl.org> <20031231101907.GB16860@louise.pinerecords.com> <20031231024855.0aca5e52.akpm@osdl.org> <20031231104947.GC16860@louise.pinerecords.com> <20031231025752.754fd926.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20031231025752.754fd926.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, davem@redhat.com
List-ID: <linux-mm.kvack.org>

On Dec-31 2003, Wed, 02:57 -0800
Andrew Morton <akpm@osdl.org> wrote:

> Tomas Szepe <szepe@pinerecords.com> wrote:
> >
> > What I did was:
> 
> Well that just reverts the recent change back to the way it was.  I assume
> that change was made for a reason.  But with such a lame changelog I am not
> able to say what it was.   No doubt Dave will hunt down the perps ;)

Let's not drag Dave out of bed. :)
Here's the explanation (and a fix) from Bart De Schuymer.

-- 
Tomas Szepe <szepe@pinerecords.com>

From: Bart De Schuymer <bdschuym@pandora.be>
To: "David S.Miller" <davem@redhat.com>
Cc: netdev <netdev@oss.sgi.com>, Tomas Szepe <szepe@pinerecords.com>
Subject: [PATCH] Always copy and save the vlan header in bridge-nf (do it right now)
Date: Wed, 31 Dec 2003 11:56:11 +0100

Hi Dave,

I forgot to get rid of another ifdef in netfilter_bridge.h when I removed
the dependency upon vlan being compiled. This patch fixes it.

cheers,
Bart

--- linux-2.6.0-bk3/include/linux/netfilter_bridge.h.earlier	2003-12-31 11:54:25.000000000 +0100
+++ linux-2.6.0-bk3/include/linux/netfilter_bridge.h	2003-12-31 11:54:47.000000000 +0100
@@ -8,10 +8,8 @@
 #include <linux/netfilter.h>
 #if defined(__KERNEL__) && defined(CONFIG_BRIDGE_NETFILTER)
 #include <asm/atomic.h>
-#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 #include <linux/if_ether.h>
 #endif
-#endif
 
 /* Bridge Hooks */
 /* After promisc drops, checksum checks. */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
