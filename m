Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D1D078D0001
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 01:17:12 -0400 (EDT)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id oA355sUU015766
	for <linux-mm@kvack.org>; Tue, 2 Nov 2010 23:05:54 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oA35GuGJ150440
	for <linux-mm@kvack.org>; Tue, 2 Nov 2010 23:16:58 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oA35GtRX013797
	for <linux-mm@kvack.org>; Tue, 2 Nov 2010 23:16:55 -0600
Date: Wed, 3 Nov 2010 10:46:47 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [BUGFIX][PATCH] fix wrong VM_BUG_ON() in try_charge()'s
 mm->owner check
Message-ID: <20101103051647.GK3769@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <AANLkTikCUdpx-jGhKdzueML39CnExumk1i_X_OZJihE2@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <AANLkTikCUdpx-jGhKdzueML39CnExumk1i_X_OZJihE2@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, hughd@gmail.com
List-ID: <linux-mm.kvack.org>

* Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com> [2010-11-03 00:10:50]:

> I'm sorry for attached file, I have to use unusual mailer this time.
> This is a fix for wrong VM_BUG_ON() for mm/memcontol.c
>

Yes, that seems reasonable. If we race with try_to_unuse() and
the mm has no new owner we set mm->owner to NULL, in those cases it
makes no sense to charge.


Reviewed-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
