Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DBC316B004D
	for <linux-mm@kvack.org>; Thu, 20 Aug 2009 15:09:51 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp07.in.ibm.com (8.14.3/8.13.1) with ESMTP id n7KJ9i7b010811
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 00:39:44 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7KJ9iqZ2359348
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 00:39:44 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n7KJ9h7U010467
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 00:39:44 +0530
Date: Fri, 21 Aug 2009 00:39:42 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Scalability fixes -- 2.6.31 candidate?
Message-ID: <20090820190941.GA29572@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, prarit@redhat.com, andi.kleen@intel.com, KOSAKI Motohiro <m-kosaki@ceres.dti.ne.jp>, Daisuke Miyakawa <dmiyakawa@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Hi, Andrew,

I've been wondering if the scalability fixes for root overhead in
memory cgroup is a candidate for 2.6.31? They don't change
functionality but help immensely using existing accounting features.

Opening up the email for more debate and discussion and thoughts.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
