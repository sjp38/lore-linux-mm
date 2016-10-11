Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 57C146B0038
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 02:53:44 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id p80so7664587lfp.6
        for <linux-mm@kvack.org>; Mon, 10 Oct 2016 23:53:44 -0700 (PDT)
Received: from mail-lf0-f67.google.com (mail-lf0-f67.google.com. [209.85.215.67])
        by mx.google.com with ESMTPS id 77si1030708ljb.23.2016.10.10.23.53.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Oct 2016 23:53:43 -0700 (PDT)
Received: by mail-lf0-f67.google.com with SMTP id b75so1955714lfg.3
        for <linux-mm@kvack.org>; Mon, 10 Oct 2016 23:53:42 -0700 (PDT)
Date: Tue, 11 Oct 2016 08:53:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/4] use up highorder free pages before OOM
Message-ID: <20161011065341.GC31996@dhcp22.suse.cz>
References: <1475819136-24358-1-git-send-email-minchan@kernel.org>
 <20161007091625.GB18447@dhcp22.suse.cz>
 <20161007150425.GD3060@bbox>
 <20161010074724.GC20420@dhcp22.suse.cz>
 <20161011050643.GC30973@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161011050643.GC30973@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>

On Tue 11-10-16 14:06:43, Minchan Kim wrote:
> On Mon, Oct 10, 2016 at 09:47:31AM +0200, Michal Hocko wrote:
[...]
> > that close to OOM usually blows up later or starts trashing very soon.
> > It is true that a particular workload might benefit from ever last
> > allocatable page in the system but it would be better to mention all
> > that in the changelog.
> 
> I don't unerstand what phrase you really want to include the changelog.
> I will add the information which isolate 30M free pages before 4K page
> allocation failure in next version. If you want something to add,
> please say again.

Describe your usecase where the additional 1% of memory can allow a
sustainable workload without OOM. This is not usually the case as I've
tried to explain but it is true that the compression might change the
picture somehow. If your testcase is artificial, try to explain how it
emulates a real workload etc...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
