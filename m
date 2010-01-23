Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B147D6B006A
	for <linux-mm@kvack.org>; Sat, 23 Jan 2010 04:29:27 -0500 (EST)
Received: by fxm5 with SMTP id 5so1951602fxm.11
        for <linux-mm@kvack.org>; Sat, 23 Jan 2010 01:29:25 -0800 (PST)
Subject: Re: [Update][PATCH] MM / PM: Force GFP_NOIO during
 suspend/hibernation and resume
From: Maxim Levitsky <maximlevitsky@gmail.com>
In-Reply-To: <201001222219.15958.rjw@sisk.pl>
References: <201001212121.50272.rjw@sisk.pl>
	 <20100122103830.6C09.A69D9226@jp.fujitsu.com>
	 <1264155067.15930.4.camel@maxim-laptop>  <201001222219.15958.rjw@sisk.pl>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 23 Jan 2010 11:29:22 +0200
Message-ID: <1264238962.16031.4.camel@maxim-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-pm@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2010-01-22 at 22:19 +0100, Rafael J. Wysocki wrote: 
> On Friday 22 January 2010, Maxim Levitsky wrote:
> > On Fri, 2010-01-22 at 10:42 +0900, KOSAKI Motohiro wrote: 
> > > > > > Probably we have multiple option. but I don't think GFP_NOIO is good
> > > > > > option. It assume the system have lots non-dirty cache memory and it isn't
> > > > > > guranteed.
> > > > > 
> > > > > Basically nothing is guaranteed in this case.  However, does it actually make
> > > > > things _worse_?  
> > > > 
> > > > Hmm..
> > > > Do you mean we don't need to prevent accidental suspend failure?
> > > > Perhaps, I did misunderstand your intention. If you think your patch solve
> > > > this this issue, I still disagree. but If you think your patch mitigate
> > > > the pain of this issue, I agree it. I don't have any reason to oppose your
> > > > first patch.
> > > 
> > > One question. Have anyone tested Rafael's $subject patch? 
> > > Please post test result. if the issue disapper by the patch, we can
> > > suppose the slowness is caused by i/o layer.
> > 
> > I did.
> > 
> > As far as I could see, patch does solve the problem I described.
> > 
> > Does it affect speed of suspend? I can't say for sure. It seems to be
> > the same.
> 
> Thanks for testing.

I'll test that too, soon.
Just to note that I left my hibernate loop run overnight, and now I am
posting from my notebook after it did 590 hibernate cycles.


Offtopic, but Note that to achieve that I had to stop using global acpi
hardware lock. I tried all kinds of things, but for now it just hands
from time to time.
See http://bugzilla.kernel.org/show_bug.cgi?id=14668

Best regards,
Maxim Levitsky




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
