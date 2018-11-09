Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 440276B06CC
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 05:08:07 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id g21-v6so1106905pfg.18
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 02:08:07 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id z70-v6si7511409pfi.165.2018.11.09.02.08.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 02:08:05 -0800 (PST)
Subject: Re: UBSAN: Undefined behaviour in mm/page_alloc.c
References: <CAEAjamseRRHu+TaTkd1TwpLNm8mtDGP=2K0WKLF0wH-3iLcW_w@mail.gmail.com>
 <20181109084353.GA5321@dhcp22.suse.cz>
 <b51aae15-eb5d-47f0-1222-bfc1ef21e06c@I-love.SAKURA.ne.jp>
 <20181109095604.GC5321@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <a74e6a5d-d4c1-9006-60af-de52afafebb2@i-love.sakura.ne.jp>
Date: Fri, 9 Nov 2018 19:07:49 +0900
MIME-Version: 1.0
In-Reply-To: <20181109095604.GC5321@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Kyungtae Kim <kt0755@gmail.com>, akpm@linux-foundation.org, pavel.tatashin@microsoft.com, vbabka@suse.cz, osalvador@suse.de, rppt@linux.vnet.ibm.com, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, alexander.h.duyck@linux.intel.com, mgorman@techsingularity.net, lifeasageek@gmail.com, threeearcat@gmail.com, syzkaller@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

On 2018/11/09 18:56, Michal Hocko wrote:
> Does this following look better?

Yes.

>> Also, why not to add BUG_ON(gfp_mask & __GFP_NOFAIL); here?
> 
> Because we do not want to blow up the kernel just because of a stupid
> usage of the allocator. Can you think of an example where it would
> actually make any sense?
> 
> I would argue that such a theoretical abuse would blow up on an
> unchecked NULL ptr access. Isn't that enough?

We after all can't avoid blowing up the kernel even if we don't add BUG_ON().
Stopping with BUG_ON() is saner than NULL pointer dereference messages.
