Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 1915F6B0254
	for <linux-mm@kvack.org>; Sun, 15 Nov 2015 21:38:28 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so158802585pac.3
        for <linux-mm@kvack.org>; Sun, 15 Nov 2015 18:38:27 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id t13si46828157pas.21.2015.11.15.18.38.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Nov 2015 18:38:27 -0800 (PST)
Received: by pacej9 with SMTP id ej9so52157148pac.2
        for <linux-mm@kvack.org>; Sun, 15 Nov 2015 18:38:27 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.0 \(3094\))
Subject: Re: [PATCH] mm: change mm_vmscan_lru_shrink_inactive() proto types
From: yalin wang <yalin.wang2010@gmail.com>
In-Reply-To: <5645E2A4.3010509@suse.cz>
Date: Mon, 16 Nov 2015 10:38:15 +0800
Content-Transfer-Encoding: 7bit
Message-Id: <7D7FB876-8D07-4CC8-9E9B-1FC791E59482@gmail.com>
References: <1447314896-24849-1-git-send-email-yalin.wang2010@gmail.com> <5645E2A4.3010509@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, namhyung@kernel.org, acme@redhat.com, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, vdavydov@parallels.com, mgorman@techsingularity.net, bywxiaobai@163.com, Tejun Heo <tj@kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org


> On Nov 13, 2015, at 21:16, Vlastimil Babka <vbabka@suse.cz> wrote:
> 
> zone_to_nid
make sense,
i will send V2 patch ,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
