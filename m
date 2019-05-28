Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0D5FC072B1
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 09:49:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4BDA62075C
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 09:49:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Q7xG41YY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4BDA62075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C15266B0270; Tue, 28 May 2019 05:49:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BECCB6B0272; Tue, 28 May 2019 05:49:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B02F16B0273; Tue, 28 May 2019 05:49:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 88AAA6B0270
	for <linux-mm@kvack.org>; Tue, 28 May 2019 05:49:36 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id 72so10039872otv.23
        for <linux-mm@kvack.org>; Tue, 28 May 2019 02:49:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=KRi+/C+vm5cztpsXfUVeLkDOVPLB4aZqwygYNrBno1g=;
        b=Na67lWs5pYetTT3y4w6Cj/l5UzN5mBb7F5xcXopjclPsMMthGzqojiFMdXISA2OidY
         d+dXgmY6Acfy0HNeUtRtPvRbQ+E9BIYWWImDfbEx4NELt/unyvUH3ElyZyTPHWBIxYgT
         f0d1d402x0TVnrW+9dqXrZ5V6Q6P5ggiiNCi5mpm1ApkMYCYDpk1cEVsCWysS4syYZ/c
         a5IaBYVDXcz40ixbFAAzL6Jy9MBz4GmRZz3/ptRnhrNtTlp/z0PlvR/jvJqEUkJSSufp
         tua1M1DBXtR10rqvvyLYupoCn3zDYDh2cqXfJBulViWz3xdMlM1GnJjYXVFdN8ZazHFu
         KY+A==
X-Gm-Message-State: APjAAAWybzIST6wSz1CuMe9xaYbK4NxMEn5BDD25YdyzAUb+eLhG7i6C
	km6lGdNMR+Vjd4GIlGQ7bKPRDSv0zoKTradQdIP8IOV00epkkObAD4kwS2ry49wtbpnCkpScCwb
	Xs1bmMx6GEd+fPMFJRMzdUEllcw/zHplS0PcyEK+MmvI8ClAzdGufd7YkPTJ8HPpKNA==
X-Received: by 2002:a9d:6494:: with SMTP id g20mr36134669otl.195.1559036976207;
        Tue, 28 May 2019 02:49:36 -0700 (PDT)
X-Received: by 2002:a9d:6494:: with SMTP id g20mr36134640otl.195.1559036975529;
        Tue, 28 May 2019 02:49:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559036975; cv=none;
        d=google.com; s=arc-20160816;
        b=bIrrfayZ0k67kTQBpksFowhOHoHP0XIaW4aULkoS5mvQWSkrK1fCFFNlBHTqgpW7zU
         k4+nEc5PYW6HK69VHpm0J01IVWgUPY9rMaxpmu9Q5IFWdeJe1o4N6W+Qab+KXp1OMxux
         ybjSE7JXHnjXgNmvodnfD4Huak7kFo+peWK7lo/Se6oOFpaMxEOchGP2AhOke2d0UJmC
         77yYuA1sXt8VFJDLxY66ogOvohsOzFEZvtetCFJXT46cZbbnfMefMpawKMtX6f2kUyct
         MBv0yK6whgaFKQFG+33nqKvuCDKm3hc5Gitosus/CgogrqiwQAYKHK9xkfGhE2kJ1LG4
         CLNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=KRi+/C+vm5cztpsXfUVeLkDOVPLB4aZqwygYNrBno1g=;
        b=eCHa2ERTMn0aeCgeTmPAeelJ0+c5hBT/5QigeCxVrDwgD7YewSRy+Lzvoi10J/szgf
         8dkviD+gJjaT8yaEq824Fmvh5x3NmZu/xCU0qgrFBObJS+C9ztUEvy+P4pCv+dqz4U0K
         Wys3VztOVky+53c04o2C+BM0WC4683KVNVU9P/j8n+r6PoEV/7sWLga1wxsMm7Ji5kAU
         RoaF9aBLmd0kr3muJx47p5nobBAqqBZfFbgc+hWO9mYBhlC9kCBGQHu/d5+QwIQc5Dv9
         /U2qh5ZF9WbCn/dJZLZX/bSs3IHHZgowwb8syyKGlGDajLcm+z6K7NbR8xknLR8VuxjC
         pY0g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Q7xG41YY;
       spf=pass (google.com: domain of kernellwp@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernellwp@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i2sor5662788otk.46.2019.05.28.02.49.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 02:49:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernellwp@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Q7xG41YY;
       spf=pass (google.com: domain of kernellwp@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernellwp@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=KRi+/C+vm5cztpsXfUVeLkDOVPLB4aZqwygYNrBno1g=;
        b=Q7xG41YYF2ZmuxUb2X+ltjAzjeK7pLMfwEBHv5e2w+/MmZh8X55fZsTHT9XwciLR/E
         HuUQGjJdVYrVQVkKmY8LlYkvwBKwRNYDjTDClmfRqzoL4jelnRiuxN9nY1CE8DeXQjbm
         uW/8GSxTyhDXHpg7QNQnWu+TRA69AeqJj3mOkdLzAnVLLY34nt8Mg9u+dSa/lGR0mmQ4
         JccPa4WCrMn9BC8uWe+Ufn2UXLgq+ojI+X2vf7wEFZnM/T4hy5jvbyFK5zDSmHkFTTfN
         pCgwp28ud4+Ut+QR/L2fuLRGXw+t5nbiVMf95C2wK8bIYx/jRFcU5iAPGuqOXpmI0DZs
         PNfw==
X-Google-Smtp-Source: APXvYqycJLHbMUrxyQVmE6fOyNT7aMXGE36q+p+fIGphy4C5ccLTEuNFk0FznlB9kOMyYpFlF5BuYnw4Rhffeot+1ZY=
X-Received: by 2002:a9d:5a11:: with SMTP id v17mr17618810oth.254.1559036975223;
 Tue, 28 May 2019 02:49:35 -0700 (PDT)
MIME-Version: 1.0
References: <20180130013919.GA19959@hori1.linux.bs1.fc.nec.co.jp>
 <1517284444-18149-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <87inbbjx2w.fsf@e105922-lin.cambridge.arm.com> <20180207011455.GA15214@hori1.linux.bs1.fc.nec.co.jp>
 <87fu6bfytm.fsf@e105922-lin.cambridge.arm.com> <20180208121749.0ac09af2b5a143106f339f55@linux-foundation.org>
 <87wozhvc49.fsf@concordia.ellerman.id.au> <e673f38a-9e5f-21f6-421b-b3cb4ff02e91@oracle.com>
In-Reply-To: <e673f38a-9e5f-21f6-421b-b3cb4ff02e91@oracle.com>
From: Wanpeng Li <kernellwp@gmail.com>
Date: Tue, 28 May 2019 17:49:28 +0800
Message-ID: <CANRm+CxAgWVv5aVzQ0wdP_A7QQgqfy7nN_SxyaactG7Mnqfr2A@mail.gmail.com>
Subject: Re: [PATCH v2] mm: hwpoison: disable memory error handling on 1GB hugepage
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, 
	Punit Agrawal <punit.agrawal@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, 
	"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, 
	Anshuman Khandual <khandual@linux.vnet.ibm.com>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, 
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, kvm <kvm@vger.kernel.org>, 
	Paolo Bonzini <pbonzini@redhat.com>, Xiao Guangrong <xiaoguangrong@tencent.com>, lidongchen@tencent.com, 
	yongkaiwu@tencent.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Cc Paolo,
Hi all,
On Wed, 14 Feb 2018 at 06:34, Mike Kravetz <mike.kravetz@oracle.com> wrote:
>
> On 02/12/2018 06:48 PM, Michael Ellerman wrote:
> > Andrew Morton <akpm@linux-foundation.org> writes:
> >
> >> On Thu, 08 Feb 2018 12:30:45 +0000 Punit Agrawal <punit.agrawal@arm.com> wrote:
> >>
> >>>>
> >>>> So I don't think that the above test result means that errors are properly
> >>>> handled, and the proposed patch should help for arm64.
> >>>
> >>> Although, the deviation of pud_huge() avoids a kernel crash the code
> >>> would be easier to maintain and reason about if arm64 helpers are
> >>> consistent with expectations by core code.
> >>>
> >>> I'll look to update the arm64 helpers once this patch gets merged. But
> >>> it would be helpful if there was a clear expression of semantics for
> >>> pud_huge() for various cases. Is there any version that can be used as
> >>> reference?
> >>
> >> Is that an ack or tested-by?
> >>
> >> Mike keeps plaintively asking the powerpc developers to take a look,
> >> but they remain steadfastly in hiding.
> >
> > Cc'ing linuxppc-dev is always a good idea :)
> >
>
> Thanks Michael,
>
> I was mostly concerned about use cases for soft/hard offline of huge pages
> larger than PMD_SIZE on powerpc.  I know that powerpc supports PGD_SIZE
> huge pages, and soft/hard offline support was specifically added for this.
> See, 94310cbcaa3c "mm/madvise: enable (soft|hard) offline of HugeTLB pages
> at PGD level"
>
> This patch will disable that functionality.  So, at a minimum this is a
> 'heads up'.  If there are actual use cases that depend on this, then more
> work/discussions will need to happen.  From the e-mail thread on PGD_SIZE
> support, I can not tell if there is a real use case or this is just a
> 'nice to have'.

1GB hugetlbfs pages are used by DPDK and VMs in cloud deployment, we
encounter gup_pud_range() panic several times in product environment.
Is there any plan to reenable and fix arch codes?

In addition, https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kvm/mmu.c#n3213
The memory in guest can be 1GB/2MB/4K, though the host-backed memory
are 1GB hugetlbfs pages, after above PUD panic is fixed,
try_to_unmap() which is called in MCA recovery path will mark the PUD
hwpoison entry. The guest will vmexit and retry endlessly when
accessing any memory in the guest which is backed by this 1GB poisoned
hugetlbfs page. We have a plan to split this 1GB hugetblfs page by 2MB
hugetlbfs pages/4KB pages, maybe file remap to a virtual address range
which is 2MB/4KB page granularity, also split the KVM MMU 1GB SPTE
into 2MB/4KB and mark the offensive SPTE w/ a hwpoison flag, a sigbus
will be delivered to VM at page fault next time for the offensive
SPTE. Is this proposal acceptable?

Regards,
Wanpeng Li

