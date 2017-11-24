Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id D853D6B0033
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 03:38:34 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id g35so5235072lfi.0
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 00:38:34 -0800 (PST)
Received: from SELDSEGREL01.sonyericsson.com (seldsegrel01.sonyericsson.com. [37.139.156.29])
        by mx.google.com with ESMTPS id w9si7197144lfd.192.2017.11.24.00.38.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Nov 2017 00:38:33 -0800 (PST)
Subject: Re: [PATCH] Add slowpath enter/exit trace events
References: <20171123104336.25855-1-peter.enderborg@sony.com>
 <20171123122530.ktsxgeakebfp3yep@dhcp22.suse.cz>
 <20171123133629.5sgmapfg7gix7pu3@techsingularity.net>
 <20171123140127.7z5z6awj2ti6lozh@dhcp22.suse.cz>
From: peter enderborg <peter.enderborg@sony.com>
Message-ID: <dfd93744-4854-cf63-e357-6bfcf505a62f@sony.com>
Date: Fri, 24 Nov 2017 09:38:31 +0100
MIME-Version: 1.0
In-Reply-To: <20171123140127.7z5z6awj2ti6lozh@dhcp22.suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Language: en-GB
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, "David S . Miller" <davem@davemloft.net>, Harry Wentland <Harry.Wentland@amd.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tony Cheng <Tony.Cheng@amd.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Pavel Tatashin <pasha.tatashin@oracle.com>

On 11/23/2017 03:01 PM, Michal Hocko wrote:
> I am not sure adding a probe on a production system will fly in many
> cases. A static tracepoint would be much easier in that case. But I
> agree there are other means to accomplish the same thing. My main point
> was to have an easy out-of-the-box way to check latencies. But that is
> not something I would really insist on.
>
In android tracefs (or part of it) is the way for the system to control to =
what developers can access to the linux system on commercial devices.=C2=A0=
 So it is very much used on production systems, it is even=C2=A0 a requirem=
ent from google to be certified as android.=C2=A0 Things like dmesg is not.=
=C2=A0 However, this probe is at the moment not in that scope.=C2=A0

My point is that you need to condense the information as much as possible b=
ut still be useful before making the effort to copy it to userspace.=C2=A0 =
And=C2=A0 for this the trace-event are very useful for small systems since =
the cost is very low for events where no one is listening.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
