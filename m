Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id C21316B0031
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 00:20:42 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id z10so23908654pdj.30
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 21:20:42 -0800 (PST)
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com. [202.81.31.140])
        by mx.google.com with ESMTPS id gn4si56709934pbc.321.2013.12.04.21.20.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 04 Dec 2013 21:20:41 -0800 (PST)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <benh@au1.ibm.com>;
	Thu, 5 Dec 2013 15:20:38 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 37A8E2CE8051
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 16:20:36 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rB55KNe95898606
	for <linux-mm@kvack.org>; Thu, 5 Dec 2013 16:20:23 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rB55KZFh011197
	for <linux-mm@kvack.org>; Thu, 5 Dec 2013 16:20:35 +1100
Message-ID: <1386220835.21910.21.camel@pasglop>
Subject: Re: [PATCH -V2 3/5] mm: Move change_prot_numa outside
 CONFIG_ARCH_USES_NUMA_PROT_NONE
From: Benjamin Herrenschmidt <benh@au1.ibm.com>
Date: Thu, 05 Dec 2013 16:20:35 +1100
In-Reply-To: <87a9gfri3u.fsf@linux.vnet.ibm.com>
References: 
	<1384766893-10189-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <1384766893-10189-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <1386126782.16703.137.camel@pasglop> <87a9gfri3u.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Thu, 2013-12-05 at 10:48 +0530, Aneesh Kumar K.V wrote:
> 
> Ok, I can move the changes below #ifdef CONFIG_NUMA_BALANCING ? We call
> change_prot_numa from task_numa_work and queue_pages_range(). The later
> may be an issue. So doing the below will help ?
> 
> -#ifdef CONFIG_ARCH_USES_NUMA_PROT_NONE
> +#ifdef CONFIG_NUMA_BALANCING

I will defer to Mel and Rik (should we also CC Andrea ?)

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
