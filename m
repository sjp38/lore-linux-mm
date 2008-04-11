Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id m3B4w1Dg003925
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 10:28:01 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3B4vxmW1192102
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 10:27:59 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m3B4w9Ac016890
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 04:58:09 GMT
Message-ID: <47FEEF6F.2000505@linux.vnet.ibm.com>
Date: Fri, 11 Apr 2008 10:26:15 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm] Add an owner to the mm_struct (v9)
References: <20080410091602.4472.32172.sendpatchset@localhost.localdomain> <20080411123339.89aea319.kamezawa.hiroyu@jp.fujitsu.com> <47FEE89A.1010102@linux.vnet.ibm.com> <20080411134739.1aae8bae.kamezawa.hiroyu@jp.fujitsu.com> <47FEED67.1080006@linux.vnet.ibm.com> <20080411135810.87536503.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080411135810.87536503.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Fri, 11 Apr 2008 10:17:35 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> Good question. It is possible that clone() was called with CLONE_VM without
>> CLONE_THREAD. In which case we have threads sharing the VM without a thread
>> group leader. Please see zap_threads() for a similar search pattern.
>>
> Oh. thank you for kindly explanation.
> 
> I'll test this on 2.6.25-rc8-mm2.
> 

Thanks for the review and help with testing.

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
