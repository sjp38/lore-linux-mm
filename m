Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id F04116B0031
	for <linux-mm@kvack.org>; Fri, 13 Sep 2013 17:12:38 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id g10so1724662pdj.30
        for <linux-mm@kvack.org>; Fri, 13 Sep 2013 14:12:38 -0700 (PDT)
Date: Fri, 13 Sep 2013 14:12:36 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm/shmem.c: check the return value of mpol_to_str()
In-Reply-To: <523124B7.8070408@gmail.com>
Message-ID: <alpine.DEB.2.02.1309131410290.31480@chino.kir.corp.google.com>
References: <5215639D.1080202@asianux.com> <5227CF48.5080700@asianux.com> <alpine.DEB.2.02.1309091326210.16291@chino.kir.corp.google.com> <522E6C14.7060006@asianux.com> <alpine.DEB.2.02.1309092334570.20625@chino.kir.corp.google.com> <522EC3D1.4010806@asianux.com>
 <alpine.DEB.2.02.1309111725290.22242@chino.kir.corp.google.com> <523124B7.8070408@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Chen Gang <gang.chen@asianux.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, riel@redhat.com, hughd@google.com, xemul@parallels.com, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, 11 Sep 2013, KOSAKI Motohiro wrote:

> At least, currently mpol_to_str() already have following assertion. I mean,
> the code assume every developer know maximum length of mempolicy. I have no
> seen any reason to bring addional complication to shmem area.
> 
> 
> 	/*
> 	 * Sanity check:  room for longest mode, flag and some nodes
> 	 */
> 	VM_BUG_ON(maxlen < strlen("interleave") + strlen("relative") + 16);
> 

No need to make it a runtime error, the value passed as maxlen is a 
constant, as is the use of sizeof(buffer), so the value is known at 
compile-time.  You can make this a BUILD_BUG_ON() if you are creative.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
