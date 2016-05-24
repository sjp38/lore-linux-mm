Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8D31A6B025F
	for <linux-mm@kvack.org>; Tue, 24 May 2016 11:06:53 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id g83so29742370oib.0
        for <linux-mm@kvack.org>; Tue, 24 May 2016 08:06:53 -0700 (PDT)
Received: from mail-io0-x22d.google.com (mail-io0-x22d.google.com. [2607:f8b0:4001:c06::22d])
        by mx.google.com with ESMTPS id oo7si4838409igb.67.2016.05.24.08.06.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 May 2016 08:06:52 -0700 (PDT)
Received: by mail-io0-x22d.google.com with SMTP id p64so13876356ioi.2
        for <linux-mm@kvack.org>; Tue, 24 May 2016 08:06:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160524115049.GH8259@dhcp22.suse.cz>
References: <CADUS3okXhU5mW5Y2BC88zq2GtaVyK1i+i2uT34zHbWPw3hFPTA@mail.gmail.com>
	<20160523144711.GV2278@dhcp22.suse.cz>
	<CADUS3onEpdMF6Pi9-cHkf+hA6bqOc4mkXAci7ikeUhtaELx4WQ@mail.gmail.com>
	<20160523190051.GF32715@dhcp22.suse.cz>
	<CADUS3onbkOC=kSsHxVgwK-m-ftmrzH+73RHDAFw_mbLvPGBx6A@mail.gmail.com>
	<20160524115049.GH8259@dhcp22.suse.cz>
Date: Tue, 24 May 2016 23:06:52 +0800
Message-ID: <CADUS3om92UNPrwji7A_M6W-YPM2zjO9j6uPJ=c3vtVwUzrg_WA@mail.gmail.com>
Subject: Re: page order 0 allocation fail but free pages are enough
From: yoma sophian <sophian.yoma@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

hi Michal:

>> Normal free:56088kB min:2000kB low:2500kB high:3000kB
>> active_anon:148332kB inactive_anon:6040kB active_file:1356kB
>> inactive_file:5240kB unevictable:0kB isolated(anon):0kB
>> isolated(file):0kB present:329728kB managed:250408kB mlocked:0kB
>> dirty:120kB writeback:0kB mapped:8108kB shmem:6136kB
>> slab_reclaimable:5520kB slab_unreclaimable:26128kB kernel_stack:2720kB
>> pagetables:4424kB unstable:0kB bounce:0kB free_cma:55452kB
>
> free-free_cma = 636kB so you are way below the watermark and that is
After tracing the __alloc_pages_slowpath, in the 2nd time we call
get_page_from_freelist, we will purposely put alloc_flags &
~ALLOC_NO_WATERMARKS.
Doesn't that mean kernel will bypass __zone_watermark_ok?

Sincerely appreciate your kind help ^^

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
