Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id AB0016B0083
	for <linux-mm@kvack.org>; Mon, 21 May 2012 04:09:51 -0400 (EDT)
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ehrhardt@linux.vnet.ibm.com>;
	Mon, 21 May 2012 09:09:50 +0100
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by d06nrmr1307.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4L89JIW2334728
	for <linux-mm@kvack.org>; Mon, 21 May 2012 09:09:19 +0100
Received: from d06av11.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4L89IND004204
	for <linux-mm@kvack.org>; Mon, 21 May 2012 02:09:18 -0600
From: ehrhardt@linux.vnet.ibm.com
Subject: [PATCH 0/2] swap: improve swap I/O rate - V2
Date: Mon, 21 May 2012 10:09:13 +0200
Message-Id: <1337587755-4743-1-git-send-email-ehrhardt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: axboe@kernel.dk, Ehrhardt Christian <ehrhardt@linux.vnet.ibm.com>

From: Ehrhardt Christian <ehrhardt@linux.vnet.ibm.com>

From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>

* Update in V2 *
- Adapted the documentation patch according to feedback of Minchan Kim
- Added the Acks I got to V1 so far

In an memory overcommitment scneario with KVM I ran into a lot of waits for
swap. While checking the I/O done on the swap disks I found almost all I/Os
to be done as single page 4k request. Despite the fact that swap in is a
batch of 1<<page-cluster pages as swap readahead and swap out is a list of
pages written in shrink_page_list.

[1/2 swap in improvment]
The read patch shows improvements of up to 50% swap throughput, much happier
guest systems and even when running with comparable throughput a lot I/O per
seconds saved leaving resources in the SAN for other consumers.

[2/2 documentation]
While doing so I also realized that the documentation for
proc/sys/vm/page-cluster is no more matching the code

Kind regards,
Christian Ehrhardt


Christian Ehrhardt (2):
  swap: allow swap readahead to be merged
  documentation: update how page-cluster affects swap I/O

 Documentation/sysctl/vm.txt |   12 ++++++++++--
 mm/swap_state.c             |    5 +++++
 2 files changed, 15 insertions(+), 2 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
