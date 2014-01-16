Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id F15726B006E
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 12:41:27 -0500 (EST)
Received: by mail-ee0-f42.google.com with SMTP id e49so1687879eek.1
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 09:41:27 -0800 (PST)
Received: from e06smtp16.uk.ibm.com (e06smtp16.uk.ibm.com. [195.75.94.112])
        by mx.google.com with ESMTPS id p46si16133634eem.63.2014.01.16.09.41.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 16 Jan 2014 09:41:27 -0800 (PST)
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <phacht@linux.vnet.ibm.com>;
	Thu, 16 Jan 2014 17:41:26 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id A3921219005C
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 17:41:22 +0000 (GMT)
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0GHfBru3211636
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 17:41:11 GMT
Received: from d06av09.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0GHfNWj028902
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 10:41:23 -0700
Date: Thu, 16 Jan 2014 18:41:21 +0100
From: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/nobootmem: Fix unused variable
Message-ID: <20140116184121.34d1e97c@lilie>
In-Reply-To: <CAPp3RGpt+qjFYrA928hBjseJNo4v0RKVnb-BjFJzH0uaVGcX+g@mail.gmail.com>
References: <1389879186-43649-1-git-send-email-phacht@linux.vnet.ibm.com>
	<CAPp3RGpWhx4uoTTiSkUe9rZ2iJjMW6O2u=xdWL7BSskse=61qw@mail.gmail.com>
	<20140116164936.1c6c3274@lilie>
	<CAPp3RGpt+qjFYrA928hBjseJNo4v0RKVnb-BjFJzH0uaVGcX+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Holt <robinmholt@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, liuj97@gmail.com, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, iamjoonsoo.kim@lge.com, robin.m.holt@gmail.com, yinghai@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


> I would think you would be better off making
> get_allocated_memblock_reserved_regions_info() and
> get_allocated_memblock_memory_regions_info be static inline functions
> when #ifdef CONFIG_ARCH_DISCARD_MEMBLOCK.
Possible, of course.
But the size variable has still to be #ifdef'd. And that's what the
patch is about. It's just an addition to another patch. 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
