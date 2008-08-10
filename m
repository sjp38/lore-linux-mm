Subject: Re: [PATCH 5/5] kmemtrace: SLOB hooks.
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <84144f020808101048l7d62c133paf320c48748fe514@mail.gmail.com>
References: <1218388447-5578-1-git-send-email-eduard.munteanu@linux360.ro>
	 <1218388447-5578-2-git-send-email-eduard.munteanu@linux360.ro>
	 <1218388447-5578-3-git-send-email-eduard.munteanu@linux360.ro>
	 <1218388447-5578-4-git-send-email-eduard.munteanu@linux360.ro>
	 <1218388447-5578-5-git-send-email-eduard.munteanu@linux360.ro>
	 <1218388447-5578-6-git-send-email-eduard.munteanu@linux360.ro>
	 <84144f020808101048l7d62c133paf320c48748fe514@mail.gmail.com>
Content-Type: text/plain
Date: Sun, 10 Aug 2008 18:18:21 -0500
Message-Id: <1218410301.7576.310.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, mathieu.desnoyers@polymtl.ca, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rdunlap@xenotime.net, rostedt@goodmis.org, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

On Sun, 2008-08-10 at 20:48 +0300, Pekka Enberg wrote:
> On Sun, Aug 10, 2008 at 8:14 PM, Eduard - Gabriel Munteanu
> <eduard.munteanu@linux360.ro> wrote:
> > This adds hooks for the SLOB allocator, to allow tracing with kmemtrace.
> >
> > We also convert some inline functions to __always_inline to make sure
> > _RET_IP_, which expands to __builtin_return_address(0), always works
> > as expected.
> >
> > Signed-off-by: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
> 
> I think Matt acked this already but as you dropped the tags, I'll ask
> once more before I merge this.

Yeah, that's fine.

Acked-by: Matt Mackall <mpm@selenic.com>

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
