Subject: Re: [PATCH] [RESEND] x86_64: add memory hotremove config option
From: Andi Kleen <andi@firstfloor.org>
References: <20080905172132.GA11692@us.ibm.com>
Date: Fri, 05 Sep 2008 20:04:55 +0200
In-Reply-To: <20080905172132.GA11692@us.ibm.com> (Gary Hade's message of "Fri, 5 Sep 2008 10:21:32 -0700")
Message-ID: <87ej3yv588.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gary Hade <garyhade@us.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Badari Pulavarty <pbadari@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, linux-kernel@vger.kernel.org, x86@kernel.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Gary Hade <garyhade@us.ibm.com> writes:
>
> Add memory hotremove config option to x86_64
>
> Memory hotremove functionality can currently be configured into
> the ia64, powerpc, and s390 kernels.  This patch makes it possible
> to configure the memory hotremove functionality into the x86_64
> kernel as well. 

You forgot to describe how you tested it? Does it actually work.
And why do you want to do it it? What's the use case?

The general understanding was that it doesn't work very well on a real
machine at least because it cannot be controlled how that memory maps
to real pluggable hardware (and you cannot completely empty a node at runtime)
and a Hypervisor would likely use different interfaces anyways.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
