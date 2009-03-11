Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DB1036B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 04:22:10 -0400 (EDT)
Date: Wed, 11 Mar 2009 16:20:38 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-ID: <20090311082038.GA32129@localhost>
References: <20090310105523.3dfd4873@mjolnir.ossman.eu> <20090310122210.GA8415@localhost> <20090310131155.GA9654@localhost> <20090310212118.7bf17af6@mjolnir.ossman.eu> <20090311013739.GA7078@localhost> <20090311075703.35de2488@mjolnir.ossman.eu> <20090311071445.GA13584@localhost> <20090311082658.06ff605a@mjolnir.ossman.eu> <20090311073619.GA26691@localhost> <20090311085738.4233df4e@mjolnir.ossman.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090311085738.4233df4e@mjolnir.ossman.eu>
Sender: owner-linux-mm@kvack.org
To: Pierre Ossman <drzeus@drzeus.cx>
Cc: Andrew Morton <akpm@linux-foundation.org>, "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 11, 2009 at 09:57:38AM +0200, Pierre Ossman wrote:
> On Wed, 11 Mar 2009 15:36:19 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > 
> > A quick question: are there any possibility of ftrace memory reservation?
> > 
> 
> You tell me. CONFIG_FTRACE was always disabled, but CONFIG_HAVE_*FTRACE
> is always on. FTRACE wasn't included in 2.6.26 though, and the bisect
> showed only ftrace commits. So it would explain things.

There are some __get_free_page() calls in kernel/trace/ring_buffer.c,
maybe the pages are consumed by one of them?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
