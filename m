Return-Path: <SRS0=tSF5=RI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28F3FC43381
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 17:47:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C0F4420842
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 17:47:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="p2Y8hdNn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0F4420842
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 350968E0003; Tue,  5 Mar 2019 12:47:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D7EA8E0001; Tue,  5 Mar 2019 12:47:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 179B78E0003; Tue,  5 Mar 2019 12:47:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C4FD98E0001
	for <linux-mm@kvack.org>; Tue,  5 Mar 2019 12:47:50 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id d5so10177085pfo.5
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 09:47:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=gHJM1QM5EJjUOY2FDdaKsqaFOXK3eKenoExJbNcqN4g=;
        b=Dob5UDBXwIOoTzWHQfS4pGNS5uFXRfn04piWsQra0ckEE5GBnPM6AJF9ipa+byK/AL
         Z9W1CpEI2QES7m2TpWFgScSPVtMw3gLG9/4sP6J+SaQGjlhiFN7Isc9iBZdX37SKt+qz
         YbHzgj3KJa8QXycxDH6xLyRF51TSGHbR56mqEO1LMh4lXNVjL0eoQodg5aWWHK6XfH9V
         YCR9MDyR/eDGDmBQcJ0jJV5jIDbjTL73HwKLe8r9cxsuib/Ra3PeBYAHHMyjcEsfOJNJ
         IDS47CpXN2jvMwWeEP9t+KMAw/IxPI0vy6MoYRiyWRQGuvW5XZk7tpnImQHAyNbV3Hc8
         w1+Q==
X-Gm-Message-State: APjAAAXiVtqbNbj0TGkFTn8OE4uI+UFfmOaBIom7rGUjHZpn3p90lqUC
	D27/WVlzjz9DsS9ysK4dHb6BeYn39Br6NjSDZjHrdtsmfx5w8VJlMcFRSi6sbs9HhrFeb8cWLG4
	R6ISdx/+0MOtQoqDyzKxpPp5N3+kecrgF/WF0Gkktj2/NInc/PkAZJs499LDenEfzOpn7m2hBSu
	6lQ9aSWyTNdBSU9mGRxdjPmPq+4+Hd9jdjKWP3Go4sPPtXTfGqFcwhA5c0gPukJs4JGrV+ecmvv
	vg7dGLkZvLux3SyEqglBlMVst3H2I+oViMn1YpSF+AjZ+U0AWwzUG2aFjdlnV5Tr2ixi2B33Y7U
	2Ym9BupMc/xoj+s6YeQuDi0LqKGP8HuaVMnnBQu5Xsj9DxEDhPXPUDddb9N2in+mQ+cMLPdDdzm
	P
X-Received: by 2002:a17:902:846:: with SMTP id 64mr2396565plk.266.1551808070295;
        Tue, 05 Mar 2019 09:47:50 -0800 (PST)
X-Received: by 2002:a17:902:846:: with SMTP id 64mr2396491plk.266.1551808069103;
        Tue, 05 Mar 2019 09:47:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551808069; cv=none;
        d=google.com; s=arc-20160816;
        b=m65fIwbdFb1o3/cUgvxRommVnRhWpkCag+D4WxKuJNywQYjClQfNwaL7kF4XBpvycW
         gNUXLlKCA+noLquutQ49NmHBKiAx0t40TbFVPutlaXaP/nRWkXrV30NGuSqFA9ErA4H7
         Dc3b7QT08o0CmckWC7EUfOUIURTwl9C7m2yYaBcMztmijCZI8WJGeu2Ksr72zqUq+g7H
         NvIkxcd850PUrv7ttBHiKXeAFg0mIRf2uAddpvkXJcymS/qk2Kztht4PO0wah0Lc8tvC
         oi/g3qFuoGoO0UIhqgR3QQGwC+kJ0MgQfqwG4K5UHKWq4ox2J0BqBE44MewNzpTgaT3K
         TV1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=gHJM1QM5EJjUOY2FDdaKsqaFOXK3eKenoExJbNcqN4g=;
        b=FfHIYv2XyMAvHMtnYBxhg9sT/hy1ZPh2SBCqizNaa3/rWt9KVTm6qzd1P0K5LiRIEn
         9Yq1Bw1m5Cz4khL74UaW5/fmN7jGs6OVPTJ9AaSw/O0Py8FrA760kKeq2M5cb9oL/Voo
         4Z6YPYoxU3ybYhArWT38UKiUpCQ3ufn2fChhzCXNzBZmDXv6aK0BXxQqmOjH2Be0ko9C
         9B3rRyAD44Mfl3HJAuEK5VFQeKdYcnPSzKNhycHxu2EqT1m0iX7GB1mxkl4ZbyAQusZg
         NLfZp+r6yzYQygv0fKkuvLdHV6Ox4qRlibW3KHXO620D6Mhhaor3o5CgFUAS1RhSQldA
         hB3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=p2Y8hdNn;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h128sor14462726pgc.33.2019.03.05.09.47.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Mar 2019 09:47:49 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=p2Y8hdNn;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=gHJM1QM5EJjUOY2FDdaKsqaFOXK3eKenoExJbNcqN4g=;
        b=p2Y8hdNnqthiWdPWaqmFy7b/8k5R5/BmM19TtexhhrWTduZyd1hXY4SAlsKdKjdcPI
         sat72+hX+ZkqOFLb8LdG6frRV2OtpqnIvtHde17vUlUIvR5ceD/KeoyIS1GlzP+N5xK/
         u9EerRuH/goJiFrHsvZzQvnJBSrIj70uKlg5qfpjpHnK+3pQf5iWM67T1SrG4ybBTvVt
         nLxM02ayT0Y0fMLUulujQe30SOR0DSgftsFb1H6mDwY74OgZRJx4phYor6WZSVxbIsDK
         myhDVYqAdqOKhriLkvtPoMwKzAS1kM6d+LD+r4uhhuiNhJStX3Y7uIGJ0qshrYteS8OD
         MDIw==
X-Google-Smtp-Source: APXvYqwDj3NnoGrQ2kCWYrAH9v9f6KsnKIVl5PHMyojxupslR+Vg36DkEhtUHfsEu9xerxBBdBjMih96qnmG5qP52o4=
X-Received: by 2002:a65:6651:: with SMTP id z17mr2299629pgv.95.1551808068440;
 Tue, 05 Mar 2019 09:47:48 -0800 (PST)
MIME-Version: 1.0
References: <cover.1550839937.git.andreyknvl@google.com> <8343cd77ca301df15839796f3b446b75ce5ffbbf.1550839937.git.andreyknvl@google.com>
 <73f2f3fe-9a66-22a1-5aae-c282779a75f5@intel.com> <CAAeHK+yQU8khtOoyDKqmHterCa16P7oWe9AMiPnrxE+Gyb_7aw@mail.gmail.com>
 <20190301165908.GA130541@arrakis.emea.arm.com> <fb721f0b-fad7-2310-4f17-8bf046413d40@intel.com>
In-Reply-To: <fb721f0b-fad7-2310-4f17-8bf046413d40@intel.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 5 Mar 2019 18:47:37 +0100
Message-ID: <CAAeHK+ydurtkoVtvyoQdfcXuR3ZnZ+=ixoZkXEFRTZARg+GtRQ@mail.gmail.com>
Subject: Re: [PATCH v10 07/12] fs, arm64: untag user pointers in fs/userfaultfd.c
To: Dave Hansen <dave.hansen@intel.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 1, 2019 at 7:37 PM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 3/1/19 8:59 AM, Catalin Marinas wrote:
> >>> So, we have to patch all these sites before the tagged values get to the
> >>> point of hitting the vma lookup functions.  Dumb question: Why don't we
> >>> just patch the vma lookup functions themselves instead of all of these
> >>> callers?
> >> That might be a working approach as well. We'll still need to fix up
> >> places where the vma fields are accessed directly. Catalin, what do
> >> you think?
> > Most callers of find_vma*() always follow it by a check of
> > vma->vma_start against some tagged address ('end' in the
> > userfaultfd_(un)register()) case. So it's not sufficient to untag it in
> > find_vma().
>
> If that's truly the common case, sounds like we should have a find_vma()
> that does the vma_end checking as well.  Then at least the common case
> would not have to worry about tagging.

It seems that a lot of find_vma() callers indeed do different kinds of
checking/subtractions of vma->vma_start and a tagged address, which
look hardly unifiable. So untagging the addresses in find_vma()
callers looks like a more suitable solution.

