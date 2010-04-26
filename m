Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E6D0F6B01EE
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 17:04:19 -0400 (EDT)
Subject: Re: [Bugme-new] [Bug 15709] New: swapper page allocation failure
From: Trond Myklebust <Trond.Myklebust@netapp.com>
In-Reply-To: <4BD5F6C5.8080605@tauceti.net>
References: <4BC43097.3060000@tauceti.net> <4BCC52B9.8070200@tauceti.net>
	 <20100419131718.GB16918@redhat.com>
	 <dbf86fc1c370496138b3a74a3c74ec18@tauceti.net>
	 <20100421094249.GC30855@redhat.com>
	 <c638ec9fdee2954ec5a7a2bd405aa2ba@tauceti.net>
	 <20100422100304.GC30532@redhat.com> <4BD12F9C.30802@tauceti.net>
	 <20100425091759.GA9993@redhat.com> <4BD4A917.70702@tauceti.net>
	 <20100425204916.GA12686@redhat.com>
	 <1272284154.4252.34.camel@localhost.localdomain>
	 <4BD5F6C5.8080605@tauceti.net>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 26 Apr 2010 17:04:14 -0400
Message-ID: <1272315854.8984.125.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Robert Wimmer <kernel@tauceti.net>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Avi Kivity <avi@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, Mel Gorman <mel@csn.ul.ie>, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2010-04-26 at 22:25 +0200, Robert Wimmer wrote:=20
> I've tried with NFSv3 now. With v4 the error normally occur
> within 5 minutes. The VM is now running for one hour and no
> soft lockup so far. So I would say it can't be reproduced with
> v3.

Thanks! That's useful info.

> >   - Have you tried running with stack tracing enabled?
> >  =20
>=20
> Can you explain this a little bit more please? CONFIG_STACKTRACE=3Dy
> was already enabled. I've now enabled
>=20
> CONFIG_USER_STACKTRACE_SUPPORT=3Dy
> CONFIG_NOP_TRACER=3Dy
> CONFIG_HAVE_FTRACE_NMI_ENTER=3Dy
> CONFIG_HAVE_FUNCTION_TRACER=3Dy
> CONFIG_HAVE_FUNCTION_GRAPH_TRACER=3Dy
> CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=3Dy
> CONFIG_HAVE_DYNAMIC_FTRACE=3Dy
> CONFIG_HAVE_FTRACE_MCOUNT_RECORD=3Dy
> CONFIG_HAVE_FTRACE_SYSCALLS=3Dy
> CONFIG_FTRACE_NMI_ENTER=3Dy
> CONFIG_CONTEXT_SWITCH_TRACER=3Dy
> CONFIG_GENERIC_TRACER=3Dy
> CONFIG_FTRACE=3Dy
> CONFIG_FUNCTION_TRACER=3Dy
> CONFIG_FUNCTION_GRAPH_TRACER=3Dy
> CONFIG_FTRACE_SYSCALLS=3Dy
> CONFIG_STACK_TRACER=3Dy
> CONFIG_KMEMTRACE=3Dy
> CONFIG_DYNAMIC_FTRACE=3Dy
> CONFIG_FTRACE_MCOUNT_RECORD=3Dy
> CONFIG_HAVE_MMIOTRACE_SUPPORT=3Dy
>=20
> and run
>=20
> echo 1 > /proc/sys/kernel/stack_tracer_enabled
>=20
> But the output is mostly the same in dmesg/
> var/log/messages. Can you please guide me how I can
> enable the stack tracing you need?

Sure. In addition to what you did above, please do

mount -t debugfs none /sys/kernel/debug

and then cat the contents of the pseudofile at

/sys/kernel/debug/tracing/stack_trace

Please do this more or less immediately after you've finished mounting
the NFSv4 client.

Does your server have the 'crossmnt' or 'nohide' flags set, or does it
use the 'refer' export option anywhere? If so, then we might have to
test further, since those may trigger the NFSv4 submount feature.

Cheers
  Trond

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
