Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id A179F6B0031
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 00:45:23 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id q10so656900pdj.25
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 21:45:23 -0800 (PST)
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com. [122.248.162.1])
        by mx.google.com with ESMTPS id xh9si1680140pab.325.2013.12.18.21.45.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 21:45:22 -0800 (PST)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 19 Dec 2013 11:15:15 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 82321E0059
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 11:17:38 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBJ5j5qX196976
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 11:15:05 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBJ5jAt7026130
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 11:15:11 +0530
Date: Thu, 19 Dec 2013 13:45:09 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] mm/rmap: fix BUG at rmap_walk
Message-ID: <52b287f2.29a0420a.2738.5775SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1387424720-22826-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <CAA_GA1dA0Yohqx9=HRUJWWcbwp==n3uY5auuB-LRMHWtKJ3QBQ@mail.gmail.com>
 <20131219042902.GA27512@hacker.(null)>
 <52B27D48.9030703@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52B27D48.9030703@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Bob Liu <lliubbo@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Wed, Dec 18, 2013 at 11:59:52PM -0500, Sasha Levin wrote:
>On 12/18/2013 11:29 PM, Wanpeng Li wrote:
>>>PageLocked is not required by page_referenced_anon() and there is not
>>>>any assertion before, commit 37f093cdf introduced this extra BUG_ON()
>>There are two callsites shrink_active_list and page_check_references()
>>of page_referenced(). shrink_active_list and its callee won't lock anonymous
>>page, however, page_check_references() is called with anonymous page
>>lock held in shrink_page_list. So page_check_references case need
>>specail handling.
>
>This explanation seems to be based on current observed behaviour.
>
>I think it would be easier if you could point out the actual code in each
>function that requires a page to be locked, once we have that we don't have
>to care about what the callers currently do.
>

rmap_walk_anon() itself don't need to hold page lock. I remove it in v3.

Regards,
Wanpeng Li 

>
>Thanks,
>Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
