Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8B51B6B004F
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 22:35:21 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e8.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n6H2Z9Es025117
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 22:35:09 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n6H2ZLIo249378
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 22:35:21 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n6H2Wkhj023491
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 22:32:46 -0400
Date: Fri, 17 Jul 2009 08:05:19 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [BUGFIX][PATCH] cgroup avoid permanent sleep at rmdir v7
Message-ID: <20090717023519.GG3576@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090703093154.5f6e910a.kamezawa.hiroyu@jp.fujitsu.com> <20090716145534.07511d67.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090716145534.07511d67.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "menage@google.com" <menage@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-07-16 14:55:34]:

> Rebased onto mm-of-the-moment snapshot 2009-07-15-20-57.
> passed fundamental tests.

Andrew could you please pick this up, it is an important bugfix and if
possible needs to go into 2.6.31-rcX. Does anybody object to that or
should we wait till 2.6.32-rc1?

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
