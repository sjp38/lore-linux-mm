Date: Tue, 13 May 2003 00:11:35 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.69-mm4
Message-Id: <20030513001135.2395860a.akpm@digeo.com>
In-Reply-To: <87vfwf8h2n.fsf@lapper.ihatent.com>
References: <20030512225504.4baca409.akpm@digeo.com>
	<87vfwf8h2n.fsf@lapper.ihatent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Hoogerhuis <alexh@ihatent.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alexander Hoogerhuis <alexh@ihatent.com> wrote:
>
> net/core/dev.c:1496: conflicting types for `handle_bridge'
>  net/core/dev.c:1468: previous declaration of `handle_bridge'

argh, sorry, stupid.

diff -puN net/core/dev.c~handle_bridge-fix net/core/dev.c
--- 25/net/core/dev.c~handle_bridge-fix	2003-05-13 00:10:47.000000000 -0700
+++ 25-akpm/net/core/dev.c	2003-05-13 00:10:57.000000000 -0700
@@ -1491,7 +1491,7 @@ static inline void handle_diverter(struc
 #endif
 }
 
-static inline int handle_bridge(struct sk_buff *skb,
+static inline int __handle_bridge(struct sk_buff *skb,
 			struct packet_type **pt_prev, int *ret)
 {
 #if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
@@ -1548,7 +1548,7 @@ int netif_receive_skb(struct sk_buff *sk
 
 	handle_diverter(skb);
 
-	if (handle_bridge(skb, &pt_prev, &ret))
+	if (__handle_bridge(skb, &pt_prev, &ret))
 		goto out;
 
 	list_for_each_entry_rcu(ptype, &ptype_base[ntohs(type)&15], list) {

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
