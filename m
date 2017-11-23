Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 24BC16B025E
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 08:00:35 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id v123so8681839oif.23
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 05:00:35 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id q11si8502528otd.162.2017.11.23.05.00.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Nov 2017 05:00:33 -0800 (PST)
Subject: Re: [PATCH] Add slowpath enter/exit trace events
References: <20171123104336.25855-1-peter.enderborg@sony.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <f12576a9-93e5-48db-3e70-88d73907801d@I-love.SAKURA.ne.jp>
Date: Thu, 23 Nov 2017 22:00:04 +0900
MIME-Version: 1.0
In-Reply-To: <20171123104336.25855-1-peter.enderborg@sony.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peter.enderborg@sony.com, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, "David S . Miller" <davem@davemloft.net>, Harry Wentland <Harry.Wentland@amd.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tony Cheng <Tony.Cheng@amd.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Pavel Tatashin <pasha.tatashin@oracle.com>

On 2017/11/23 19:43, peter.enderborg@sony.com wrote:
> The warning of slow allocation has been removed, this is
> a other way to fetch that information. But you need
> to enable the trace. The exit function also returns
> information about the number of retries, how long
> it was stalled and failure reason if that happened.

However, the fast path (I mean, get_page_from_freelist() at
"/* First allocation attempt */" label) might be slow, for it is
allowed to call node_reclaim() which can take uncontrollable
duration. I think that you need to add hooks like
http://lkml.kernel.org/r/1510833448-19918-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp does. ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
