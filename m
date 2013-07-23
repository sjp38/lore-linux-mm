Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 6B2296B0032
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 04:20:44 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id d51so53433eek.0
        for <linux-mm@kvack.org>; Tue, 23 Jul 2013 01:20:42 -0700 (PDT)
Date: Tue, 23 Jul 2013 10:20:39 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC 0/4] Transparent on-demand struct page initialization
 embedded in the buddy allocator
Message-ID: <20130723082039.GD16088@gmail.com>
References: <1373594635-131067-1-git-send-email-holt@sgi.com>
 <20130712082756.GA4328@gmail.com>
 <20130716085502.GA31276@lge.com>
 <20130716090805.GC4402@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130716090805.GC4402@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Robin Holt <holt@sgi.com>, Robert Richter <rric@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Nate Zimmer <nzimmer@sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Rob Landley <rob@landley.net>, Mike Travis <travis@sgi.com>, Daniel J Blueman <daniel@numascale-asia.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Yinghai Lu <yinghai@kernel.org>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>


* Borislav Petkov <bp@alien8.de> wrote:

> On Tue, Jul 16, 2013 at 05:55:02PM +0900, Joonsoo Kim wrote:
> > How about executing a perf in usermodehelper and collecting output
> > in tmpfs? Using this approach, we can start a perf after rootfs
> > initialization,
> 
> What for if we can start logging to buffers much earlier? *Reading*
> from those buffers can be done much later, at our own leisure with full
> userspace up.

Yeah, agreed, I think this needs to be more integrated into the kernel, so 
that people don't have to worry about "when does userspace start up the 
earliest" details.

Fundamentally all perf really needs here is some memory to initialize and 
buffer into.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
