Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16168C04AB7
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 15:24:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD04521473
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 15:24:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="eVCLg4/X"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD04521473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48D136B0005; Tue, 14 May 2019 11:24:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43DD56B0006; Tue, 14 May 2019 11:24:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32D6A6B0007; Tue, 14 May 2019 11:24:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id EC8A36B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 11:24:03 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id j36so11707819pgb.20
        for <linux-mm@kvack.org>; Tue, 14 May 2019 08:24:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=GoLz+QSqIyffgCrNMjUVAMh3xuEjh/l8T0RItu42FqQ=;
        b=qGR+Nd/ltQIz2G4hgt6CtSkb+Kw2kt6NW2f+0ybFooaLfkexkHpUDmFK/u2G5SQ2Fc
         43FgChhJVBnXIo0qaj2RJ4r+GQoPL16MhUo18Ofxoe/7vl7Kh4aKbDH00urZ8BSTy4t7
         qwpz1jpHSuoY2EJ1YylR7Ec30TCk40WLF+axYYfdPz2e4bYi7X+zTWpZqMg2RExNF4fJ
         5Jml8wY1PpubfidX7XK2wG75WxrYNMoULv5gSB1NimjcqLSDuI5F4g1qiGGiRI1nVCf6
         c7nyZH/EHEqSfAolQSfz4VBNQi6pLbbRRm7Bwhtxy8XLd2QojxvQDQKXvFLJXUQr9CF/
         74fA==
X-Gm-Message-State: APjAAAVMNvVKVEMlNRUZZtCMHmSdxbrxWdp5dV6EwburfzEpUQ/359fu
	+WZ/+kLZ7QKo1LRFfcf9f63Fur6qBfp3jbHLI2kwp85E6WuCe36RozxzxrcQ0sPszJFIY0jtMvv
	NvmgdQh09GCd71FLN8LBBNnrBHs3HZwSifRladaTwUG9FgKHWx5ufUgwXUzFLx6deIg==
X-Received: by 2002:a62:f247:: with SMTP id y7mr40960090pfl.18.1557847443390;
        Tue, 14 May 2019 08:24:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxvKaDTHiYbmKzTxWXPVbaWV9588YrDx7sLaT7yDIg/7/1h1YUm5KDmFigig0yf90l8GQZf
X-Received: by 2002:a62:f247:: with SMTP id y7mr40959985pfl.18.1557847442169;
        Tue, 14 May 2019 08:24:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557847442; cv=none;
        d=google.com; s=arc-20160816;
        b=sS6r766Sgc2RowSRaTDc0tCYpY1h1cRj9ZGiMGbglDtrq/b44mdONEQaCs5NRhF40o
         eUmj6isIEOcy31awfxbJW/Y0PcfhtAVmY4FEcFK5hUgo7uKs5S8OT5qeRwzGpZ9r0jb8
         oACBYEqFVxjV09Ed8uUhiRvp1i7EJTijcSMaJau3VHqfMg9FVMdF3xA9aBPsB/Bf2O+Q
         ZqfgjO30jMkrWyHtqJC/yKs3r6kP3uLtvUr32lAPm2Y1z587Ngew4fKM3/yu/g8GZ0hD
         ikajkDDE2IiHHzYM6T+UZUtdk29NsrlHM9wQeyyKn97XBZdcSAiLZzrZgVg92+9FnmCi
         MthQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=GoLz+QSqIyffgCrNMjUVAMh3xuEjh/l8T0RItu42FqQ=;
        b=Qqp9TVJxwwmBx9lp4n9P/1fUqRwWxBp1Dy5E0HeLItMU61ZEyQr2ucvALnzlFRtq2R
         0AA9fc3NOkzdLgwqsICCVHGHGuDLqET0qI6NuM92i7FAtJfhvtrHPMJqO8rkVG9S8tza
         OCRNoRi+ExqCEt2s2WYM65AovDk69BaFHkScCDABMF+QzevA42kdNaSb/SrN/9vcbR1C
         CSYC/mtLvhp8S5DkVoxUp2Vq3aeP/6L2CX9sTOVrwCvfBnZdHs3w4m5AdZmBEnw+Yr3c
         brZ+lGWejFBO+oqzP5tRjnKUrdlOj400x9GeNomQt4ku22DNKqm+dpb0T16YCxyBnU+N
         foHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="eVCLg4/X";
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p8si20445366plq.225.2019.05.14.08.24.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 08:24:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="eVCLg4/X";
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f51.google.com (mail-wr1-f51.google.com [209.85.221.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 57E12216B7
	for <linux-mm@kvack.org>; Tue, 14 May 2019 15:24:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557847441;
	bh=lEnwwmU1XbKwYI+07sS2BHHk1ukbBjXSFcW1oRTxeAo=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=eVCLg4/XxcMGOLsPFn6OR8b5+D0fSJ3C73EsiGv+ZP1UExvdsqIN8jEcRCYerQv8E
	 JiJQI0nJ+Wm5vH2G6Wc56NLBhB0dSfY8L+kVXyatxe3O+MvvIlYBmHROcAADcXdyMu
	 gmFnLgnQ5/GErDUj0tVtJM/DgF+Mw/f+QUS627hc=
Received: by mail-wr1-f51.google.com with SMTP id r7so1870553wrr.13
        for <linux-mm@kvack.org>; Tue, 14 May 2019 08:24:01 -0700 (PDT)
X-Received: by 2002:adf:ec42:: with SMTP id w2mr21163913wrn.77.1557847439920;
 Tue, 14 May 2019 08:23:59 -0700 (PDT)
MIME-Version: 1.0
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <1557758315-12667-19-git-send-email-alexandre.chartre@oracle.com>
 <CALCETrWUKZv=wdcnYjLrHDakamMBrJv48wp2XBxZsEmzuearRQ@mail.gmail.com>
 <20190514070941.GE2589@hirez.programming.kicks-ass.net> <b8487de1-83a8-2761-f4a6-26c583eba083@oracle.com>
 <B447B6E8-8CEF-46FF-9967-DFB2E00E55DB@amacapital.net> <4e7d52d7-d4d2-3008-b967-c40676ed15d2@oracle.com>
In-Reply-To: <4e7d52d7-d4d2-3008-b967-c40676ed15d2@oracle.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 14 May 2019 08:23:48 -0700
X-Gmail-Original-Message-ID: <CALCETrXtwksWniEjiWKgZWZAyYLDipuq+sQ449OvDKehJ3D-fg@mail.gmail.com>
Message-ID: <CALCETrXtwksWniEjiWKgZWZAyYLDipuq+sQ449OvDKehJ3D-fg@mail.gmail.com>
Subject: Re: [RFC KVM 18/27] kvm/isolation: function to copy page table
 entries for percpu buffer
To: Alexandre Chartre <alexandre.chartre@oracle.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, 
	Paolo Bonzini <pbonzini@redhat.com>, Radim Krcmar <rkrcmar@redhat.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
	"H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	kvm list <kvm@vger.kernel.org>, X86 ML <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, jan.setjeeilers@oracle.com, 
	Liran Alon <liran.alon@oracle.com>, Jonathan Adams <jwadams@google.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 14, 2019 at 2:42 AM Alexandre Chartre
<alexandre.chartre@oracle.com> wrote:
>
>
> On 5/14/19 10:34 AM, Andy Lutomirski wrote:
> >
> >
> >> On May 14, 2019, at 1:25 AM, Alexandre Chartre <alexandre.chartre@orac=
le.com> wrote:
> >>
> >>
> >>> On 5/14/19 9:09 AM, Peter Zijlstra wrote:
> >>>> On Mon, May 13, 2019 at 11:18:41AM -0700, Andy Lutomirski wrote:
> >>>> On Mon, May 13, 2019 at 7:39 AM Alexandre Chartre
> >>>> <alexandre.chartre@oracle.com> wrote:
> >>>>>
> >>>>> pcpu_base_addr is already mapped to the KVM address space, but this
> >>>>> represents the first percpu chunk. To access a per-cpu buffer not
> >>>>> allocated in the first chunk, add a function which maps all cpu
> >>>>> buffers corresponding to that per-cpu buffer.
> >>>>>
> >>>>> Also add function to clear page table entries for a percpu buffer.
> >>>>>
> >>>>
> >>>> This needs some kind of clarification so that readers can tell wheth=
er
> >>>> you're trying to map all percpu memory or just map a specific
> >>>> variable.  In either case, you're making a dubious assumption that
> >>>> percpu memory contains no secrets.
> >>> I'm thinking the per-cpu random pool is a secrit. IOW, it demonstrabl=
y
> >>> does contain secrits, invalidating that premise.
> >>
> >> The current code unconditionally maps the entire first percpu chunk
> >> (pcpu_base_addr). So it assumes it doesn't contain any secret. That is
> >> mainly a simplification for the POC because a lot of core information
> >> that we need, for example just to switch mm, are stored there (like
> >> cpu_tlbstate, current_task...).
> >
> > I don=E2=80=99t think you should need any of this.
> >
>
> At the moment, the current code does need it. Otherwise it can't switch f=
rom
> kvm mm to kernel mm: switch_mm_irqs_off() will fault accessing "cpu_tlbst=
ate",
> and then the page fault handler will fail accessing "current" before call=
ing
> the kvm page fault handler. So it will double fault or loop on page fault=
s.
> There are many different places where percpu variables are used, and I ha=
ve
> experienced many double fault/page fault loop because of that.

Now you're experiencing what working on the early PTI code was like :)

This is why I think you shouldn't touch current in any of this.

>
> >>
> >> If the entire first percpu chunk effectively has secret then we will
> >> need to individually map only buffers we need. The kvm_copy_percpu_map=
ping()
> >> function is added to copy mapping for a specified percpu buffer, so
> >> this used to map percpu buffers which are not in the first percpu chun=
k.
> >>
> >> Also note that mapping is constrained by PTE (4K), so mapped buffers
> >> (percpu or not) which do not fill a whole set of pages can leak adjace=
nt
> >> data store on the same pages.
> >>
> >>
> >
> > I would take a different approach: figure out what you need and put it =
in its
> > own dedicated area, kind of like cpu_entry_area.
>
> That's certainly something we can do, like Julian proposed with "Process-=
local
> memory allocations": https://lkml.org/lkml/2018/11/22/1240
>
> That's fine for buffers allocated from KVM, however, we will still need s=
ome
> core kernel mappings so the thread can run and interrupts can be handled.
>
> > One nasty issue you=E2=80=99ll have is vmalloc: the kernel stack is in =
the
> > vmap range, and, if you allow access to vmap memory at all, you=E2=80=
=99ll
> > need some way to ensure that *unmap* gets propagated. I suspect the
> > right choice is to see if you can avoid using the kernel stack at all
> > in isolated mode.  Maybe you could run on the IRQ stack instead.
>
> I am currently just copying the task stack mapping into the KVM page tabl=
e
> (patch 23) when a vcpu is created:
>
>         err =3D kvm_copy_ptes(tsk->stack, THREAD_SIZE);
>
> And this seems to work. I am clearing the mapping when the VM vcpu is fre=
ed,
> so I am making the assumption that the same task is used to create and fr=
ee
> a vcpu.
>

vCPUs are bound to an mm but not a specific task, right?  So I think
this is wrong in both directions.

Suppose a vCPU is created, then the task exits, the stack mapping gets
freed (the core code tries to avoid this, but it does happen), and a
new stack gets allocated at the same VA with different physical pages.
Now you're toast :)  On the flip side, wouldn't you crash if a vCPU is
created and then run on a different thread?

How important is the ability to enable IRQs while running with the KVM
page tables?

