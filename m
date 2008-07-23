Date: Tue, 22 Jul 2008 21:26:11 -0400
From: "Frank Ch. Eigler" <fche@redhat.com>
Subject: Re: [RFC PATCH 1/4] kmemtrace: Core implementation.
Message-ID: <20080723012611.GB28486@redhat.com>
References: <1216751493-13785-1-git-send-email-eduard.munteanu@linux360.ro> <1216751493-13785-2-git-send-email-eduard.munteanu@linux360.ro> <y0mvdyx7gnj.fsf@ton.toronto.redhat.com> <20080723005002.GA5206@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080723005002.GA5206@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: penberg@cs.helsinki.fi, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rdunlap@xenotime.net, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

Hi -


On Wed, Jul 23, 2008 at 03:50:02AM +0300, Eduard - Gabriel Munteanu wrote:

> [...]  Sounds like a good idea, but I'd like to get rid of markers
> and use Mathieu Desnoyers' tracepoints instead. I'm just waiting for
> tracepoints to get closer to inclusion in mainline/-mm.

OK.

> It would be great if tracepoints completely replaced markers, so
> SystemTap would use those instead.

Raw tracepoints are problematic as they require a per-tracepoint C
function signature to be synthesized by the tool (or hard-coded in the
tool or elsewhere).  We haven't worked out how best do to this.  OTOH,
markers don't require such hard-coding, so are simpler for a general
tool to interface to.


> However, if tracepoints are not ready when kmemtrace is to be merged,
> I'll take your advice and mention markers and SystemTap.

Thanks either way - I'm glad you found an existing tracing mechanism
usable and didn't choose/need to invent your own.


- FChE

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
