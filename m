Received: by gxk8 with SMTP id 8so6089148gxk.14
        for <linux-mm@kvack.org>; Tue, 19 Aug 2008 11:36:56 -0700 (PDT)
Date: Tue, 19 Aug 2008 21:32:03 +0300
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: Re: [PATCH 1/5] Revert "kmemtrace: fix printk format warnings"
Message-ID: <20080819183203.GB5520@localhost>
References: <1219167807-5407-1-git-send-email-eduard.munteanu@linux360.ro> <Pine.LNX.4.64.0808191049260.7877@shark.he.net> <20080819175440.GA5435@localhost> <20080819181652.GA29757@Krystal>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080819181652.GA29757@Krystal>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: "Randy.Dunlap" <rdunlap@xenotime.net>, penberg@cs.helsinki.fi, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mpm@selenic.com, tglx@linutronix.de, rostedt@goodmis.org, cl@linux-foundation.org, tzanussi@gmail.com
List-ID: <linux-mm.kvack.org>

On Tue, Aug 19, 2008 at 02:16:53PM -0400, Mathieu Desnoyers wrote:
> Question :
> 
> Is this kmemtrace marker meant to be exposed to userspace ?
> 
> I suspect not. In all case, not directly. I expect in-kernel probes to
> be connected on these markers which will get the arguments they need,
> and maybe access the inner data structures. Anyhow, tracepoints should
> be used for that, not markers. You can later put markers in the probes
> which are themselves connected to tracepoints.
> 
> Tracepoints = in-kernel tracing API.
> 
> Markers = Data-formatting tracing API, meant to export the data either
> to user-space in text or binary format.
> 
> See
> 
> http://git.kernel.org/?p=linux/kernel/git/compudj/linux-2.6-lttng.git;a=shortlog
> 
> tracepoint-related patches.

I think we're ready to try tracepoints. Pekka, could you merge Mathieu's
tracepoints or otherwise provide a branch where I could submit a
tracepoint conversion patch for kmemtrace?

> Mathieu
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
