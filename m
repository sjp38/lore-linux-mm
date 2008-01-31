Date: Thu, 31 Jan 2008 09:50:13 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 6/6] s390: Use generic percpu linux-2.6.git
Message-ID: <20080131085013.GB1585@elte.hu>
References: <20080130180940.022172000@sgi.com> <20080130180940.921597000@sgi.com> <20080130215339.GC28242@elte.hu> <1201768346.18221.5.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1201768346.18221.5.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: travis@sgi.com, Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Martin Schwidefsky <schwidefsky@de.ibm.com> wrote:

> On Wed, 2008-01-30 at 22:53 +0100, Ingo Molnar wrote:
> > * travis@sgi.com <travis@sgi.com> wrote:
> > 
> > > Change s390 percpu.h to use asm-generic/percpu.h
> > 
> > do the s390 maintainer agree with this change (Acks please), and has it 
> > been tested on s390?
> 
> Now I'm confused. The patch has been acked a few weeks ago and the 
> last 5+ version of the patch had the acked line. The lastest version 
> dropped it for a reason I don't know. And more, the patch is already 
> upstream with the (correct) acked line, see git commit 
> f034347470e486835ccdcd7a5bb2ceb417be11c4. So, what is the problem ?

the latest patch was sent without your acked line and i asked about 
that. But later on Mike told me that you acked it - so i restored the 
ack and the patch, Linus pulled the fixes and it now all is upstream and 
all architectures should be fine again now.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
