Date: Wed, 16 Jun 2004 17:07:14 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH]: Option to run cache reap in thread mode
Message-ID: <20040616160714.GA14413@infradead.org>
References: <20040616142413.GA5588@sgi.com> <20040616152934.GA13527@infradead.org> <20040616160355.GA5963@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040616160355.GA5963@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dimitri Sivanich <sivanich@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 16, 2004 at 11:03:55AM -0500, Dimitri Sivanich wrote:
> On Wed, Jun 16, 2004 at 04:29:34PM +0100, Christoph Hellwig wrote:
> > YAKT, sigh..  I don't quite understand what you mean with a "holdoff" so
> > maybe you could explain what problem you see?  You don't like cache_reap
> > beeing called from timer context?
> 
> The issue(s) I'm attempting to solve is to achieve more deterministic interrupt
> response times on CPU's that have been designated for use as such.  By setting
> cache_reap to run as a kthread, the cpu is only unavailable during the time
> that irq's are disabled.  By doing this on a cpu that's been restricted from
> running most other processes, I have been able to achieve much more
> deterministic interrupt response times.
> 
> So yes, I don't want cache_reap to be called from timer context when I've
> configured a CPU as such.

Well, if you want deterministic interrupt latencies you should go for a realtime OS.
I know Linux is the big thing in the industry, but you're really better off looking
for a small Hard RT OS.  From the OpenSource world eCOS or RTEMS come to mind.  Or even
rtlinux/rtai if you want to run a full linux kernel as idle task.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
