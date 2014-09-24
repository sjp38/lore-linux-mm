Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 55FA66B0036
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 12:49:28 -0400 (EDT)
Received: by mail-we0-f180.google.com with SMTP id u56so6507850wes.39
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 09:49:27 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTP id ju2si19974445wjc.138.2014.09.24.09.49.26
        for <linux-mm@kvack.org>;
        Wed, 24 Sep 2014 09:49:26 -0700 (PDT)
Date: Wed, 24 Sep 2014 18:49:25 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [next:master 7267/7446] drivers/rtc/rtc-bq32k.c:169:3: warning:
 'setup' may be used uninitialized in this function
Message-ID: <20140924164925.GA1231@amd>
References: <542131f8.FeDGKH/9671AZbCt%fengguang.wu@intel.com>
 <20140923140109.d1e81b714082e562b7fb3e2c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140923140109.d1e81b714082e562b7fb3e2c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org

On Tue 2014-09-23 14:01:09, Andrew Morton wrote:
> On Tue, 23 Sep 2014 16:40:24 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
> 
> > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> > head:   55f21306900abf9f9d2a087a127ff49c6d388ad2
> > commit: 7bb72683b1708c3cf3bea0575c0e80314a2232dc [7267/7446] rtc: bq32000: add trickle charger option, with device tree binding
> > config: i386-randconfig-ib0-09231629 (attached as .config)
> > reproduce:
> >   git checkout 7bb72683b1708c3cf3bea0575c0e80314a2232dc
> >   # save the attached .config to linux build tree
> >   make ARCH=i386 
> > 
> > Note: it may well be a FALSE warning. FWIW you are at least aware of it now.
> > http://gcc.gnu.org/wiki/Better_Uninitialized_Warnings
> > 
> > All warnings:
> > 
> >    drivers/rtc/rtc-bq32k.c: In function 'trickle_charger_of_init':
> >    drivers/rtc/rtc-bq32k.c:155:7: warning: assignment makes pointer from integer without a cast
> >       reg = 0x05;
> >           ^
> >    drivers/rtc/rtc-bq32k.c:165:7: warning: assignment makes pointer from integer without a cast
> >       reg = 0x25;
> >           ^
> >    drivers/rtc/rtc-bq32k.c:177:6: warning: assignment makes pointer from integer without a cast
> >      reg = 0x20;
> >          ^
> >    drivers/rtc/rtc-bq32k.c:135:6: warning: unused variable 'plen' [-Wunused-variable]
> >      int plen = 0;
> >          ^
> >    drivers/rtc/rtc-bq32k.c: In function 'bq32k_probe':
> > >> drivers/rtc/rtc-bq32k.c:169:3: warning: 'setup' may be used uninitialized in this function [-Wmaybe-uninitialized]
> >       dev_err(dev, "invalid resistor value (%d)\n", *setup);
> >       ^
> >    drivers/rtc/rtc-bq32k.c:136:18: note: 'setup' was declared here
> >      const uint32_t *setup;
> 
> Pavel's changelog failed to tell us what warnings were being fixed
> (bad!) but I expect the below will fix this.

Yes, it should. Thanks for patience,

								Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
