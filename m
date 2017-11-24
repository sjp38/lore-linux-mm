Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2D3766B0033
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 02:43:50 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id d10so2847086lfj.17
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 23:43:50 -0800 (PST)
Received: from SELDSEGREL01.sonyericsson.com (seldsegrel01.sonyericsson.com. [37.139.156.29])
        by mx.google.com with ESMTPS id g62si7693554lje.313.2017.11.23.23.43.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Nov 2017 23:43:48 -0800 (PST)
Subject: Re: [PATCH] Add slowpath enter/exit trace events
References: <20171123104336.25855-1-peter.enderborg@sony.com>
 <20171123122530.ktsxgeakebfp3yep@dhcp22.suse.cz>
 <20171123133629.5sgmapfg7gix7pu3@techsingularity.net>
 <640b7de7-c216-de34-18e8-dc1aacd19f35@I-love.SAKURA.ne.jp>
From: peter enderborg <peter.enderborg@sony.com>
Message-ID: <16719b9b-b7e2-3cce-299b-99215b79518f@sony.com>
Date: Fri, 24 Nov 2017 08:43:47 +0100
MIME-Version: 1.0
In-Reply-To: <640b7de7-c216-de34-18e8-dc1aacd19f35@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Language: en-GB
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, "David S . Miller" <davem@davemloft.net>, Harry Wentland <Harry.Wentland@amd.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tony Cheng <Tony.Cheng@amd.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Pavel Tatashin <pasha.tatashin@oracle.com>

On 11/23/2017 02:43 PM, Tetsuo Handa wrote:
> Please see my attempt at
> http://lkml.kernel.org/r/1510833448-19918-1-git-send-email-penguin-kernel=
@I-love.SAKURA.ne.jp .
> Printing just current thread is not sufficient for me.
>
>
Seems to=A0 me that it is a lot more overhead with timers and stuff.
My probe is for the health of the system trying to capture how get the pena=
lty and how much. A slowpath alloc in a audio stream can causes drop-outs. =
And they are very hard to debug in userspace.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
