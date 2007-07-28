Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1IEnIw-00024F-5T
	for linux-mm@kvack.org; Sat, 28 Jul 2007 16:30:02 +0200
Received: from n219079086056.netvigator.com ([219.79.86.56])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Sat, 28 Jul 2007 16:30:02 +0200
Received: from gmane by n219079086056.netvigator.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Sat, 28 Jul 2007 16:30:02 +0200
From: Daniel Cheng <gmane@sdiz.net>
Subject: Re: -mm merge plans for 2.6.23
Date: Sat, 28 Jul 2007 11:42:43 +0800
Message-ID: <46AABB33.1080301@sdiz.net>
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>	<9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>	<46A57068.3070701@yahoo.com.au>	<2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>	<46A58B49.3050508@yahoo.com.au>	<2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>	<46A6CC56.6040307@yahoo.com.au> <46A6D7D2.4050708@gmail.com>	<1185341449.7105.53.camel@perkele> <46A6E1A1.4010508@yahoo.com.au>	<2c0942db0707250909r435fef75sa5cbf8b1c766000b@mail.gmail.com> <20070725215717.df1d2eea.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=Big5-HKSCS
Content-Transfer-Encoding: 7bit
In-Reply-To: <20070725215717.df1d2eea.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: ck@vds.kolivas.org, linux-kernel@vger.kernel.orglinux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
[...]
> 
> And userspace can do a much better implementation of this
> how-to-handle-large-load-shifts problem, because it is really quite
> complex.  The system needs to be monitored to determine what is the "usual"
[...]
> All this would end up needing runtime configurability and tweakability and
> customisability.  All standard fare for userspace stuff - much easier than
> patching the kernel.

But a patch already exist.
Which is easier: (1) apply the patch ; or (2) write a new patch?

> 
> So.  We can
> a) provide a way for userspace to reload pagecache and
> b) merge maps2 (once it's finished) (pokes mpm)
> and we're done?

might be.
but merging maps2 have higher risk which should be done in a development
branch (er... 2.7, but we don't have it now).

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
