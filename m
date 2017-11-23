Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9F9306B0069
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 08:47:48 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id d6so17079754pfb.3
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 05:47:48 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n1si16061955pgt.498.2017.11.23.05.47.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Nov 2017 05:47:47 -0800 (PST)
Date: Thu, 23 Nov 2017 14:47:43 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] Add slowpath enter/exit trace events
Message-ID: <20171123134743.rllnw4u4b73kfrre@dhcp22.suse.cz>
References: <20171123104336.25855-1-peter.enderborg@sony.com>
 <20171123122530.ktsxgeakebfp3yep@dhcp22.suse.cz>
 <ef88ca71-b41b-f5e9-fd41-d02676bad1cf@sony.com>
 <20171123124738.nj7foesbajo42t3g@dhcp22.suse.cz>
 <e9d1b05d-0188-6c98-7247-d43467fa73f5@sony.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <e9d1b05d-0188-6c98-7247-d43467fa73f5@sony.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peter enderborg <peter.enderborg@sony.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, "David S . Miller" <davem@davemloft.net>, Harry Wentland <Harry.Wentland@amd.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tony Cheng <Tony.Cheng@amd.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Pavel Tatashin <pasha.tatashin@oracle.com>

On Thu 23-11-17 14:03:04, peter enderborg wrote:
> On 11/23/2017 01:47 PM, Michal Hocko wrote:
> >
> > This might be true but the other POV is that the trace point with the
> > additional information is just too disruptive to the rest of the code
> > and it exposes too many implementation details.
> 
> From who do you want to hide details? Is this a security thing? I
> don't understand this  argument.  Tracefs is not part of uapi,
> right?

Linus would disagree https://lwn.net/Articles/737530/

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
