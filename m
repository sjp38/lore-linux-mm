Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id A23096B0062
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 22:52:21 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Wed, 20 Jun 2012 08:22:18 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5K2puLI13566228
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 08:21:57 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5K8LhM5030361
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 18:21:43 +1000
Message-ID: <4FE13ACA.7090301@linux.vnet.ibm.com>
Date: Wed, 20 Jun 2012 10:51:54 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/10] zcache: fix preemptable memory allocation in atomic
 context
References: <4FE0392E.3090300@linux.vnet.ibm.com> <4FE08C1A.2020308@linux.vnet.ibm.com>
In-Reply-To: <4FE08C1A.2020308@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 06/19/2012 10:26 PM, Seth Jennings wrote:


> Did you get a might_sleep warning on this?  I haven't seen this being an
> issue.
> 


No, i did not, i get it just from code review.

> GFP_ATOMIC only modifies the existing mask to allow allocation use the
> emergency pool.  It is __GFP_WAIT not being set that prevents sleep.  We
> don't want to use the emergency pool since we make large, long lived
> allocations with this mask.
> 


Ah, yes, i thought only GFP_ATOMIC can prevent sleep, thank you very much
for pointing it out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
