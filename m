Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 80B4C6B0005
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 21:02:59 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id k13so5834074pff.23
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 18:02:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h13-v6sor3285848pln.137.2018.03.29.18.02.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 29 Mar 2018 18:02:55 -0700 (PDT)
Date: Fri, 30 Mar 2018 09:02:43 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm/page_alloc: call set_pageblock_order() once for each
 node
Message-ID: <20180330010243.GA14446@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20180329033607.8440-1-richard.weiyang@gmail.com>
 <20180329121109.xg5tfk6dyqzkrgrh@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180329121109.xg5tfk6dyqzkrgrh@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org

On Thu, Mar 29, 2018 at 01:11:09PM +0100, Mel Gorman wrote:
>On Thu, Mar 29, 2018 at 11:36:07AM +0800, Wei Yang wrote:
>> set_pageblock_order() is a standalone function which sets pageblock_order,
>> while current implementation calls this function on each ZONE of each node
>> in free_area_init_core().
>> 
>> Since free_area_init_node() is the only user of free_area_init_core(),
>> this patch moves set_pageblock_order() up one level to invoke
>> set_pageblock_order() only once on each node.
>> 
>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>
>The patch looks ok but given that set_pageblock_order returns immediately
>if it has already been called, I expect the benefit is marginal. Was any
>improvement in boot time measured?

No, I don't expect measurable improvement from this since the number of nodes
and zones are limited.

This is just a code refine from logic point of view.

>
>-- 
>Mel Gorman
>SUSE Labs

-- 
Wei Yang
Help you, Help me
