Subject: Re: [PATCH 1/5] Revert "kmemtrace: fix printk format warnings"
References: <1219167807-5407-1-git-send-email-eduard.munteanu@linux360.ro>
	<Pine.LNX.4.64.0808191049260.7877@shark.he.net>
	<20080819175440.GA5435@localhost> <20080819181652.GA29757@Krystal>
From: fche@redhat.com (Frank Ch. Eigler)
Date: Tue, 19 Aug 2008 14:47:16 -0400
In-Reply-To: <20080819181652.GA29757@Krystal> (Mathieu Desnoyers's message of "Tue, 19 Aug 2008 14:16:53 -0400")
Message-ID: <y0md4k4zvt7.fsf@ton.toronto.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, "Randy.Dunlap" <rdunlap@xenotime.net>, penberg@cs.helsinki.fi, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mpm@selenic.com, tglx@linutronix.de, rostedt@goodmis.org, cl@linux-foundation.org, tzanussi@gmail.com
List-ID: <linux-mm.kvack.org>

Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca> writes:

> [...]
> Is this kmemtrace marker meant to be exposed to userspace ?
> I suspect not.
> [...]
> Tracepoints = in-kernel tracing API.
> Markers = Data-formatting tracing API, meant to export the data either
> to user-space in text or binary format.

FWIW, that was certainly not the intent of markers.  It was to try to
satisfy both sorts of uses with relative type-safety and a minimum of
code.  Tracepoints may be nice if one needs somewhat (how much?) more
performance, and is willing to burden someone else with the necessary
extra code (such as tracepoint-to-marker conversion modules) to expose
the same data to "userspace" tools like lttng/systemtap.

- FChE

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
