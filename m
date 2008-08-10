Received: by rv-out-0708.google.com with SMTP id f25so1749962rvb.26
        for <linux-mm@kvack.org>; Sun, 10 Aug 2008 10:48:33 -0700 (PDT)
Message-ID: <84144f020808101048l7d62c133paf320c48748fe514@mail.gmail.com>
Date: Sun, 10 Aug 2008 20:48:33 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [PATCH 5/5] kmemtrace: SLOB hooks.
In-Reply-To: <1218388447-5578-6-git-send-email-eduard.munteanu@linux360.ro>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1218388447-5578-1-git-send-email-eduard.munteanu@linux360.ro>
	 <1218388447-5578-2-git-send-email-eduard.munteanu@linux360.ro>
	 <1218388447-5578-3-git-send-email-eduard.munteanu@linux360.ro>
	 <1218388447-5578-4-git-send-email-eduard.munteanu@linux360.ro>
	 <1218388447-5578-5-git-send-email-eduard.munteanu@linux360.ro>
	 <1218388447-5578-6-git-send-email-eduard.munteanu@linux360.ro>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: mathieu.desnoyers@polymtl.ca, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rdunlap@xenotime.net, mpm@selenic.com, rostedt@goodmis.org, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

On Sun, Aug 10, 2008 at 8:14 PM, Eduard - Gabriel Munteanu
<eduard.munteanu@linux360.ro> wrote:
> This adds hooks for the SLOB allocator, to allow tracing with kmemtrace.
>
> We also convert some inline functions to __always_inline to make sure
> _RET_IP_, which expands to __builtin_return_address(0), always works
> as expected.
>
> Signed-off-by: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>

I think Matt acked this already but as you dropped the tags, I'll ask
once more before I merge this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
