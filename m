Received: from westrelay01.boulder.ibm.com (westrelay01.boulder.ibm.com [9.17.195.10])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j1SNUKua478738
	for <linux-mm@kvack.org>; Mon, 28 Feb 2005 18:30:20 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay01.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j1SNUJe1167058
	for <linux-mm@kvack.org>; Mon, 28 Feb 2005 16:30:20 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j1SNUJ56002135
	for <linux-mm@kvack.org>; Mon, 28 Feb 2005 16:30:19 -0700
Subject: Re: [PATCH 3/5] abstract discontigmem setup
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <E1D5q2Q-0007eV-00@kernel.beaverton.ibm.com>
References: <E1D5q2Q-0007eV-00@kernel.beaverton.ibm.com>
Content-Type: multipart/mixed; boundary="=-E0c7nWu8qtH6CsSR5UHX"
Date: Mon, 28 Feb 2005 15:30:14 -0800
Message-Id: <1109633414.6921.69.camel@localhost>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@osdl.org>, kmannth@us.ibm.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

--=-E0c7nWu8qtH6CsSR5UHX
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

The $SUBJECT patch has a small, obvious, compile bug in it on the
NUMA-Q, which I introduced while cleaning it up.  Please apply this
patch on top of that one.

-- Dave

--=-E0c7nWu8qtH6CsSR5UHX
Content-Disposition: attachment; filename=A3.2.1-fix-numaq.patch
Content-Type: text/x-patch; name=A3.2.1-fix-numaq.patch; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 7bit

The "abstract discontigmem setup" patch has a small compile bug in
it on the NUMA-Q, which I introduced while "cleaning it up."

Please apply after that patch.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 memhotplug-dave/arch/i386/kernel/numaq.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletion(-)

diff -puN arch/i386/kernel/numaq.c~A3.2.1-fix-numaq arch/i386/kernel/numaq.c
--- memhotplug/arch/i386/kernel/numaq.c~A3.2.1-fix-numaq	2005-02-28 14:16:23.000000000 -0800
+++ memhotplug-dave/arch/i386/kernel/numaq.c	2005-02-28 14:16:59.000000000 -0800
@@ -62,7 +62,9 @@ static void __init smp_dump_qct(void)
 
 			memory_present(node,
 				node_start_pfn[node], node_end_pfn[node]);
-			node_remap_size[node] = node_memmap_size_bytes(node);
+			node_remap_size[node] = node_memmap_size_bytes(node,
+							node_start_pfn[node],
+							node_end_pfn[node]);
 		}
 	}
 }
_

--=-E0c7nWu8qtH6CsSR5UHX--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
