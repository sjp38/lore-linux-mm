Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id C2EC76B0038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 11:46:52 -0500 (EST)
Received: by pabrd3 with SMTP id rd3so19972078pab.5
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 08:46:52 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id lq9si10361773pab.61.2015.03.05.08.46.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 08:46:52 -0800 (PST)
Date: Thu, 5 Mar 2015 19:46:36 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 0/4] cleancache: remove limit on the number of cleancache
 enabled filesystems
Message-ID: <20150305164636.GB4762@esperanza>
References: <cover.1424628280.git.vdavydov@parallels.com>
 <20150223161222.GD30733@l.oracle.com>
 <20150224103406.GF16138@esperanza>
 <20150304212230.GB18253@l.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150304212230.GB18253@l.oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Vrabel <david.vrabel@citrix.com>, Mark
 Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>, Stefan Hengelein <ilendir@googlemail.com>, Florian Schmaus <fschmaus@gmail.com>, Andor Daam <andor.daam@googlemail.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Bob Liu <lliubbo@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Mar 04, 2015 at 04:22:30PM -0500, Konrad Rzeszutek Wilk wrote:
> On Tue, Feb 24, 2015 at 01:34:06PM +0300, Vladimir Davydov wrote:
> > On Mon, Feb 23, 2015 at 11:12:22AM -0500, Konrad Rzeszutek Wilk wrote:
> > > Thank you for posting these patches. I was wondering if you had
> > > run through some of the different combinations that you can
> > > load the filesystems/tmem drivers in random order? The #4 patch
> > > deleted a nice chunk of documentation that outlines the different
> > > combinations.
> > 
> > Yeah, I admit the synchronization between cleancache_register_ops and
> > cleancache_init_fs is far not obvious. I should have updated the comment
> > instead of merely dropping it, sorry. What about the following patch
> > proving correctness of register_ops-vs-init_fs synchronization? It is
> > meant to be applied incrementally on top of patch #4.
> 
> Just fold it in please. But more importantly - I was wondering if you
> had run throught the different combinations it outlines?

Ah, you mean testing - I misunderstood you at first, sorry.

Of course, I checked that a cleancache backend module works fine no
matter if it is loaded before or after a filesystem is mounted. However,
I used our own cleancache driver for testing (we are trying to use
cleancache for containers).

To be 100% sure that I did not occasionally break anything, today I
installed XenServer on my test machine, enabled tmem both in dom0 and
domU, and ran through all possible sequences of tmem load vs fs
mount/use/unmount described in the old comment.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
