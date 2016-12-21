Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 561566B037B
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 02:48:12 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id o3so57910970wjo.1
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 23:48:12 -0800 (PST)
Received: from mail-wj0-f196.google.com (mail-wj0-f196.google.com. [209.85.210.196])
        by mx.google.com with ESMTPS id u200si22744085wmd.19.2016.12.20.23.48.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 23:48:11 -0800 (PST)
Received: by mail-wj0-f196.google.com with SMTP id o3so1573353wjo.2
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 23:48:11 -0800 (PST)
Date: Wed, 21 Dec 2016 08:48:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V2 1/2] mm/memblock.c: trivial code refine in
 memblock_is_region_memory()
Message-ID: <20161221074809.GD16502@dhcp22.suse.cz>
References: <1482072470-26151-1-git-send-email-richard.weiyang@gmail.com>
 <1482072470-26151-2-git-send-email-richard.weiyang@gmail.com>
 <20161219151514.GB5175@dhcp22.suse.cz>
 <20161220163540.GA13224@vultr.guest>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161220163540.GA13224@vultr.guest>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: trivial@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 20-12-16 16:35:40, Wei Yang wrote:
> On Mon, Dec 19, 2016 at 04:15:14PM +0100, Michal Hocko wrote:
> >On Sun 18-12-16 14:47:49, Wei Yang wrote:
> >> The base address is already guaranteed to be in the region by
> >> memblock_search().
> >
> 
> Hi, Michal
> 
> Nice to receive your comment.
> 
> >First of all the way how the check is removed is the worst possible...
> >Apart from that it is really not clear to me why checking the base
> >is not needed. You are mentioning memblock_search but what about other
> >callers? adjust_range_page_size_mask e.g...
> >
> 
> Hmm... the memblock_search() is called by memblock_is_region_memory(). Maybe I
> paste the whole function here would clarify the change.
> 
> int __init_memblock memblock_is_region_memory(phys_addr_t base, phys_addr_t size)
> {
> 	int idx = memblock_search(&memblock.memory, base);
> 	phys_addr_t end = base + memblock_cap_size(base, &size);
> 
> 	if (idx == -1)
> 		return 0;
> 	return memblock.memory.regions[idx].base <= base &&
> 		(memblock.memory.regions[idx].base +
> 		 memblock.memory.regions[idx].size) >= end;
> }

Ohh, my bad. I thought that memblock_search is calling
memblock_is_region_memory. I didn't notice this is other way around.
Then I agree that the check for the base is not needed and can be
removed.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
