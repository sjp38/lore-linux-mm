Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 05C5A6B0034
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 04:47:32 -0400 (EDT)
Date: Fri, 12 Jul 2013 10:47:12 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: boot tracing
Message-ID: <20130712084712.GD24008@pd.tnic>
References: <1373594635-131067-1-git-send-email-holt@sgi.com>
 <20130712082756.GA4328@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20130712082756.GA4328@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Robin Holt <holt@sgi.com>, Robert Richter <rric@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Nate Zimmer <nzimmer@sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Rob Landley <rob@landley.net>, Mike Travis <travis@sgi.com>, Daniel J Blueman <daniel@numascale-asia.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Yinghai Lu <yinghai@kernel.org>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Fri, Jul 12, 2013 at 10:27:56AM +0200, Ingo Molnar wrote:
> Robert Richter and Boris Petkov are working on 'persistent events'
> support for perf, which will eventually allow boot time profiling -
> I'm not sure if the patches and the tooling support is ready enough
> yet for your purposes.

Nope, not yet but we're getting there.

> Robert, Boris, the following workflow would be pretty intuitive:
> 
>  - kernel developer sets boot flag: perf=boot,freq=1khz,size=16MB

What does perf=boot mean? I assume boot tracing.

If so, does it mean we want to enable *all* tracepoints and collect
whatever hits us?

What makes more sense to me is to hijack what the function tracer does -
i.e. simply collect all function calls.

>  - we'd get a single (cycles?) event running once the perf subsystem is up
>    and running, with a sampling frequency of 1 KHz, sending profiling
>    trace events to a sufficiently sized profiling buffer of 16 MB per
>    CPU.

Right, what would those trace events be?

>  - once the system reaches SYSTEM_RUNNING, profiling is stopped either
>    automatically - or the user stops it via a new tooling command.

Ok.

>  - the profiling buffer is extracted into a regular perf.data via a
>    special 'perf record' call or some other, new perf tooling 
>    solution/variant.
> 
>    [ Alternatively the kernel could attempt to construct a 'virtual'
>      perf.data from the persistent buffer, available via /sys/debug or
>      elsewhere in /sys - just like the kernel constructs a 'virtual' 
>      /proc/kcore, etc. That file could be copied or used directly. ]

Yeah, that.

>  - from that point on this workflow joins the regular profiling workflow: 
>    perf report, perf script et al can be used to analyze the resulting
>    boot profile.

Agreed.

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
