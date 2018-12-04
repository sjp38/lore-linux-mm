Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C447A6B6D5E
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 01:54:56 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id s50so7687030edd.11
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 22:54:56 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b9sor8323459eda.20.2018.12.03.22.54.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Dec 2018 22:54:55 -0800 (PST)
Date: Tue, 4 Dec 2018 06:54:53 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm/alloc: fallback to first node if the wanted node
 offline
Message-ID: <20181204065453.4rsyhtsk2aej4vim@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <1543892757-4323-1-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1543892757-4323-1-git-send-email-kernelfans@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

On Tue, Dec 04, 2018 at 11:05:57AM +0800, Pingfan Liu wrote:
>During my test on some AMD machine, with kexec -l nr_cpus=x option, the
>kernel failed to bootup, because some node's data struct can not be allocated,
>e.g, on x86, initialized by init_cpu_to_node()->init_memory_less_node(). But
>device->numa_node info is used as preferred_nid param for

could we fix the preferred_nid before passed to
__alloc_pages_nodemask()?

BTW, I don't catch the function call flow to this point. Would you mind
giving me some hint?

-- 
Wei Yang
Help you, Help me
