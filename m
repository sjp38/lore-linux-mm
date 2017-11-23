Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id A20826B0033
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 07:47:41 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id o60so11994845wrc.14
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 04:47:41 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g52si7575912edc.164.2017.11.23.04.47.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Nov 2017 04:47:40 -0800 (PST)
Date: Thu, 23 Nov 2017 13:47:38 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] Add slowpath enter/exit trace events
Message-ID: <20171123124738.nj7foesbajo42t3g@dhcp22.suse.cz>
References: <20171123104336.25855-1-peter.enderborg@sony.com>
 <20171123122530.ktsxgeakebfp3yep@dhcp22.suse.cz>
 <ef88ca71-b41b-f5e9-fd41-d02676bad1cf@sony.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ef88ca71-b41b-f5e9-fd41-d02676bad1cf@sony.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peter enderborg <peter.enderborg@sony.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, "David S . Miller" <davem@davemloft.net>, Harry Wentland <Harry.Wentland@amd.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tony Cheng <Tony.Cheng@amd.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Pavel Tatashin <pasha.tatashin@oracle.com>

On Thu 23-11-17 13:35:15, peter enderborg wrote:
> Monitoring both enter/exit for all allocations and track down the one
> that are slow will be a very big load on mobile devices or embedded
> device consuming a lot of battery and cpu. With this we can do useful
> monitoring on devices on our field tests with real usage.

This might be true but the other POV is that the trace point with the
additional information is just too disruptive to the rest of the code
and it exposes too many implementation details.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
