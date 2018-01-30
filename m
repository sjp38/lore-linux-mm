Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C25A86B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 12:52:16 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id r28so8377050pgu.1
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 09:52:16 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id m6si2404304pff.273.2018.01.30.09.52.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 30 Jan 2018 09:52:15 -0800 (PST)
Subject: Re: [PATCH v2] mm/swap.c: make functions and their kernel-doc agree
References: <3b42ee3e-04a9-a6ca-6be4-f00752a114fe@infradead.org>
 <20180130123400.GD26445@dhcp22.suse.cz>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <958aa51a-e497-795f-1482-2e6b18143209@infradead.org>
Date: Tue, 30 Jan 2018 09:52:10 -0800
MIME-Version: 1.0
In-Reply-To: <20180130123400.GD26445@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>

On 01/30/2018 04:34 AM, Michal Hocko wrote:
> On Mon 29-01-18 16:43:55, Randy Dunlap wrote:
>> From: Randy Dunlap <rdunlap@infradead.org>
>>
>> Fix some basic kernel-doc notation in mm/swap.c:
>> - for function lru_cache_add_anon(), make its kernel-doc function name
>>   match its function name and change colon to hyphen following the
>>   function name
> 
> This is pretty much an internal function to the MM. It shouldn't have
> any external callers. Why do we need a kernel doc at all?
> 
>> - for function pagevec_lookup_entries(), change the function parameter
>>   name from nr_pages to nr_entries since that is more descriptive of
>>   what the parameter actually is and then it matches the kernel-doc
>>   comments also
> 
> I know what is nr_pages because I do expect pages to be returned. What
> are entries? Can it be something different from pages?

OK, never mind.  I'll revisit this some other day.

later,
-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
