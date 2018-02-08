Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id BA8506B0003
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 08:33:56 -0500 (EST)
Received: by mail-vk0-f71.google.com with SMTP id o202so2283494vkd.23
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 05:33:56 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id f1si838503uae.366.2018.02.08.05.33.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Feb 2018 05:33:55 -0800 (PST)
Subject: Re: [LSF/MM TOPIC] lru_lock scalability
References: <2a16be43-0757-d342-abfb-d4d043922da9@oracle.com>
 <20180201094431.GA20742@bombadil.infradead.org>
 <af831ebd-6acf-1f83-c531-39895ab2eddb@oracle.com>
 <20180202170003.GA16840@bombadil.infradead.org>
 <20180206153359.GA31089@bombadil.infradead.org>
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Message-ID: <d33748d8-6bba-638d-46b6-5c074821d516@oracle.com>
Date: Thu, 8 Feb 2018 08:33:56 -0500
MIME-Version: 1.0
In-Reply-To: <20180206153359.GA31089@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, steven.sistare@oracle.com, pasha.tatashin@oracle.com, yossi.lev@oracle.com, Dave.Dice@oracle.com, akpm@linux-foundation.org, mhocko@kernel.org, ldufour@linux.vnet.ibm.com, dave@stgolabs.net, khandual@linux.vnet.ibm.com, ak@linux.intel.com, mgorman@suse.de, Peter Zijlstra <peterz@infradead.org>

On 02/06/2018 10:33 AM, Matthew Wilcox wrote:
> static inline void xas_maybe_lock_irq(struct xa_state *xas, void *entry)
> {
> 	if (entry) {
> 		rcu_read_lock();
> 		xas_start(&xas);
> 		if (!xas_bounds(&xas))
> 			return;
> 	}

Trying to understand what's going on here.

xas_bounds isn't in your latest two XArray branches (xarray-4.16 or 
xarray-2018-01-09).  Isn't it checking whether 'entry' falls inside the 
currently allocated range of the XArray?  So that it should tell us 
whether a new xa_node needs to be allocated for 'entry'?

If that's true, I guess it should take 'entry' as well as '&xas'.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
