Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0756A28025F
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 03:54:37 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 107so14111740wra.7
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 00:54:36 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i3si827070edc.271.2017.11.16.00.54.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Nov 2017 00:54:35 -0800 (PST)
Date: Thu, 16 Nov 2017 09:54:33 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, meminit: Serially initialise deferred memory if
 trace_buf_size is specified
Message-ID: <20171116085433.qmz4w3y3ra42j2ih@dhcp22.suse.cz>
References: <20171115085556.fla7upm3nkydlflp@techsingularity.net>
 <20171115115559.rjb5hy6d6332jgjj@dhcp22.suse.cz>
 <20171115141329.ieoqvyoavmv6gnea@techsingularity.net>
 <20171115142816.zxdgkad3ch2bih6d@dhcp22.suse.cz>
 <20171115144314.xwdi2sbcn6m6lqdo@techsingularity.net>
 <20171115145716.w34jaez5ljb3fssn@dhcp22.suse.cz>
 <06a33f82-7f83-7721-50ec-87bf1370c3d4@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <06a33f82-7f83-7721-50ec-87bf1370c3d4@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, koki.sanagi@us.fujitsu.com

On Wed 15-11-17 14:17:52, YASUAKI ISHIMATSU wrote:
> Hi Michal and Mel,
> 
> To reproduce the issue, I specified the large trace buffer. The issue also occurs with
> trace_buf_size=12M and movable_node on 4.14.0.

This is still 10x more than the default. Why do you need it in the first
place? You can of course find a size that will not fit into the initial
memory but I am questioning why do you want something like that during
early boot in the first place.

The whole deferred struct page allocation operates under assumption
that there are no large page allocator consumers that early during
the boot process. If this assumption is not correct then we probably
need a generic way to describe this. Add-hoc trace specific thing is
far from idea, imho. If anything the first approach to disable the
deferred initialization via kernel command line option sounds much more
appropriate and simpler to me.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
