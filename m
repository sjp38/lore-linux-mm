Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0008E6B0282
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 02:47:44 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 76so13664939pfr.3
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 23:47:44 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v10si551458plz.305.2017.11.06.23.47.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Nov 2017 23:47:44 -0800 (PST)
Date: Tue, 7 Nov 2017 08:47:40 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: page_ext: allocate page extension though first PFN
 is invalid
Message-ID: <20171107074740.zjroymvomayapebs@dhcp22.suse.cz>
References: <CGME20171102063347epcas2p2ce3e91597de3bf68e818130ea44ac769@epcas2p2.samsung.com>
 <20171102063507.25671-1-jaewon31.kim@samsung.com>
 <20171102080249.uxxq4ko3cc2wgnbz@dhcp22.suse.cz>
 <CAJrd-UtBcnvZqu77LuRTzc2u8X+qL_kWC5xaYsA-8BHVRLBaBg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJrd-UtBcnvZqu77LuRTzc2u8X+qL_kWC5xaYsA-8BHVRLBaBg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaewon Kim <jaewon31.kim@gmail.com>
Cc: Jaewon Kim <jaewon31.kim@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, vbabka@suse.cz, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 07-11-17 07:30:05, Jaewon Kim wrote:
> I wonder if you want me to split and resend the 2 patches, or if you
> will use this mail thread for the further discussion.

Please resend
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
