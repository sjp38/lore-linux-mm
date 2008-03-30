Date: Sun, 30 Mar 2008 23:18:48 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC 8/8] x86_64: Support for new UV apic
Message-ID: <20080330211848.GA29105@one.firstfloor.org>
References: <20080324182122.GA28327@sgi.com> <87abknhzhd.fsf@basil.nowhere.org> <20080325175657.GA6262@sgi.com> <20080326073823.GD3442@elte.hu> <86802c440803301323q5c4bd4f4k1f9bdc1d6b1a0a7b@mail.gmail.com> <20080330210356.GA13383@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080330210356.GA13383@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: Yinghai Lu <yhlu.kernel@gmail.com>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> If there was a significant differece between UV and generic kernels
> (or hardware), then I would agree. However, the only significant
> difference is the APIC model on large systems. Small systems are
> exactly compatible.
> 
> The problem with subarch is that we want 1 binary kernel to support

x86-64 subarchs are more options than true subarchs. They generally
do not prevent the kernel from running on other systems, just
control addition of some additional code or special data layout. They are 
quite different from the i386 subarchs or those of other architectures.

The main reason vSMP is called a subarch is that it pads a lot
of data structures to 4K and you don't really want that on your
normal kernel, but there isn't anything in there that would
prevent booting on a normal system.

The UV option certainly doesn't have this issue.

> both generic hardware AND uv hardware. This restriction is desirable
> for the distros and software vendors. Otherwise, additional kernel
> images would have to be built, released, & certified.

I think an option would be fine, just don't call it a subarch. I don't
feel strongly about it, as you point out it is not really very much
code.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
