Date: Mon, 11 Aug 2008 11:57:47 -0400
From: "Frank Ch. Eigler" <fche@redhat.com>
Subject: Re: [PATCH 4/5] kmemtrace: SLUB hooks.
Message-ID: <20080811155747.GC15331@redhat.com>
References: <1218388447-5578-3-git-send-email-eduard.munteanu@linux360.ro> <1218388447-5578-4-git-send-email-eduard.munteanu@linux360.ro> <1218388447-5578-5-git-send-email-eduard.munteanu@linux360.ro> <48A046F5.2000505@linux-foundation.org> <1218463774.7813.291.camel@penberg-laptop> <48A048FD.30909@linux-foundation.org> <alpine.DEB.1.10.0808111027370.29861@gandalf.stny.rr.com> <48A04EC2.1080302@linux-foundation.org> <y0mhc9ra7m6.fsf@ton.toronto.redhat.com> <48A05F4D.4080404@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48A05F4D.4080404@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, mathieu.desnoyers@polymtl.ca, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rdunlap@xenotime.net, mpm@selenic.com, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

Hi -

On Mon, Aug 11, 2008 at 10:48:29AM -0500, Christoph Lameter wrote:
> [...]
> AFAICT: Each test also adds an out of line call to the tracing facility.

Yes, but that call is normally placed out of the cache-hot path with unlikely().

- FChE

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
