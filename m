Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7F74C43218
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 08:41:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 99A91208E3
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 08:41:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kzGBZj5q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 99A91208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36D306B0005; Tue, 11 Jun 2019 04:41:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31C3E6B0006; Tue, 11 Jun 2019 04:41:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E3AC6B0007; Tue, 11 Jun 2019 04:41:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id EACC76B0005
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 04:41:56 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id u200so3766369oia.23
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 01:41:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=v59RXEncklQZD+fQgfPPSwKXWN+Shli8ceMKKuyEhf0=;
        b=GV5pNiC/x6nb8JFx+NbDB3wt8NiwO7lweu6qllRO/CQw4DK60k3cDjNuLhxPOAopqa
         zA+NQLHxVSlwcM6vEis/PYEkIBsKIn54BjI6Dx7uY6m4q1T3+8sZTXMfQ6DQBUIpO7LE
         Lugvp3QfQFLdP2tiV+pBbrGMx3IC/bzSPvxodCSmitrtELZpwTtT0ooSs3ntPsBfimPn
         xjDdxDsivjzMe/4dgNmX0Ik9M0kHpQ7/FPoaLLJXDgyDtB1npu9WLPVp6OBEHPMnlkT2
         1kzDPGTwTUiHfhdgxbMqnYc/eL/UogksgVef+JxEb1osSeLcbhhTWUDiGnxsVorJKPb7
         vcBQ==
X-Gm-Message-State: APjAAAWLu7l6IFdTOImRuBo9jdre4dOH8duF4F974mCfCxxbBSu6VxI2
	L7FgBrMBVNctdWRvENzovJ8Iao25yWp5QKIUtWC3e5wSKddxv7q4So2JNtf2jSoBsqtCNULXVLH
	oT0CtReTDMILEKUV8g7o2kyT9KoF9Pw/K5gsk/TrDfKOBkmxthUnwRTYsu+V8dKUoEg==
X-Received: by 2002:a05:6830:1250:: with SMTP id s16mr7845947otp.158.1560242516416;
        Tue, 11 Jun 2019 01:41:56 -0700 (PDT)
X-Received: by 2002:a05:6830:1250:: with SMTP id s16mr7845918otp.158.1560242515467;
        Tue, 11 Jun 2019 01:41:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560242515; cv=none;
        d=google.com; s=arc-20160816;
        b=X+SZRuFAeWziX4es1Oy+myOzebE4UlpMnVLb20U7jkQh9a+fSgscpMCEf6m5s8xvbk
         32kEwdALHplS+VV3+0BrdxGRkRuRquYMJiW1/aEY35SAaChHPRmsexnv7ktwYoN4284u
         0cKdfhQUcNfDVvd8aXAUNJROdTd0S6rS4qDzDxV/PY8fFJZ9t29e1u4dJEiIzPRh9c/3
         Phu5MGIxa4EmgxbNRzCHY68zqfE5VFedv3q++wqn0sukVgIkqjit4cEZumaoY5Upr3a5
         hTXvPsn4Abg8m7yUi0ub4PTT+3yqdy7g1IvTBEnMH0ObqF7mfntyfU6EmCuxcFYa44kK
         wFHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=v59RXEncklQZD+fQgfPPSwKXWN+Shli8ceMKKuyEhf0=;
        b=SRKbOEiHPxtsQpuyBbPYhqHJX387+kCjS6Hz7HhTmiUhF0we6fcKctz+1biT8XxFpZ
         oBfkG/DxS5gBB00uX9H+r1K9sui8WfNtbZwM1LipCn5jTiKvkH1IdXqkmM7O9is0a9PR
         /4/D4fHtfBtAcpojMwPpix8aFEPie3S2L24fBv9BIyH0l9XhvbAv0rZ6UVFiI0dafKKh
         q5qqj2XsJ0jt/vDMba4AZdSAQ7Wa5qysfzDZHblkn5PDnks/O1LeYBniomAL/uMeTpy1
         sFOs8oUbzpQPl3V67iQdCS2026tbVoOlVrDskfdqlXIk0LO/GJGyFZSwYWTddGnuM9pi
         sBKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kzGBZj5q;
       spf=pass (google.com: domain of kernellwp@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernellwp@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o9sor4689531oif.125.2019.06.11.01.41.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Jun 2019 01:41:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernellwp@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kzGBZj5q;
       spf=pass (google.com: domain of kernellwp@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernellwp@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=v59RXEncklQZD+fQgfPPSwKXWN+Shli8ceMKKuyEhf0=;
        b=kzGBZj5q2XeUUnNn+hZIDQ46zIbc4pi+XhZMT9xquzmAl0mAoe/hTW/h4vI3GliFyD
         mXnvOXJl3RpDm9VgZWAEm2w4h2wvu0g8FX8kQbFB14i2xbEtTzS3nJtZ+sTfGYQIY7+0
         fIiRu2bpFatZkFK7tl+5xmNIkNo/0+aWiQUyy2ZQR3G9TgPGLCkyGRfd2GVcmdAQbwoT
         dIDnLEETDOW7qbBihciICLYyBxd0Jaymx3fytdeRwx3hC4H742XJmZ0riceYpBoyKeEr
         FYpmZBWZz3MUPy3Acp87PhKrT92mbXGGfNVFAVpX35lGvFuc9uJG/ZKYUADeNkYNr+wB
         zEXw==
X-Google-Smtp-Source: APXvYqzxaOZ9KUV/kRDM8l0u6+E8suUMaqGg0qPMAJRT6KRoeygwlTXcCyHIDf4inVwolTl02OcElY+Wfcd/PVxQ3Ig=
X-Received: by 2002:aca:3305:: with SMTP id z5mr12702145oiz.141.1560242515130;
 Tue, 11 Jun 2019 01:41:55 -0700 (PDT)
MIME-Version: 1.0
References: <20180130013919.GA19959@hori1.linux.bs1.fc.nec.co.jp>
 <1517284444-18149-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <87inbbjx2w.fsf@e105922-lin.cambridge.arm.com> <20180207011455.GA15214@hori1.linux.bs1.fc.nec.co.jp>
 <87fu6bfytm.fsf@e105922-lin.cambridge.arm.com> <20180208121749.0ac09af2b5a143106f339f55@linux-foundation.org>
 <87wozhvc49.fsf@concordia.ellerman.id.au> <e673f38a-9e5f-21f6-421b-b3cb4ff02e91@oracle.com>
 <CANRm+CxAgWVv5aVzQ0wdP_A7QQgqfy7nN_SxyaactG7Mnqfr2A@mail.gmail.com>
 <f79d828c-b0b4-8a20-c316-a13430cfb13c@oracle.com> <20190610235045.GB30991@hori.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20190610235045.GB30991@hori.linux.bs1.fc.nec.co.jp>
From: Wanpeng Li <kernellwp@gmail.com>
Date: Tue, 11 Jun 2019 16:42:39 +0800
Message-ID: <CANRm+Cy80ca6XC3c1CT0KzX=xi3g3nMEp5GxmhOH-CUZa-jM_g@mail.gmail.com>
Subject: Re: [PATCH v2] mm: hwpoison: disable memory error handling on 1GB hugepage
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, 
	Andrew Morton <akpm@linux-foundation.org>, Punit Agrawal <punit.agrawal@arm.com>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, 
	"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, 
	Anshuman Khandual <khandual@linux.vnet.ibm.com>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, 
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, kvm <kvm@vger.kernel.org>, 
	Paolo Bonzini <pbonzini@redhat.com>, Xiao Guangrong <xiaoguangrong@tencent.com>, 
	"lidongchen@tencent.com" <lidongchen@tencent.com>, "yongkaiwu@tencent.com" <yongkaiwu@tencent.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 11 Jun 2019 at 07:51, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
>
> On Wed, May 29, 2019 at 04:31:01PM -0700, Mike Kravetz wrote:
> > On 5/28/19 2:49 AM, Wanpeng Li wrote:
> > > Cc Paolo,
> > > Hi all,
> > > On Wed, 14 Feb 2018 at 06:34, Mike Kravetz <mike.kravetz@oracle.com> wrote:
> > >>
> > >> On 02/12/2018 06:48 PM, Michael Ellerman wrote:
> > >>> Andrew Morton <akpm@linux-foundation.org> writes:
> > >>>
> > >>>> On Thu, 08 Feb 2018 12:30:45 +0000 Punit Agrawal <punit.agrawal@arm.com> wrote:
> > >>>>
> > >>>>>>
> > >>>>>> So I don't think that the above test result means that errors are properly
> > >>>>>> handled, and the proposed patch should help for arm64.
> > >>>>>
> > >>>>> Although, the deviation of pud_huge() avoids a kernel crash the code
> > >>>>> would be easier to maintain and reason about if arm64 helpers are
> > >>>>> consistent with expectations by core code.
> > >>>>>
> > >>>>> I'll look to update the arm64 helpers once this patch gets merged. But
> > >>>>> it would be helpful if there was a clear expression of semantics for
> > >>>>> pud_huge() for various cases. Is there any version that can be used as
> > >>>>> reference?
> > >>>>
> > >>>> Is that an ack or tested-by?
> > >>>>
> > >>>> Mike keeps plaintively asking the powerpc developers to take a look,
> > >>>> but they remain steadfastly in hiding.
> > >>>
> > >>> Cc'ing linuxppc-dev is always a good idea :)
> > >>>
> > >>
> > >> Thanks Michael,
> > >>
> > >> I was mostly concerned about use cases for soft/hard offline of huge pages
> > >> larger than PMD_SIZE on powerpc.  I know that powerpc supports PGD_SIZE
> > >> huge pages, and soft/hard offline support was specifically added for this.
> > >> See, 94310cbcaa3c "mm/madvise: enable (soft|hard) offline of HugeTLB pages
> > >> at PGD level"
> > >>
> > >> This patch will disable that functionality.  So, at a minimum this is a
> > >> 'heads up'.  If there are actual use cases that depend on this, then more
> > >> work/discussions will need to happen.  From the e-mail thread on PGD_SIZE
> > >> support, I can not tell if there is a real use case or this is just a
> > >> 'nice to have'.
> > >
> > > 1GB hugetlbfs pages are used by DPDK and VMs in cloud deployment, we
> > > encounter gup_pud_range() panic several times in product environment.
> > > Is there any plan to reenable and fix arch codes?
> >
> > I too am aware of slightly more interest in 1G huge pages.  Suspect that as
> > Intel MMU capacity increases to handle more TLB entries there will be more
> > and more interest.
> >
> > Personally, I am not looking at this issue.  Perhaps Naoya will comment as
> > he know most about this code.
>
> Thanks for forwarding this to me, I'm feeling that memory error handling
> on 1GB hugepage is demanded as real use case.
>
> >
> > > In addition, https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/arch/x86/kvm/mmu.c#n3213
> > > The memory in guest can be 1GB/2MB/4K, though the host-backed memory
> > > are 1GB hugetlbfs pages, after above PUD panic is fixed,
> > > try_to_unmap() which is called in MCA recovery path will mark the PUD
> > > hwpoison entry. The guest will vmexit and retry endlessly when
> > > accessing any memory in the guest which is backed by this 1GB poisoned
> > > hugetlbfs page. We have a plan to split this 1GB hugetblfs page by 2MB
> > > hugetlbfs pages/4KB pages, maybe file remap to a virtual address range
> > > which is 2MB/4KB page granularity, also split the KVM MMU 1GB SPTE
> > > into 2MB/4KB and mark the offensive SPTE w/ a hwpoison flag, a sigbus
> > > will be delivered to VM at page fault next time for the offensive
> > > SPTE. Is this proposal acceptable?
> >
> > I am not sure of the error handling design, but this does sound reasonable.
>
> I agree that that's better.
>
> > That block of code which potentially dissolves a huge page on memory error
> > is hard to understand and I'm not sure if that is even the 'normal'
> > functionality.  Certainly, we would hate to waste/poison an entire 1G page
> > for an error on a small subsection.
>
> Yes, that's not practical, so we need at first establish the code base for
> 2GB hugetlb splitting and then extending it to 1GB next.

I'm working on this, thanks for the inputs.

Regards,
Wanpeng Li

