Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 08E686B006A
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 05:11:13 -0500 (EST)
Received: by fxm8 with SMTP id 8so65613fxm.6
        for <linux-mm@kvack.org>; Fri, 22 Jan 2010 02:11:11 -0800 (PST)
Subject: Re: [RFC][PATCH] PM: Force GFP_NOIO during suspend/resume (was:
 Re: [linux-pm] Memory allocations in .suspend became very unreliable)
From: Maxim Levitsky <maximlevitsky@gmail.com>
In-Reply-To: <20100122103830.6C09.A69D9226@jp.fujitsu.com>
References: <201001212121.50272.rjw@sisk.pl>
	 <20100122100155.6C03.A69D9226@jp.fujitsu.com>
	 <20100122103830.6C09.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 22 Jan 2010 12:11:07 +0200
Message-ID: <1264155067.15930.4.camel@maxim-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-pm@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2010-01-22 at 10:42 +0900, KOSAKI Motohiro wrote: 
> > > > Probably we have multiple option. but I don't think GFP_NOIO is good
> > > > option. It assume the system have lots non-dirty cache memory and it isn't
> > > > guranteed.
> > > 
> > > Basically nothing is guaranteed in this case.  However, does it actually make
> > > things _worse_?  
> > 
> > Hmm..
> > Do you mean we don't need to prevent accidental suspend failure?
> > Perhaps, I did misunderstand your intention. If you think your patch solve
> > this this issue, I still disagree. but If you think your patch mitigate
> > the pain of this issue, I agree it. I don't have any reason to oppose your
> > first patch.
> 
> One question. Have anyone tested Rafael's $subject patch? 
> Please post test result. if the issue disapper by the patch, we can
> suppose the slowness is caused by i/o layer.

I did.

As far as I could see, patch does solve the problem I described.

Does it affect speed of suspend? I can't say for sure. It seems to be
the same.

Best regards,
Maxim Levitsky

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
