Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C2DC66B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 05:12:50 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id r144so32447393wme.0
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 02:12:50 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y70si15346648wmh.162.2017.01.17.02.12.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Jan 2017 02:12:49 -0800 (PST)
Date: Tue, 17 Jan 2017 11:12:47 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: + mm-vmscan-add-mm_vmscan_inactive_list_is_low-tracepoint.patch
 added to -mm tree
Message-ID: <20170117101247.GF19699@dhcp22.suse.cz>
References: <20170111155239.GD16365@dhcp22.suse.cz>
 <20170112051247.GA8387@bbox>
 <20170112081554.GB2264@dhcp22.suse.cz>
 <20170112084813.GA24030@bbox>
 <20170112091016.GE2264@dhcp22.suse.cz>
 <20170113013724.GA23494@bbox>
 <20170113074705.GA21784@dhcp22.suse.cz>
 <20170113085734.GC8018@bbox>
 <20170113091009.GD25212@dhcp22.suse.cz>
 <20170117064531.GA9812@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170117064531.GA9812@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, hillf.zj@alibaba-inc.com, mgorman@suse.de, vbabka@suse.cz, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Tue 17-01-17 15:45:31, Minchan Kim wrote:
[...]
> Actually, IMO, there is no need to insert any tracepoint in inactive_list_is_low.
> Instead, if we add tracepint in get_scan_count to record each LRU list size and
> nr[LRU_{INACTIVE,ACTIVE}_{ANON|FILE}], it could be general and more helpful.

You are free to propose patches of course. I just worry that you are
overthinking this. This is no rocket science, really. We have a set of
trace points at places where we make a decision. Having a tracepoint in
inactive_list_is_low sounds like a proper fit to me. get_scan_count has
a different responsibility. We might disagree on that, though, but as
long as you preserve the debugability I won't be opposed.

I really do not see much point in discussing this further and spend more
time repeating arguments. After all the whole point of the series was
to make the debugging easier.  Which I believe is the case. Different
people do debugging differently so it is not really all that surprising
that we disagree on some parts. I really consider these tracepoints as a
debugging aid and exporting more than less has proven being useful in
the past. The worst thing really is when numbers do not make sense
because you are just missing part of the picture. I definitely agree
with you on the general objective to keep this debugging tools out of hot
paths and being too disruptive or spill over to the regular code to
cause a maintenance burden but I _believe_ this is not the case here.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
