Return-Path: <SRS0=GxOJ=TZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4DF17C46460
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 18:09:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E2C57216E3
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 18:09:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="B28z101M"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E2C57216E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 56BB26B0003; Sat, 25 May 2019 14:09:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51C2F6B0005; Sat, 25 May 2019 14:09:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 40B7F6B0007; Sat, 25 May 2019 14:09:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 13AC36B0003
	for <linux-mm@kvack.org>; Sat, 25 May 2019 14:09:21 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id f30so4522450oij.3
        for <linux-mm@kvack.org>; Sat, 25 May 2019 11:09:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=rFgOoMr190otbVvdh7Sjz5mXZ2cf+5wMmXCKsssM39U=;
        b=lt6QEl+85oIX3HTz1WiZlxuIQJD13k5BkVi2/r3cdn/C3SuVHWhyjhUrjispTlAyvT
         +YOpzLyme/S5CGBbP5f1TyvT+J3e3ezfSrkrjRyzqXh57W4ahMEJJqD2rxaKE1h6Zt10
         4khRyJUJHbMk1g3SbUkE4Cvdam01RXdxYcUvAh453ZqUvKGSIQ7idP385iC+yKyvliWQ
         BAZE+jvdibFV+4ayeKLVvPm9/yfYqFrxiX3W2iIGdOwblJxrNbpiMUf66eEm5CgrBwXs
         +FPivC/G+UjXnbS/ohG3uTU4cbWXkMPSyfEIbFHJ6zbXoMTWZf9+9AF1rkrnLMz1p6pL
         LblQ==
X-Gm-Message-State: APjAAAX6RufOk3r6VF7RpQbcDPtKP6waXwGGPEarQ75eMyci6vE7Bovy
	BxGYGCc1VSkfBvqkIZ/zCGRV9GCyege3ityUVNlKORbjz3aSBBdStjQRssqh1tXg/81wM+abKVe
	Be9xk0HipL7pKktP5hGzNeJfgT6etamEgbwtavHRgOMTDZDNhHd08xMSwPvtZf7+wGw==
X-Received: by 2002:a9d:71d1:: with SMTP id z17mr40654619otj.22.1558807760690;
        Sat, 25 May 2019 11:09:20 -0700 (PDT)
X-Received: by 2002:a9d:71d1:: with SMTP id z17mr40654560otj.22.1558807759778;
        Sat, 25 May 2019 11:09:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558807759; cv=none;
        d=google.com; s=arc-20160816;
        b=O1E2yCpHQgDL1AuCUuCUMbORequfYkRDd2lZEDQL89hr1PktT91iwSB5UceeJXOCt9
         oODWFvAb+egsUiw4maU/p/iOerhh9A4VFz1J6mD9KiHfiR+XITaX+MMlBbp36kOnerdZ
         gAVmjFGrB1AgUclqpNUtbLUdXqYw5RFgkIk5LFvY1zeuAdlrLVGWZvhh/mWA87jGOniR
         MiLDFY6opTQ5Rocd9LHbUTdQovlPtaLw7p4C4zKnwRdkTighEn1R89JMidBqGxEZ3v+D
         f6/yHLSpYPOf1Dc5xW02SToMS2kw4olfuviJO1EPkb5KKNeHyfXvXZehPoWohjOtrrXP
         kbYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=rFgOoMr190otbVvdh7Sjz5mXZ2cf+5wMmXCKsssM39U=;
        b=B0HirVhOk3E97Ac7jBCUvzToPXuzkFs7Iyhiyr1h9fO3N5IbvKEn5JbrFfPwcx1g9T
         c1hm6p0qPgJhe6JQHvg6qaamoEIe5KpUr+qsULrHnjIF9ZBRidvBwWPzZTv8w8qM1jgv
         Zd3fPVRtg7GKs0/yWgL9cOsv0/cvOCQFU6rezHD2upzFhtpfmOx3LyMT4dgB5QkW7PHU
         KWcmxVi1t0IB9VJCjcjH+Ycj6gLt56Fj5hl61uOMkfbD8qLLRKa8+Kx1QT2BpNVvYkbn
         yYGPX3Ck1BHRaCp/fKIf6WnL4UdKxlCPIt6jTaTTFSrUNbwlqL477laosWi5TBQfbc6/
         7UWw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=B28z101M;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i16sor2769469ota.142.2019.05.25.11.09.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 25 May 2019 11:09:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=B28z101M;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=rFgOoMr190otbVvdh7Sjz5mXZ2cf+5wMmXCKsssM39U=;
        b=B28z101MMb+xz5ZuNz32ZuUK400uyAbJBivZiOA8Ofss6C9wnz+t8aMAIY6qnP6Y/I
         P54tSGwQ1vux1+VjpZ4y98ugvd/Eu0/gtBhIPrMTfDUvHFQF2X+iuKxPXQa8FZQRNTni
         +ScKBaPz28JBqoQlc7xdrZMUM9Ww6A3FqoWXemzaPoEG39IvwPAl4IwKlliTRK/9Noz2
         KO6hQubO8lSixzp/98fTUR4SAY9Ng1h0Ml/60gSb1ifOHIVmSF/dlf36quAIYfgCRVC6
         t/byTjyZDPpqdU9nLdy+Tjqwviescps0rKHMYcj89Ewxhr/A4ttctv6pECjWvVgdgw0m
         aPgw==
X-Google-Smtp-Source: APXvYqztKqxbD7Ywnn+rPPPQ3SnRUYAxabnSeTaKypF4Rdw++p7KkbtL+Op+f9Wc+EjZOoaAvNXy7w==
X-Received: by 2002:a9d:69c8:: with SMTP id v8mr12339129oto.6.1558807759055;
        Sat, 25 May 2019 11:09:19 -0700 (PDT)
Received: from eggly.attlocal.net (172-10-233-147.lightspeed.sntcca.sbcglobal.net. [172.10.233.147])
        by smtp.gmail.com with ESMTPSA id x91sm2377705otb.10.2019.05.25.11.09.17
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 25 May 2019 11:09:17 -0700 (PDT)
Date: Sat, 25 May 2019 11:09:15 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
    Mike Rapoport <rppt@linux.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
    Borislav Petkov <bp@suse.de>, Pavel Machek <pavel@ucw.cz>, 
    Dave Hansen <dave.hansen@linux.intel.com>
Subject: Re: [PATCH] mm/gup: continue VM_FAULT_RETRY processing event for
 pre-faults
In-Reply-To: <20190525084546.fap2wkefepeia22f@linutronix.de>
Message-ID: <alpine.LSU.2.11.1905251033230.1112@eggly.anvils>
References: <1557844195-18882-1-git-send-email-rppt@linux.ibm.com> <20190522122113.a2edc8aba32f0fad189bae21@linux-foundation.org> <20190522194322.5k52docwgp5zkdcj@linutronix.de> <alpine.LSU.2.11.1905241429460.1141@eggly.anvils>
 <20190525084546.fap2wkefepeia22f@linutronix.de>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 25 May 2019, Sebastian Andrzej Siewior wrote:
> On 2019-05-24 15:22:51 [-0700], Hugh Dickins wrote:
> > I've now run a couple of hours of load successfully with Mike's patch
> > to GUP, no problem; but whatever the merits of that patch in general,
> > I agree with Andrew that fault_in_pages_writeable() seems altogether
> > more appropriate for copy_fpstate_to_sigframe(), and have now run a
> > couple of hours of load successfully with this instead (rewrite to taste):
> 
> so this patch instead of Mike's GUP patch fixes the issue you observed?

Yes.

> Is this just a taste question or limitation of the function in general?

I'd say it's just a taste question. Though the the fact that your
usage showed up a bug in the get_user_pages_unlocked() implementation,
demanding a fix, does indicate that it's a more fragile and complex
route, better avoided if there's a good simple alternative. If it were
not already on your slowpath, I'd also argue fault_in_pages_writeable()
is a more efficient way to do it.

> 
> I'm asking because it has been suggested and is used in MPX code (in the
> signal path but .mmap) and I'm not aware of any limitation. But as I
> wrote earlier to akpm, if the MM folks suggest to use this instead I am
> happy to switch.

I know nothing of MPX, beyond that Dave Hansen has posted patches to
remove that support entirely, so I'm surprised arch/x86/mm/mpx.c is
still in the tree. But peering at it now, it looks as if it's using
get_user_pages() while holding mmap_sem, whereas you (sensibly enough)
used get_user_pages_unlocked() to handle the mmap_sem for you -
the trouble with that is that since it knows it's in control of
mmap_sem, it feels free to drop it internally, and that takes it
down the path of the premature return when pages NULL that Mike is
fixing. MPX's get_user_pages() is not free to go that way.

> 
> > --- 5.2-rc1/arch/x86/kernel/fpu/signal.c
> > +++ linux/arch/x86/kernel/fpu/signal.c
> > @@ -3,6 +3,7 @@
> >   * FPU signal frame handling routines.
> >   */
> >  
> > +#include <linux/pagemap.h>
> >  #include <linux/compat.h>
> >  #include <linux/cpu.h>
> >  
> > @@ -189,15 +190,7 @@ retry:
> >  	fpregs_unlock();
> >  
> >  	if (ret) {
> > -		int aligned_size;
> > -		int nr_pages;
> > -
> > -		aligned_size = offset_in_page(buf_fx) + fpu_user_xstate_size;
> > -		nr_pages = DIV_ROUND_UP(aligned_size, PAGE_SIZE);
> > -
> > -		ret = get_user_pages_unlocked((unsigned long)buf_fx, nr_pages,
> > -					      NULL, FOLL_WRITE);
> > -		if (ret == nr_pages)
> > +		if (!fault_in_pages_writeable(buf_fx, fpu_user_xstate_size))
> >  			goto retry;
> >  		return -EFAULT;
> >  	}
> > 
> > (I did wonder whether there needs to be an access_ok() check on buf_fx;
> > but if so, then I think it would already have been needed before the
> > earlier copy_fpregs_to_sigframe(); but I didn't get deep enough into
> > that to be sure, nor into whether access_ok() check on buf covers buf_fx.)
> 
> There is an access_ok() at the begin of copy_fpregs_to_sigframe(). The
> memory is allocated from user's stack and there is (later) an
> access_ok() for the whole region (which can be more than the memory used
> by the FPU code).

Yes, but remember I know nothing of this FPU signal code, so I cannot
tell whether an access_ok(buf, size) is good enough to cover the range
of an access_ok(buf_fx, fpu_user_xstate_size).

Your "(later)" worries me a little - I hope you're not writing first
and checking the limits later; but what you're doing may be perfectly
correct, I'm just too far from understanding the details to say; but
raised the matter because (I think) get_user_pages_unlocked() would
entail an access_ok() check where fault_in_pages_writable() would not.

Hugh

