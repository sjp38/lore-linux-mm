Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id B0B6B6B006E
	for <linux-mm@kvack.org>; Tue, 27 Jan 2015 12:00:02 -0500 (EST)
Received: by mail-ie0-f171.google.com with SMTP id tr6so16367831ieb.2
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 09:00:02 -0800 (PST)
Received: from resqmta-po-01v.sys.comcast.net (resqmta-po-01v.sys.comcast.net. [2001:558:fe16:19:96:114:154:160])
        by mx.google.com with ESMTPS id r1si1521249icg.88.2015.01.27.09.00.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 27 Jan 2015 09:00:02 -0800 (PST)
Date: Tue, 27 Jan 2015 10:59:59 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2] mm: vmscan: fix the page state calculation in
 too_many_isolated
In-Reply-To: <20150127105242.GC19880@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.11.1501271058230.25124@gentwo.org>
References: <20150114165036.GI4706@dhcp22.suse.cz> <54B7F7C4.2070105@codeaurora.org> <20150116154922.GB4650@dhcp22.suse.cz> <54BA7D3A.40100@codeaurora.org> <alpine.DEB.2.11.1501171347290.25464@gentwo.org> <54BC879C.90505@codeaurora.org>
 <20150121143920.GD23700@dhcp22.suse.cz> <alpine.DEB.2.11.1501221010510.3937@gentwo.org> <20150126174606.GD22681@dhcp22.suse.cz> <alpine.DEB.2.11.1501261233550.16786@gentwo.org> <20150127105242.GC19880@dhcp22.suse.cz>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, mgorman@suse.de, minchan@kernel.org

On Tue, 27 Jan 2015, Michal Hocko wrote:

> I am not following. The idea was to run vmstat_shepherd in a kernel
> thread and waking up as per defined timeout and then check need_update
> for each CPU and call smp_call_function_single to refresh the timer
> rather than building a mask and then calling sm_call_function_many to
> reduce paralel contention on the shared counters.

Thats ok.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
