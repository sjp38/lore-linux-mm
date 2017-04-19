Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 508022806D9
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 03:10:44 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p111so1493827wrc.10
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 00:10:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 73si2846110wmp.148.2017.04.19.00.10.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Apr 2017 00:10:43 -0700 (PDT)
Date: Wed, 19 Apr 2017 09:10:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Re: "mm: move pcp and lru-pcp draining into single wq" broke
 resume from s2ram
Message-ID: <20170419071039.GB28263@dhcp22.suse.cz>
References: <CAMuHMdUJSfrZ=2zy88_zojDek3CHEWKhv_qoJAVgDpPWz8V=Ew@mail.gmail.com>
 <20170418201907.GC20671@dhcp22.suse.cz>
 <201704190541.v3J5fUE3054131@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201704190541.v3J5fUE3054131@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux PM list <linux-pm@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Linux-Renesas <linux-renesas-soc@vger.kernel.org>, Tejun Heo <tj@kernel.org>

On Wed 19-04-17 14:41:30, Tetsuo Handa wrote:
[...]
> Somebody is waiting forever with cpu_hotplug.lock held?

Why would that matter for drain_all_pages? It doesn't use
get_online_cpus since a459eeb7b852 ("mm, page_alloc: do not depend on
cpu hotplug locks inside the allocator") while ce612879ddc7 ("mm: move
pcp and lru-pcp draining into single wq") was merged later.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
