Date: Wed, 16 Jul 2003 07:41:55 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.6.0-test1-mm1
Message-ID: <20030716144155.GK15452@holomorphy.com>
References: <20030715225608.0d3bff77.akpm@osdl.org> <20030716104448.GC25869@ip68-4-255-84.oc.oc.cox.net> <20030716035848.560674ac.akpm@osdl.org> <20030716122454.GJ15452@holomorphy.com> <20030716143221.GD25829@ip68-4-255-84.oc.oc.cox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030716143221.GD25829@ip68-4-255-84.oc.oc.cox.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Barry K. Nathan" <barryn@pobox.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 16, 2003 at 07:32:21AM -0700, Barry K. Nathan wrote:
> AFAICT it's starting from this:
> cpumask_t irq_affinity [NR_IRQS] =
>         { [0 ... NR_IRQS-1] = DEFAULT_CPU_AFFINITY };
> and NR_IRQS-1 is becoming 256, DEFAULT_CPU_AFFINITY is becoming
> cpumask_of_cpu(0). Then cpumask_of_cpu(0) is getting transformed some
> more (I haven't quite figured out what's going on there).
> Does this help at all?

Oh, well that won't fly; it effectively isn't a constant initializer.
I'll see what can be rammed past gcc. We're shooting for something
with array element 0 equal to 0x1UL and all others 0.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
