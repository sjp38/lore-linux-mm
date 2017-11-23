Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id B7A086B025F
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 08:03:06 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id g35so4667589lfi.0
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 05:03:06 -0800 (PST)
Received: from SELDSEGREL01.sonyericsson.com (seldsegrel01.sonyericsson.com. [37.139.156.29])
        by mx.google.com with ESMTPS id j14si6002471lfk.355.2017.11.23.05.03.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Nov 2017 05:03:05 -0800 (PST)
Subject: Re: [PATCH] Add slowpath enter/exit trace events
References: <20171123104336.25855-1-peter.enderborg@sony.com>
 <20171123122530.ktsxgeakebfp3yep@dhcp22.suse.cz>
 <ef88ca71-b41b-f5e9-fd41-d02676bad1cf@sony.com>
 <20171123124738.nj7foesbajo42t3g@dhcp22.suse.cz>
From: peter enderborg <peter.enderborg@sony.com>
Message-ID: <e9d1b05d-0188-6c98-7247-d43467fa73f5@sony.com>
Date: Thu, 23 Nov 2017 14:03:04 +0100
MIME-Version: 1.0
In-Reply-To: <20171123124738.nj7foesbajo42t3g@dhcp22.suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Language: en-GB
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, "David S . Miller" <davem@davemloft.net>, Harry Wentland <Harry.Wentland@amd.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Tony Cheng <Tony.Cheng@amd.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Pavel Tatashin <pasha.tatashin@oracle.com>

On 11/23/2017 01:47 PM, Michal Hocko wrote:
>
> This might be true but the other POV is that the trace point with the
> additional information is just too disruptive to the rest of the code
> and it exposes too many implementation details.

>From who do you want to hide details? Is this a security thing? I don't und=
erstand this=C2=A0 argument.=C2=A0 Tracefs is not part of uapi, right?

Hopefully there are not that many fails, and they might be very hard to rep=
roduce if you don't know what you are looking for.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
