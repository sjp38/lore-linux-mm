Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id BD8846B0031
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 22:23:44 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id r10so478018pdi.41
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 19:23:44 -0700 (PDT)
Date: Thu, 26 Sep 2013 10:23:10 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [munlock] BUG: Bad page map in process killall5 pte:cf17e720
 pmd:05a22067
Message-ID: <20130926022310.GA12047@localhost>
References: <20130926004028.GB9394@localhost>
 <52439258.3010904@oracle.com>
 <20130926015924.GA10453@localhost>
 <CAA_GA1frX9rCc8i=8nJFLu+BTPjTP6ZkEvGdMph4TXqH0_yaDg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA_GA1frX9rCc8i=8nJFLu+BTPjTP6ZkEvGdMph4TXqH0_yaDg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Bob Liu <bob.liu@oracle.com>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Thu, Sep 26, 2013 at 10:17:59AM +0800, Bob Liu wrote:
> On Thu, Sep 26, 2013 at 9:59 AM, Fengguang Wu <fengguang.wu@intel.com> wrote:
> > Hi Bob,
> >
> > On Thu, Sep 26, 2013 at 09:48:08AM +0800, Bob Liu wrote:
> >> Hi Fengguang,
> >>
> >> Would you please have a try with the attached patch?
> >> It added a small fix based on Vlastimil's patch.
> >
> > Thanks for the quick response! I just noticed Andrew added this patch
> > to -mm tree:
> >
> > ------------------------------------------------------
> > From: Vlastimil Babka <vbabka@suse.cz>
> > Subject: mm/mlock.c: prevent walking off the end of a pagetable in no-pmd configuration
> >
> > What's the git tree your v2 patch based on? If you already had a git
> 
> It's based on v3.12-rc1.  Should I send you a new one based on latest mmotm?

Not necessary for now. However it'd be good to know whether Vlastimil
has reviewed your v2 fix.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
