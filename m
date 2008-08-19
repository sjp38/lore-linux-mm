Received: from toip7.srvr.bell.ca ([209.226.175.124])
          by tomts40-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20080819202317.GDFS1625.tomts40-srv.bellnexxia.net@toip7.srvr.bell.ca>
          for <linux-mm@kvack.org>; Tue, 19 Aug 2008 16:23:17 -0400
Date: Tue, 19 Aug 2008 16:23:16 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [PATCH 1/5] Revert "kmemtrace: fix printk format warnings"
Message-ID: <20080819202316.GA4188@Krystal>
References: <1219167807-5407-1-git-send-email-eduard.munteanu@linux360.ro> <Pine.LNX.4.64.0808191049260.7877@shark.he.net> <20080819175440.GA5435@localhost> <20080819181652.GA29757@Krystal> <20080819183203.GB5520@localhost> <48AB1E43.2010408@cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <48AB1E43.2010408@cs.helsinki.fi>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, "Randy.Dunlap" <rdunlap@xenotime.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mpm@selenic.com, tglx@linutronix.de, rostedt@goodmis.org, cl@linux-foundation.org, tzanussi@gmail.com
List-ID: <linux-mm.kvack.org>

* Pekka Enberg (penberg@cs.helsinki.fi) wrote:
> Eduard - Gabriel Munteanu wrote:
>> On Tue, Aug 19, 2008 at 02:16:53PM -0400, Mathieu Desnoyers wrote:
>>> Question :
>>>
>>> Is this kmemtrace marker meant to be exposed to userspace ?
>>>
>>> I suspect not. In all case, not directly. I expect in-kernel probes to
>>> be connected on these markers which will get the arguments they need,
>>> and maybe access the inner data structures. Anyhow, tracepoints should
>>> be used for that, not markers. You can later put markers in the probes
>>> which are themselves connected to tracepoints.
>>>
>>> Tracepoints = in-kernel tracing API.
>>>
>>> Markers = Data-formatting tracing API, meant to export the data either
>>> to user-space in text or binary format.
>>>
>>> See
>>>
>>> http://git.kernel.org/?p=linux/kernel/git/compudj/linux-2.6-lttng.git;a=shortlog
>>>
>>> tracepoint-related patches.
>> I think we're ready to try tracepoints. Pekka, could you merge Mathieu's
>> tracepoints or otherwise provide a branch where I could submit a
>> tracepoint conversion patch for kmemtrace?
>
> Sorry, that's too much of a hassle for me. I'll happily take your 
> conversion patch once tracepoints hit mainline. Mathieu, are you aiming for 
> 2.6.28?

Probably. it's in -tip right now, and the new ftrace depends on it. So
at least 2.6.28 yes.

Mathieu

-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
