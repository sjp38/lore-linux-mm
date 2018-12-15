Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2A9FB8E021D
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 19:26:17 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c3so3574285eda.3
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 16:26:17 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l52sor4248401edc.17.2018.12.14.16.26.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 14 Dec 2018 16:26:15 -0800 (PST)
Date: Sat, 15 Dec 2018 00:26:13 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH v2 1/1] mm, memory_hotplug: Initialize struct pages for
 the full memory section
Message-ID: <20181215002613.gj3s62uuxad6n4rb@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181212172712.34019-1-zaslonko@linux.ibm.com>
 <20181212172712.34019-2-zaslonko@linux.ibm.com>
 <20181213034615.4ntpo4cl2oo5mcx4@master>
 <e4cebbae-3fcb-f03c-3d0e-a1a44ff0675a@linux.bm.com>
 <20181213151209.hmrhrr5gvb256bzm@master>
 <674c53e2-e4b3-f21f-4613-b149acef7e53@linux.bm.com>
 <20181214101651.GE5624@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181214101651.GE5624@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Zaslonko Mikhail <zaslonko@linux.ibm.com>, Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pavel.Tatashin@microsoft.com, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, gerald.schaefer@de.ibm.com

On Fri, Dec 14, 2018 at 11:19:59AM +0100, Michal Hocko wrote:
>[Your From address seems to have a typo (linux.bm.com) - fixed]
>
>On Fri 14-12-18 10:33:55, Zaslonko Mikhail wrote:
>[...]
>> Yes, it might still trigger PF_POISONED_CHECK if the first page 
>> of the pageblock is left uninitialized (poisoned).
>> But in order to cover these exceptional cases we would need to 
>> adjust memory_hotplug sysfs handler functions with similar 
>> checks (as in the for loop of memmap_init_zone()). And I guess 
>> that is what we were trying to avoid (adding special cases to 
>> memory_hotplug paths).
>
>is_mem_section_removable should test pfn_valid_within at least.
>But that would require some care because next_active_pageblock expects
>aligned pages. Ble, this code is just horrible. I would just remove it
>altogether. I strongly suspect that nobody is using it for anything
>reasonable anyway. The only reliable way to check whether a block is
>removable is to remove it. Everything else is just racy.
>

Sounds reasonable.

The result return from removable sysfs is transient. If no user rely on
this, remove this is a better way.

>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
