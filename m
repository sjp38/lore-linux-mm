Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D51CD6B0253
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 16:50:20 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 1so24380708wmz.2
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 13:50:20 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id q126si10225094wme.10.2016.08.05.13.50.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Aug 2016 13:50:19 -0700 (PDT)
Date: Fri, 5 Aug 2016 22:50:18 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [linux-mm] Drastic increase in application memory usage with
 Kernel version upgrade
Message-ID: <20160805205018.GE7999@amd>
References: <CGME20160805045709epcas3p1dc6f12f2fa3031112c4da5379e33b5e9@epcas3p1.samsung.com>
 <01a001d1eed5$c50726c0$4f157440$@samsung.com>
 <20160805082015.GA28235@bbox>
 <01c101d1ef28$50706ad0$f1514070$@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01c101d1ef28$50706ad0$f1514070$@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu.k@samsung.com>
Cc: 'Minchan Kim' <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jaejoon.seo@samsung.com, jy0.jeon@samsung.com, vishnu.ps@samsung.com

On Fri 2016-08-05 20:17:36, PINTU KUMAR wrote:
> Hi,

> > On Fri, Aug 05, 2016 at 10:26:37AM +0530, PINTU KUMAR wrote:
> > > Hi All,
> > >
> > > For one of our ARM embedded product, we recently updated the Kernel
> > > version from
> > > 3.4 to 3.18 and we noticed that the same application memory usage (PSS
> > > value) gone up by ~10% and for some cases it even crossed ~50%.
> > > There is no change in platform part. All platform component was built
> > > with ARM 32-bit toolchain.
> > > However, the Kernel is changed from 32-bit to 64-bit.
> > >
> > > Is upgrading Kernel version and moving from 32-bit to 64-bit is such a risk
> ?
> > > After the upgrade, what can we do further to reduce the application
> > > memory usage ?
> > > Is there any other factor that will help us to improve without major
> > > modifications in platform ?
> > >
> > > As a proof, we did a small experiment on our Ubuntu-32 bit machine.
> > > We upgraded Ubuntu Kernel version from 3.13 to 4.01 and we observed
> > > the
> > > following:
> > > ----------------------------------------------------------------------
> > > ----------
> > > -------------
> > > |UBUNTU-32 bit		|Kernel 3.13	|Kernel 4.03	|DIFF	|
> > > |CALCULATOR PSS	|6057 KB	|6466 KB	|409 KB	|
> > > ----------------------------------------------------------------------
> > > ----------
> > > -------------
> > > So, just by upgrading the Kernel version: PSS value for calculator is
> > > increased by 409KB.
> > >
> > > If anybody knows any in-sight about it please point out more details
> > > about the root cause.
> > 
> > One of culprit is [8c6e50b0290c, mm: introduce vm_ops->map_pages()].
> Ok. Thank you for your reply.
> So, if I revert this patch, will the memory usage be decreased for the processes
> with Kernel 3.18 ?

I guess you should try it...

You may want to try the same kernel version, once in 32-bit and once
in 64-bit version. And you may consider moving to recent kernel.

Yes, 64-bit kernel will increase memory usage _of kernel_, but...

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
