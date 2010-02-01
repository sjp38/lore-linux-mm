Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B04396B004D
	for <linux-mm@kvack.org>; Mon,  1 Feb 2010 14:52:07 -0500 (EST)
Received: by fxm8 with SMTP id 8so4822274fxm.6
        for <linux-mm@kvack.org>; Mon, 01 Feb 2010 11:52:01 -0800 (PST)
Subject: Re: [RFC][PATCH] PM: Force GFP_NOIO during suspend/resume (was:
 Re: [linux-pm] Memory allocations in .suspend became very unreliable)
From: Maxim Levitsky <maximlevitsky@gmail.com>
In-Reply-To: <1264883863.13861.3.camel@maxim-laptop>
References: <1263549544.3112.10.camel@maxim-laptop>
	 <201001170138.37283.rjw@sisk.pl> <1264866419.27933.0.camel@maxim-laptop>
	 <201001301947.10453.rjw@sisk.pl>  <1264883863.13861.3.camel@maxim-laptop>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 01 Feb 2010 21:51:56 +0200
Message-ID: <1265053916.26421.1.camel@maxim-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-pm@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Sat, 2010-01-30 at 22:37 +0200, Maxim Levitsky wrote: 
> On Sat, 2010-01-30 at 19:47 +0100, Rafael J. Wysocki wrote: 
> > On Saturday 30 January 2010, Maxim Levitsky wrote:
> > > On Sun, 2010-01-17 at 01:38 +0100, Rafael J. Wysocki wrote: 
> > > > Hi,
> > > > 
> > > > I thing the snippet below is a good summary of what this is about.
> > > 
> > > Any progress on that?
> > 
> > Well, I'm waiting for you to report back:
> > http://patchwork.kernel.org/patch/74740/
> > 
> > The patch is appended once again for convenience.
> 
> Ah, sorry!
> 
> I used the second version (with the locks) and it works for sure (~500
> cycles)
> 
> However, as I discovered today, it takes the lock also for GFP_ATOMIC,
> and thats why I see several backtraces in the kernel log. Anyway this
> isn't important.
> 
> I forgot all about this patch, and I am compiling the kernel right away.
> Will put the kernel through the hibernate loop tonight.

I did 123 hibernate cycles on my notebook. Everything is fine.
This patch very very likely is working.

Best regards,
Maxim Levitsky

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
