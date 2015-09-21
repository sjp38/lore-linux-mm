Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3B26B6B0253
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 03:52:33 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so109765133pac.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 00:52:33 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id lj9si35895234pbc.51.2015.09.21.00.52.32
        for <linux-mm@kvack.org>;
        Mon, 21 Sep 2015 00:52:32 -0700 (PDT)
Date: Mon, 21 Sep 2015 15:51:57 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-next:master 2561/2564] net/ipv4/route.c:1695:21: sparse:
 Using plain integer as NULL pointer
Message-ID: <201509211549.r7k7CVCa%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   caf2c1caaba179d0943d0358f95ac53b19a803b3
commit: b4102a1a6474fdbb3b49bc402c5270a8c28690ae [2561/2564] net/ipv4/route.c: prevent oops
reproduce:
  # apt-get install sparse
  git checkout b4102a1a6474fdbb3b49bc402c5270a8c28690ae
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> net/ipv4/route.c:1695:21: sparse: Using plain integer as NULL pointer

vim +1695 net/ipv4/route.c

  1679	 */
  1680	
  1681	static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
  1682				       u8 tos, struct net_device *dev)
  1683	{
  1684		struct fib_result res;
  1685		struct in_device *in_dev = __in_dev_get_rcu(dev);
  1686		struct ip_tunnel_info *tun_info;
  1687		struct flowi4	fl4;
  1688		unsigned int	flags = 0;
  1689		u32		itag = 0;
  1690		struct rtable	*rth;
  1691		int		err = -EINVAL;
  1692		struct net    *net = dev_net(dev);
  1693		bool do_cache;
  1694	
> 1695		res.table = 0;
  1696	
  1697		/* IP on this device is disabled. */
  1698	
  1699		if (!in_dev)
  1700			goto out;
  1701	
  1702		/* Check for the most weird martians, which can be not detected
  1703		   by fib_lookup.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
