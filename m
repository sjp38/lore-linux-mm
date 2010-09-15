Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id F10646B004A
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 10:09:28 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e35.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8FDxQ8a002509
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 07:59:26 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8FE9Frb163068
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 08:09:15 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8FE9ENu002513
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 08:09:14 -0600
Date: Wed, 15 Sep 2010 19:39:11 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] After swapout/swapin private dirty mappings are
 reported clean in smaps
Message-ID: <20100915140911.GC4383@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100915134724.C9EE.A69D9226@jp.fujitsu.com>
 <201009151034.22497.knikanth@suse.de>
 <20100915141710.C9F7.A69D9226@jp.fujitsu.com>
 <201009151201.11359.knikanth@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <201009151201.11359.knikanth@suse.de>
Sender: owner-linux-mm@kvack.org
To: Nikanth Karthikesan <knikanth@suse.de>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Richard Guenther <rguenther@suse.de>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michael Matz <matz@novell.com>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Nikanth Karthikesan <knikanth@suse.de> [2010-09-15 12:01:11]:

> How? Current smaps information without this patch provides incorrect 
> information. Just because a private dirty page became part of swap cache, it 
> shown as clean and backed by a file. If it is shown as clean and backed by 
> swap then it is fine.
>

How is GDB using this information?  

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
