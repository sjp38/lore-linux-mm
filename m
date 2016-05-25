Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5FD116B0005
	for <linux-mm@kvack.org>; Tue, 24 May 2016 22:11:24 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id g6so54800070obn.0
        for <linux-mm@kvack.org>; Tue, 24 May 2016 19:11:24 -0700 (PDT)
Received: from mail-io0-x22a.google.com (mail-io0-x22a.google.com. [2607:f8b0:4001:c06::22a])
        by mx.google.com with ESMTPS id 4si20236731itz.98.2016.05.24.19.11.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 May 2016 19:11:23 -0700 (PDT)
Received: by mail-io0-x22a.google.com with SMTP id t40so23898629ioi.0
        for <linux-mm@kvack.org>; Tue, 24 May 2016 19:11:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CADUS3om92UNPrwji7A_M6W-YPM2zjO9j6uPJ=c3vtVwUzrg_WA@mail.gmail.com>
References: <CADUS3okXhU5mW5Y2BC88zq2GtaVyK1i+i2uT34zHbWPw3hFPTA@mail.gmail.com>
	<20160523144711.GV2278@dhcp22.suse.cz>
	<CADUS3onEpdMF6Pi9-cHkf+hA6bqOc4mkXAci7ikeUhtaELx4WQ@mail.gmail.com>
	<20160523190051.GF32715@dhcp22.suse.cz>
	<CADUS3onbkOC=kSsHxVgwK-m-ftmrzH+73RHDAFw_mbLvPGBx6A@mail.gmail.com>
	<20160524115049.GH8259@dhcp22.suse.cz>
	<CADUS3om92UNPrwji7A_M6W-YPM2zjO9j6uPJ=c3vtVwUzrg_WA@mail.gmail.com>
Date: Wed, 25 May 2016 10:11:23 +0800
Message-ID: <CADUS3okn3a74j-aYKyfPis+NJa4OGvNPsJWW4iyyRu6bfdZB6Q@mail.gmail.com>
Subject: Re: page order 0 allocation fail but free pages are enough
From: yoma sophian <sophian.yoma@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

>> free-free_cma = 636kB so you are way below the watermark and that is
> After tracing the __alloc_pages_slowpath, in the 2nd time we call
> get_page_from_freelist, we will purposely put alloc_flags &
> ~ALLOC_NO_WATERMARKS.
> Doesn't that mean kernel will bypass __zone_watermark_ok?
I apologize for my misunderstanding.
(alloc_flags & ~ALLOC_NO_WATERMARKS) will NOT bypass __zone_watermark_ok.
on the contrary, it will filter out watermarks checking.

there is one thing makes me curious,
why we put  alloc_flags = gfp_to_alloc_flags(gfp_mask) in
__alloc_pages_slowpath  instead of __alloc_pages_nodemask?

Appreciate your kind help,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
