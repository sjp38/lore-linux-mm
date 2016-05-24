Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 464B56B0253
	for <linux-mm@kvack.org>; Tue, 24 May 2016 07:50:52 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id m138so8023864lfm.0
        for <linux-mm@kvack.org>; Tue, 24 May 2016 04:50:52 -0700 (PDT)
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com. [74.125.82.54])
        by mx.google.com with ESMTPS id 198si4527456wmj.9.2016.05.24.04.50.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 May 2016 04:50:51 -0700 (PDT)
Received: by mail-wm0-f54.google.com with SMTP id n129so125632809wmn.1
        for <linux-mm@kvack.org>; Tue, 24 May 2016 04:50:50 -0700 (PDT)
Date: Tue, 24 May 2016 13:50:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: page order 0 allocation fail but free pages are enough
Message-ID: <20160524115049.GH8259@dhcp22.suse.cz>
References: <CADUS3okXhU5mW5Y2BC88zq2GtaVyK1i+i2uT34zHbWPw3hFPTA@mail.gmail.com>
 <20160523144711.GV2278@dhcp22.suse.cz>
 <CADUS3onEpdMF6Pi9-cHkf+hA6bqOc4mkXAci7ikeUhtaELx4WQ@mail.gmail.com>
 <20160523190051.GF32715@dhcp22.suse.cz>
 <CADUS3onbkOC=kSsHxVgwK-m-ftmrzH+73RHDAFw_mbLvPGBx6A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADUS3onbkOC=kSsHxVgwK-m-ftmrzH+73RHDAFw_mbLvPGBx6A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yoma sophian <sophian.yoma@gmail.com>
Cc: linux-mm@kvack.org

OK, I could have noticed that earlier...

On Tue 24-05-16 19:40:21, yoma sophian wrote:
[...]
> Normal free:56088kB min:2000kB low:2500kB high:3000kB
> active_anon:148332kB inactive_anon:6040kB active_file:1356kB
> inactive_file:5240kB unevictable:0kB isolated(anon):0kB
> isolated(file):0kB present:329728kB managed:250408kB mlocked:0kB
> dirty:120kB writeback:0kB mapped:8108kB shmem:6136kB
> slab_reclaimable:5520kB slab_unreclaimable:26128kB kernel_stack:2720kB
> pagetables:4424kB unstable:0kB bounce:0kB free_cma:55452kB

free-free_cma = 636kB so you are way below the watermark and that is
why your atomic allocation fails (see __zone_watermark_ok). I am not an
expect on CMA but I guess your CMA pool is too large for your load.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
