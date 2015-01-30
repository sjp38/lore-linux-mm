Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 24B8E6B008A
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 10:29:03 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id l15so3348071wiw.0
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 07:29:02 -0800 (PST)
Received: from mail-we0-x234.google.com (mail-we0-x234.google.com. [2a00:1450:400c:c03::234])
        by mx.google.com with ESMTPS id dx1si7289859wib.72.2015.01.30.07.29.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 Jan 2015 07:29:01 -0800 (PST)
Received: by mail-we0-f180.google.com with SMTP id m14so27777871wev.11
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 07:29:01 -0800 (PST)
Date: Fri, 30 Jan 2015 16:28:59 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] mm: vmscan: fix the page state calculation in
 too_many_isolated
Message-ID: <20150130152859.GI15505@dhcp22.suse.cz>
References: <20150116154922.GB4650@dhcp22.suse.cz>
 <54BA7D3A.40100@codeaurora.org>
 <alpine.DEB.2.11.1501171347290.25464@gentwo.org>
 <54BC879C.90505@codeaurora.org>
 <20150121143920.GD23700@dhcp22.suse.cz>
 <alpine.DEB.2.11.1501221010510.3937@gentwo.org>
 <20150126174606.GD22681@dhcp22.suse.cz>
 <alpine.DEB.2.11.1501261233550.16786@gentwo.org>
 <20150127105242.GC19880@dhcp22.suse.cz>
 <alpine.DEB.2.11.1501271058230.25124@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1501271058230.25124@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, mgorman@suse.de, minchan@kernel.org

On Tue 27-01-15 10:59:59, Christoph Lameter wrote:
> On Tue, 27 Jan 2015, Michal Hocko wrote:
> 
> > I am not following. The idea was to run vmstat_shepherd in a kernel
> > thread and waking up as per defined timeout and then check need_update
> > for each CPU and call smp_call_function_single to refresh the timer
> > rather than building a mask and then calling sm_call_function_many to
> > reduce paralel contention on the shared counters.
> 
> Thats ok.

OK, I will put that on my todo list and try to find some time to
implement it.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
