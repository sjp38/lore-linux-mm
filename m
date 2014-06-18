Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 2FBF56B0036
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 16:51:47 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id md12so1124920pbc.17
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 13:51:46 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id tz6si3331632pbc.165.2014.06.18.13.51.45
        for <linux-mm@kvack.org>;
        Wed, 18 Jun 2014 13:51:46 -0700 (PDT)
Date: Wed, 18 Jun 2014 13:51:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 -next 0/9] CMA: generalize CMA reserved area
 management code
Message-Id: <20140618135144.297c785260f9e2aebead867c@linux-foundation.org>
In-Reply-To: <20140617012507.GA6825@js1304-P5Q-DELUXE>
References: <1402897251-23639-1-git-send-email-iamjoonsoo.kim@lge.com>
	<539EB4C7.3080106@samsung.com>
	<20140617012507.GA6825@js1304-P5Q-DELUXE>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Tue, 17 Jun 2014 10:25:07 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> > >v2:
> > >   - Although this patchset looks very different with v1, the end result,
> > >   that is, mm/cma.c is same with v1's one. So I carry Ack to patch 6-7.
> > >
> > >This patchset is based on linux-next 20140610.
> > 
> > Thanks for taking care of this. I will test it with my setup and if
> > everything goes well, I will take it to my -next tree. If any branch
> > is required for anyone to continue his works on top of those patches,
> > let me know, I will also prepare it.
> 
> Hello,
> 
> I'm glad to hear that. :)
> But, there is one concern. As you already know, I am preparing further
> patches (Aggressively allocate the pages on CMA reserved memory). It
> may be highly related to MM branch and also slightly depends on this CMA
> changes. In this case, what is the best strategy to merge this
> patchset? IMHO, Anrew's tree is more appropriate branch. If there is
> no issue in this case, I am willing to develope further patches based
> on your tree.

That's probably easier.  Marek, I'll merge these into -mm (and hence
-next and git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git)
and shall hold them pending you review/ack/test/etc, OK?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
