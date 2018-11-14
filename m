Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id EF11D6B0006
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 02:10:56 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id h25-v6so7789049eds.21
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 23:10:56 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b5-v6si9190382edd.21.2018.11.13.23.10.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Nov 2018 23:10:55 -0800 (PST)
Date: Wed, 14 Nov 2018 08:10:52 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: UBSAN: Undefined behaviour in mm/page_alloc.c
Message-ID: <20181114071052.GA23419@dhcp22.suse.cz>
References: <CAEAjamseRRHu+TaTkd1TwpLNm8mtDGP=2K0WKLF0wH-3iLcW_w@mail.gmail.com>
 <20181109084353.GA5321@dhcp22.suse.cz>
 <20181113094305.GM15120@dhcp22.suse.cz>
 <20181113152941.cc328e48d5c0c2f366f5db83@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181113152941.cc328e48d5c0c2f366f5db83@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kyungtae Kim <kt0755@gmail.com>, pavel.tatashin@microsoft.com, vbabka@suse.cz, osalvador@suse.de, rppt@linux.vnet.ibm.com, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, alexander.h.duyck@linux.intel.com, mgorman@techsingularity.net, lifeasageek@gmail.com, threeearcat@gmail.com, syzkaller@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

On Tue 13-11-18 15:29:41, Andrew Morton wrote:
[...]
> But do we really need to do this?  Are there any other known potential
> callsites?

The main point is that the code as it stands is quite fragile, isn't it?
Fixing up all the callers is possible but can you actually think of a
reason why this would cause any measurable effect in the fast path?
The order argument is usually in a register and comparing it to a number
with unlikely branch should be hardly something visible.

Besides that we are talking few cycles at best compared to a fragile
code that got broken by accident without anybody noticing for quite some
time.

I vote for the maintainability over few cycles here. Should anybody find
this measurable we can rework the code by other means.

-- 
Michal Hocko
SUSE Labs
