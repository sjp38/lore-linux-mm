Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 68AFB6B03A3
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 08:15:35 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id b1so376406742pgc.5
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 05:15:35 -0800 (PST)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id p85si26635852pfj.243.2016.12.21.05.15.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Dec 2016 05:15:34 -0800 (PST)
Received: by mail-pf0-x241.google.com with SMTP id c4so10933528pfb.3
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 05:15:34 -0800 (PST)
Date: Wed, 21 Dec 2016 13:15:31 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH V2 1/2] mm/memblock.c: trivial code refine in
 memblock_is_region_memory()
Message-ID: <20161221131531.GC23096@vultr.guest>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <1482072470-26151-1-git-send-email-richard.weiyang@gmail.com>
 <1482072470-26151-2-git-send-email-richard.weiyang@gmail.com>
 <20161219151514.GB5175@dhcp22.suse.cz>
 <20161220163540.GA13224@vultr.guest>
 <20161221074809.GD16502@dhcp22.suse.cz>
 <20161221124320.GA23096@vultr.guest>
 <20161221124816.GJ31118@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161221124816.GJ31118@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, trivial@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Dec 21, 2016 at 01:48:17PM +0100, Michal Hocko wrote:
>On Wed 21-12-16 12:43:20, Wei Yang wrote:
>> On Wed, Dec 21, 2016 at 08:48:09AM +0100, Michal Hocko wrote:
>> >On Tue 20-12-16 16:35:40, Wei Yang wrote:
>> >> On Mon, Dec 19, 2016 at 04:15:14PM +0100, Michal Hocko wrote:
>> >> >On Sun 18-12-16 14:47:49, Wei Yang wrote:
>> >> >> The base address is already guaranteed to be in the region by
>> >> >> memblock_search().
>> >> >
>> >> 
>> >> Hi, Michal
>> >> 
>> >> Nice to receive your comment.
>> >> 
>> >> >First of all the way how the check is removed is the worst possible...
>> >> >Apart from that it is really not clear to me why checking the base
>> >> >is not needed. You are mentioning memblock_search but what about other
>> >> >callers? adjust_range_page_size_mask e.g...
>> >> >
>> >> 
>> >> Hmm... the memblock_search() is called by memblock_is_region_memory(). Maybe I
>> >> paste the whole function here would clarify the change.
>> >> 
>> >> int __init_memblock memblock_is_region_memory(phys_addr_t base, phys_addr_t size)
>> >> {
>> >> 	int idx = memblock_search(&memblock.memory, base);
>> >> 	phys_addr_t end = base + memblock_cap_size(base, &size);
>> >> 
>> >> 	if (idx == -1)
>> >> 		return 0;
>> >> 	return memblock.memory.regions[idx].base <= base &&
>> >> 		(memblock.memory.regions[idx].base +
>> >> 		 memblock.memory.regions[idx].size) >= end;
>> >> }
>> >
>> >Ohh, my bad. I thought that memblock_search is calling
>> >memblock_is_region_memory. I didn't notice this is other way around.
>> >Then I agree that the check for the base is not needed and can be
>> >removed.
>> 
>> Thanks~ 
>> 
>> I would feel honored if you would like to add Acked-by :-)
>
>My Nack to the original patch still holds. If you want to remove the
>check then remove it rather than comment it out.

Got it, will send a new version.

>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
