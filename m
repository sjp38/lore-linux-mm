Received: from xparelay1.corp.hp.com (unknown [15.58.136.173])
	by palrel1.hp.com (Postfix) with ESMTP id A508536AA
	for <linux-mm@kvack.org>; Tue, 19 Jun 2001 04:00:49 -0700 (PDT)
Received: from xpabh1.corp.hp.com (xpabh1.corp.hp.com [15.58.136.191])
	by xparelay1.corp.hp.com (Postfix) with ESMTP id C24C91F542
	for <linux-mm@kvack.org>; Mon, 18 Jun 2001 21:00:02 -0700 (PDT)
Message-ID: <F341E03C8ED6D311805E00902761278C07EFA675@xfc04.fc.hp.com>
From: "ZINKEVICIUS,MATT (HP-Loveland,ex1)" <matt_zinkevicius@hp.com>
Subject: 2.4.6pre3: kswapd dominating CPU
Date: Mon, 18 Jun 2001 17:12:44 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi gang,
For a while now 2.4 kernels have been a little flaky for us with regards to
memory management. We had chalked this up to the known VM updates going on
and have ignored and worked around it as much as we could. Now that
2.4.6pre3 is out and supposedly VM friendly and we are still seeing our
original problem I thought it was time I submitted the details to you guys
to get some help.

We are benchmarking NFS with SpecSFS 97 version 2. When the machine gets
close to running out of physical memory (according to top) kswapd quickly
become the most active process (98% CPU time). This occurs whether or not we
have any swap space enabled! The nfsd daemons get starved and our
performance drops to null. If we kill the benchmark things settle down
immediately, but we never get any memory back and afterwards if we run
anything even slightly stressful (iozone) the problem appears again
immediately. The only solution we've found is to reboot. This seems related
to whether we enable highmem in the kernel, as this problem only appears
when highmem is set to 4GB or 64GB. Any hints?

Server specs:
HP LT6000r server
4 x 700Mhz P3Xeons
4GB RAM
1GB swap partition
2.4.6pre3 kernel

Matt Zinkevicius
Modular Network Storage
Hewlett-Packard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
