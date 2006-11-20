Received: from rgmgw3.us.oracle.com (rgmgw3.us.oracle.com [138.1.186.112])
	by rgminet01.oracle.com (Switch-3.2.4/Switch-3.1.6) with ESMTP id kAK55Xam021004
	for <linux-mm@kvack.org>; Sun, 19 Nov 2006 22:05:34 -0700
Received: from midway.site (dhcp-amer-csvpn-gw1-141-144-64-78.vpn.oracle.com [141.144.64.78])
	by rgmgw3.us.oracle.com (Switch-3.2.4/Switch-3.1.7) with SMTP id kAK55UC2005786
	for <linux-mm@kvack.org>; Sun, 19 Nov 2006 22:05:32 -0700
Date: Sun, 19 Nov 2006 21:05:45 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: build error: sparsemem + SLOB
Message-Id: <20061119210545.9708e366.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

  LD      .tmp_vmlinux1
mm/built-in.o: In function `sparse_index_init':
sparse.c:(.text.sparse_index_init+0x19): undefined reference to `slab_is_available'
make: *** [.tmp_vmlinux1] Error 1


mm/sparse.c: line 35 uses slab_is_available() but SLAB=n, SLOB=y.

---
~Randy
full config: http://oss.oracle.com/~rdunlap/configs/config-slob-sparse
(a randconfig)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
