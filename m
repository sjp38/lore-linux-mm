Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 659156B01E3
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 16:25:37 -0400 (EDT)
Message-ID: <4BD5F6C5.8080605@tauceti.net>
Date: Mon, 26 Apr 2010 22:25:41 +0200
From: Robert Wimmer <kernel@tauceti.net>
MIME-Version: 1.0
Subject: Re: [Bugme-new] [Bug 15709] New: swapper page allocation failure
References: <4BC43097.3060000@tauceti.net> <4BCC52B9.8070200@tauceti.net> <20100419131718.GB16918@redhat.com> <dbf86fc1c370496138b3a74a3c74ec18@tauceti.net> <20100421094249.GC30855@redhat.com> <c638ec9fdee2954ec5a7a2bd405aa2ba@tauceti.net> <20100422100304.GC30532@redhat.com> <4BD12F9C.30802@tauceti.net> <20100425091759.GA9993@redhat.com> <4BD4A917.70702@tauceti.net> <20100425204916.GA12686@redhat.com> <1272284154.4252.34.camel@localhost.localdomain>
In-Reply-To: <1272284154.4252.34.camel@localhost.localdomain>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Avi Kivity <avi@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, Mel Gorman <mel@csn.ul.ie>, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


>>> I've added CONFIG_KALLSYMS and CONFIG_KALLSYMS_ALL
>>> to my .config. I've uploaded the dmesg output. Maybe it
>>> helps a little bit:
>>>
>>> https://bugzilla.kernel.org/attachment.cgi?id=26138
>>>
>>> - Robert
>>>
>>>       
> That last trace is just saying that the NFSv4 reboot recovery code is
> crashing (which is hardly surprising if the memory management is hosed).
>
> The initial bisection makes little sense to me: it is basically blaming
> a page allocation problem on a change to the NFSv4 mount code. The only
> way I can see that possibly happen is if you are hitting a stack
> overflow.
> So 2 questions:
>
>   - Are you able to reproduce the bug when using NFSv3 instead?
>   

I've tried with NFSv3 now. With v4 the error normally occur
within 5 minutes. The VM is now running for one hour and no
soft lockup so far. So I would say it can't be reproduced with
v3.

>   - Have you tried running with stack tracing enabled?
>   

Can you explain this a little bit more please? CONFIG_STACKTRACE=y
was already enabled. I've now enabled

CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FTRACE_NMI_ENTER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_FTRACE_SYSCALLS=y
CONFIG_FTRACE_NMI_ENTER=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_GENERIC_TRACER=y
CONFIG_FTRACE=y
CONFIG_FUNCTION_TRACER=y
CONFIG_FUNCTION_GRAPH_TRACER=y
CONFIG_FTRACE_SYSCALLS=y
CONFIG_STACK_TRACER=y
CONFIG_KMEMTRACE=y
CONFIG_DYNAMIC_FTRACE=y
CONFIG_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_MMIOTRACE_SUPPORT=y

and run

echo 1 > /proc/sys/kernel/stack_tracer_enabled

But the output is mostly the same in dmesg/
var/log/messages. Can you please guide me how I can
enable the stack tracing you need?

Thanks!
Robert

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
