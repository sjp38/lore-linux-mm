Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1E6706B0033
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 09:01:30 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id n8so4981574wmg.4
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 06:01:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x9si9401353edh.429.2017.11.23.06.01.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Nov 2017 06:01:28 -0800 (PST)
Date: Thu, 23 Nov 2017 15:01:27 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] Add slowpath enter/exit trace events
Message-ID: <20171123140127.7z5z6awj2ti6lozh@dhcp22.suse.cz>
References: <20171123104336.25855-1-peter.enderborg@sony.com>
 <20171123122530.ktsxgeakebfp3yep@dhcp22.suse.cz>
 <20171123133629.5sgmapfg7gix7pu3@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171123133629.5sgmapfg7gix7pu3@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: peter.enderborg@sony.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, "David S . Miller" <davem@davemloft.net>, Harry Wentland <Harry.Wentland@amd.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tony Cheng <Tony.Cheng@amd.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Pavel Tatashin <pasha.tatashin@oracle.com>

On Thu 23-11-17 13:36:29, Mel Gorman wrote:
> On Thu, Nov 23, 2017 at 01:25:30PM +0100, Michal Hocko wrote:
> > On Thu 23-11-17 11:43:36, peter.enderborg@sony.com wrote:
> > > From: Peter Enderborg <peter.enderborg@sony.com>
> > > 
> > > The warning of slow allocation has been removed, this is
> > > a other way to fetch that information. But you need
> > > to enable the trace. The exit function also returns
> > > information about the number of retries, how long
> > > it was stalled and failure reason if that happened.
> > 
> > I think this is just too excessive. We already have a tracepoint for the
> > allocation exit. All we need is an entry to have a base to compare with.
> > Another usecase would be to measure allocation latency. Information you
> > are adding can be (partially) covered by existing tracepoints.
> > 
> 
> You can gather that by simply adding a probe to __alloc_pages_slowpath
> (like what perf probe does) and matching the trigger with the existing
> mm_page_alloc points.

I am not sure adding a probe on a production system will fly in many
cases. A static tracepoint would be much easier in that case. But I
agree there are other means to accomplish the same thing. My main point
was to have an easy out-of-the-box way to check latencies. But that is
not something I would really insist on.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
