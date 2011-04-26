Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 37531900001
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 02:13:56 -0400 (EDT)
Date: Tue, 26 Apr 2011 14:13:53 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: readahead and oom
Message-ID: <20110426061353.GA19717@localhost>
References: <BANLkTin8mE=DLWma=U+CdJaQW03X2M2W1w@mail.gmail.com>
 <20110426055521.GA18473@localhost>
 <BANLkTik8k9A8N8CPk+eXo9c_syxJFRyFCA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTik8k9A8N8CPk+eXo9c_syxJFRyFCA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <hidave.darkstar@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Apr 26, 2011 at 02:05:12PM +0800, Dave Young wrote:
> On Tue, Apr 26, 2011 at 1:55 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > On Tue, Apr 26, 2011 at 01:49:25PM +0800, Dave Young wrote:
> >> Hi,
> >>
> >> When memory pressure is high, readahead could cause oom killing.
> >> IMHO we should stop readaheading under such circumstancesa??If it's true
> >> how to fix it?
> >
> > Good question. Before OOM there will be readahead thrashings, which
> > can be addressed by this patch:
> >
> > http://lkml.org/lkml/2010/2/2/229
> 
> Hi, I'm not clear about the patch, could be regard as below cases?
> 1) readahead alloc fail due to low memory such as other large allocation
> 2) readahead thrashing caused by itself

When memory pressure goes up (not as much as allocation failures and OOM),
the readahead pages may be reclaimed before they are read() accessed
by the user space. At the time read() asks for the page, it will have
to be read from disk _again_. This is called readahead thrashing.

What the patch does is to automatically detect readahead thrashing and
shrink the readahead size adaptively, which will the reduce memory
consumption by readahead buffers.

Thanks,
Fengguang

> >
> > However there seems no much interest on that feature.. I can separate
> > that out and resubmit it standalone if necessary.
> >
> > Thanks,
> > Fengguang
> >
> 
> 
> 
> -- 
> Regards
> dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
