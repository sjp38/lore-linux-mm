Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 87D756B005D
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 00:33:34 -0400 (EDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <wangyun@linux.vnet.ibm.com>;
	Fri, 17 Aug 2012 14:32:40 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7H4OfAZ23068742
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 14:24:42 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7H4XQDv026929
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 14:33:26 +1000
Message-ID: <502DC992.4040304@linux.vnet.ibm.com>
Date: Fri, 17 Aug 2012 12:33:22 +0800
From: Michael Wang <wangyun@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 0/3] raid, kmemleak, netfilter: replace list_for_each_continue_rcu
 with new interface
References: <502CB91E.4050304@linux.vnet.ibm.com>
In-Reply-To: <502CB91E.4050304@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-raid@vger.kernel.org, linux-mm@kvack.org, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, netfilter@vger.kernel.org, coreteam@netfilter.org, netfilter-devel@vger.kernel.org
Cc: neilb@suse.de, catalin.marinas@arm.com, David Miller <davem@davemloft.net>, kaber@trash.net, pablo@netfilter.org, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>

From: Michael Wang <wangyun@linux.vnet.ibm.com>

This patch set will replace the list_for_each_continue_rcu with the new
interface list_for_each_entry_continue_rcu, so we could remove the old
one later.

Changed:
	raid:		in "next_active_rdev"
	kmemleak:	in "kmemleak_seq_next"
	netfilter:	in "nf_iterate"	

Tested:
	raid:
		mdadm command with an internal bitmap.
	kmemleak:
		enable kmemleak and check the info it captured.
	netfilter:
		add rule to iptables and check result by ping.
		nfqnl_test which is a test utility of libnetfilter_queue.

	All testing are using printk to make sure the code we want test
	was invoked.

Signed-off-by: Michael Wang <wangyun@linux.vnet.ibm.com>
---
 drivers/md/bitmap.c  |    9 +++------
 mm/kmemleak.c        |    6 ++----
 net/netfilter/core.c |   11 +++++++----
 3 files changed, 12 insertions(+), 14 deletions(-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
