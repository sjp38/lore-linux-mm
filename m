Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 6F11E6B0083
	for <linux-mm@kvack.org>; Tue, 26 May 2009 09:36:22 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e37.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4QDaFG3015274
	for <linux-mm@kvack.org>; Tue, 26 May 2009 07:36:15 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4QDaqgD207002
	for <linux-mm@kvack.org>; Tue, 26 May 2009 07:36:52 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4QDap22017241
	for <linux-mm@kvack.org>; Tue, 26 May 2009 07:36:52 -0600
Date: Tue, 26 May 2009 21:30:50 +0800
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] Fix build warning and avoid checking for mem != null
	twice
Message-ID: <20090526133050.GS4858@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <200905261844.33864.knikanth@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <200905261844.33864.knikanth@suse.de>
Sender: owner-linux-mm@kvack.org
To: Nikanth Karthikesan <knikanth@suse.de>
Cc: Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Nikanth Karthikesan <knikanth@suse.de> [2009-05-26 18:44:32]:

> Fix build warning, "mem_cgroup_is_obsolete defined but not used" when
> CONFIG_DEBUG_VM is not set. Also avoid checking for !mem twice.
> 
> Signed-off-by: Nikanth Karthikesan <knikanth@suse.de>

I thought we fixed this, could you check the latest mmotm please!
-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
