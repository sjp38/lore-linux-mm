Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BC1D66B0158
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 23:21:36 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp07.in.ibm.com (8.14.3/8.13.1) with ESMTP id o2G3LVPa005640
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 08:51:31 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2G3LVLW3121238
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 08:51:31 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2G3LUEb028790
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 08:51:30 +0530
Date: Tue, 16 Mar 2010 08:51:29 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH][RF C/T/D] Unmapped page cache control - via boot
 parameter
Message-ID: <20100316032129.GH18054@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100315072214.GA18054@balbir.in.ibm.com>
 <20100315084631.a350f066.randy.dunlap@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100315084631.a350f066.randy.dunlap@oracle.com>
Sender: owner-linux-mm@kvack.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: KVM development list <kvm@vger.kernel.org>, Rik van Riel <riel@surriel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* Randy Dunlap <randy.dunlap@oracle.com> [2010-03-15 08:46:31]:

> On Mon, 15 Mar 2010 12:52:15 +0530 Balbir Singh wrote:
> 
> Hi,
> If you go ahead with this, please add the boot parameter & its description
> to Documentation/kernel-parameters.txt.
>

I certainly will, thanks for keeping a watch. 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
