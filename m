Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id m1Q3aF1Z004721
	for <linux-mm@kvack.org>; Tue, 26 Feb 2008 09:06:15 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1Q3aFFx991318
	for <linux-mm@kvack.org>; Tue, 26 Feb 2008 09:06:15 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id m1Q3aFRB010125
	for <linux-mm@kvack.org>; Tue, 26 Feb 2008 03:36:15 GMT
Message-ID: <47C387EC.4070900@linux.vnet.ibm.com>
Date: Tue, 26 Feb 2008 09:00:52 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] Memory Resource Controller use strstrip while parsing
 arguments
References: <20080225182746.9512.21582.sendpatchset@localhost.localdomain> <20080225105606.bcab215e.akpm@linux-foundation.org>
In-Reply-To: <20080225105606.bcab215e.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Mon, 25 Feb 2008 23:57:46 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> The memory controller has a requirement that while writing values, we need
>> to use echo -n. This patch fixes the problem and makes the UI more consistent.
> 
> that's a decent improvement ;)
> 
> btw, could I ask that you, Paul and others who work on this and cgroups
> have a think about a ./MAINTAINERS update?

Aah.. yes.. we should do that.



-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
