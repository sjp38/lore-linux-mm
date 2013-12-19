Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id EB2456B0031
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 01:14:38 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id un15so710225pbc.13
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 22:14:38 -0800 (PST)
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com. [202.81.31.146])
        by mx.google.com with ESMTPS id eb3si1790146pbc.26.2013.12.18.22.14.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 22:14:37 -0800 (PST)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 19 Dec 2013 16:14:31 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 3B77D2BB0053
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 17:14:28 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBJ5u6Ev53936270
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 16:56:06 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBJ6ERcN015026
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 17:14:27 +1100
Date: Thu, 19 Dec 2013 14:14:25 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v3] mm/rmap: fix BUG at rmap_walk
Message-ID: <52b28ecd.23b6440a.2262.603bSMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1387431715-6786-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20131219055510.GA27532@lge.com>
 <20131219060703.GA27787@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131219060703.GA27787@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 19, 2013 at 03:07:03PM +0900, Joonsoo Kim wrote:
>On Thu, Dec 19, 2013 at 02:55:10PM +0900, Joonsoo Kim wrote:
>> On Thu, Dec 19, 2013 at 01:41:55PM +0800, Wanpeng Li wrote:
>> > This bug is introduced by commit 37f093cdf(mm/rmap: use rmap_walk() in 
>> > page_referenced()). page_get_anon_vma() called in page_referenced_anon() 
>> > will lock and increase the refcount of anon_vma. PageLocked is not required 
>> > by page_referenced_anon() and there is not any assertion before, commit 
>> > 37f093cdf introduced this extra BUG_ON() checking for anon page by mistake.
>> > This patch fix it by remove rmap_walk()'s VM_BUG_ON() and comment reason why 
>> > the page must be locked for rmap_walk_ksm() and rmap_walk_file().
>
>FYI.
>
>See following link to get more information.
>
>https://lkml.org/lkml/2004/7/12/241
>

Interesting, thanks. ;-)

Regards,
Wanpeng Li 

>Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
