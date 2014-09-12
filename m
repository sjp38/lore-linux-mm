Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 900336B0038
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 05:25:03 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id n3so243172wiv.1
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 02:25:03 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id bp7si6206623wjb.134.2014.09.12.02.25.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 12 Sep 2014 02:25:02 -0700 (PDT)
Date: Fri, 12 Sep 2014 11:24:49 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v8 08/10] x86, mpx: add prctl commands PR_MPX_REGISTER,
 PR_MPX_UNREGISTER
In-Reply-To: <alpine.DEB.2.10.1409120950260.4178@nanos>
Message-ID: <alpine.DEB.2.10.1409121120440.4178@nanos>
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com> <1410425210-24789-9-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.10.1409120020060.4178@nanos> <541239F1.2000508@intel.com> <alpine.DEB.2.10.1409120950260.4178@nanos>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Qiaowei Ren <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 12 Sep 2014, Thomas Gleixner wrote:
> On Thu, 11 Sep 2014, Dave Hansen wrote:
> > Well, we use it to figure out whether we _potentially_ need to tear down
> > an VM_MPX-flagged area.  There's no guarantee that there will be one.
> 
> So what you are saying is, that if user space sets the pointer to NULL
> via the unregister prctl, kernel can safely ignore vmas which have the
> VM_MPX flag set. I really can't follow that logic.
>  
> 	mmap_mpx();
> 	prctl(enable mpx);
> 	do lots of crap which uses mpx;
> 	prctl(disable mpx);
> 
> So after that point the previous use of MPX is irrelevant, just
> because we set a pointer to NULL? Does it just look like crap because
> I do not get the big picture how all of this is supposed to work?

do_bounds() will happily map new BTs no matter whether the prctl was
invoked or not. So what's the value of the prctl at all?

The mapping is flagged VM_MPX. Why is this not sufficient?

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
