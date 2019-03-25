Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 871DFC10F03
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 20:04:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D35F2075D
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 20:04:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="ul/ATYfu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D35F2075D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CACC06B0003; Mon, 25 Mar 2019 16:04:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C5A566B0006; Mon, 25 Mar 2019 16:04:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B49316B0007; Mon, 25 Mar 2019 16:04:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 820D56B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 16:04:04 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id w11so7109132otq.7
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 13:04:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=j8iMmCuwX2aCoYyVyKsIorArHi446pk2+N/mU/mW9uk=;
        b=MLFF57fwgW9iDwQ/OAnMxioYSXEdGC9kmoht1XbDwEJi5eDfWgwCeGJf/KuA+uiIdn
         UW77gV9ww2Pz1oFeCP7uONCldURURl99J9HK3R+eXqOKKzV3UfSUgBEgxEzQaZv92rR/
         yIluD3EuJ/EXVLXx4TrbDfRWIgVomLlpOcQKy+7bKPe0JZ3mw8PThaoWMsRMNBBkVROu
         2NfcknEFFT634V41WZSafSclXv9+JAZ82OaYjUI7QYRMPW8a/y+aZGvSOROC3gsIiPfM
         tXr6MgH83rHyQqFzk+me+VTd6epP7MMLcCDSBsf0bsqMB9ITY5coHcWX/SviioWUkKHr
         1HTQ==
X-Gm-Message-State: APjAAAVIjIFcutdApUKgK3Sn5wVrXVS4sWdrZp9FeAN2x1+MwBG+CqjO
	pd4ESGFXQVQTM8V8LbXsl6efPbxiEqi7FnKRFVT3Qewr0mnXUrHTmGNfW62N1BMlB3nLTHJs0bo
	bVsmQaTJ2DwzPp/cQWeVBE7jgTwwzTOnaNUnZKhcCdp3Z9sWWRVgPOre3d0zHCpszDg==
X-Received: by 2002:a05:6830:20cc:: with SMTP id z12mr19626587otq.334.1553544243691;
        Mon, 25 Mar 2019 13:04:03 -0700 (PDT)
X-Received: by 2002:a05:6830:20cc:: with SMTP id z12mr19626493otq.334.1553544242311;
        Mon, 25 Mar 2019 13:04:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553544242; cv=none;
        d=google.com; s=arc-20160816;
        b=oXJN/E04gl7a82XVH49s2vhieyzCWbWakuu0RwQD09FBGSlJPbpt5C/5bkj4w5ALxu
         T+iqKfvu4eRmqiLQtH6tt8CiW8n6JTH1c1NI8+Qz5igNk/gAkHD/NzvV+aIL+kvxpjFr
         XLDqUI4B8hEwhn86a44DbmSgkwlNEVmS5NAMi2hkC9g4z2PIl4DSIMVPVF40avLPvXyR
         quFHBwiIZtZUZuxABnRzEZ6u0sVhVESndZrFA0ucoy8nQ0iZaD97mt5MWHl0DgeesJse
         t1CdihnpzA34qzpWK7yb7mJDD43sxwELhIxARZWy+t6cb/4EtqmI9MGrxyLSQnOGi4lL
         wpjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=j8iMmCuwX2aCoYyVyKsIorArHi446pk2+N/mU/mW9uk=;
        b=odz613U5gm7pIoayUvMwFPRv2yltj3DLkCbr63sevqDg8cgnH6N6lY5dAB9t+rUiyg
         fMGt4kW9xNp2Jkyx8lqY8n95Ya7VixDGl8Lsgp05n63fLdvuOfD3waVE5+uf1S16rboy
         IbkFXUkKUvvF8Hf2sgTtx8loX75DkK/F0Lo0+9CwvBTUyOBgSgRHYAzcsasAUONTNypS
         TnXVXjZ8vLo3APEnT0lsBItpfQ1zW64Djk9H76afsrOsTk5g3SJ+FRQjjxxsuKHD0o13
         GlN4ahbHLv1/tyEJH/1yKzf3ZZur+7nXnjnR140/NJzVAhFyEOFsBIizUdfSM6ldQW1j
         heGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="ul/ATYfu";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c2sor2675530oto.158.2019.03.25.13.04.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Mar 2019 13:04:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="ul/ATYfu";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=j8iMmCuwX2aCoYyVyKsIorArHi446pk2+N/mU/mW9uk=;
        b=ul/ATYfujOPFBQf6Plk87BLxrzpl00lYBLyGUKYvSh4tJJL3Afj/be39oxB+F+AbQ8
         XevypMi/3cJrZ2Kl+zikv5aYw8HEkYiAsp9nl7bNIPXgFhryJ0BZ/bmMgdSTVh5dTeYc
         KaqMFZiCcxplSSxk9ZppJ83ZwXdVqR65cthi9oWLwNWyB9PS6dhB/FtURuv1calXpoe1
         DpmsiU/6IEBP2twQDn14r2mV66w+MUh8hk/WbWE+EQcXCHsKCcdB/beWBUOZYSKoktIk
         eUKFZolbPhQbiPmV5gpBDRkZ9tK5Gv7QPR1HeA44Qx5lVdDTvOesD/TnKLZsTpXLrCUY
         eKwA==
X-Google-Smtp-Source: APXvYqzPOuSjj1sSIGgdYoB2Kz6mZc1CBDcBm+z++qoudQjIR03HzPDoh0mYY23PFFfO60vrLyEK7mdC2nyjgPwXWko=
X-Received: by 2002:a9d:4d0b:: with SMTP id n11mr18040633otf.98.1553544240381;
 Mon, 25 Mar 2019 13:04:00 -0700 (PDT)
MIME-Version: 1.0
References: <155327387405.225273.9325594075351253804.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190322180532.GM32418@dhcp22.suse.cz> <CAPcyv4gBGNP95APYaBcsocEa50tQj9b5h__83vgngjq3ouGX_Q@mail.gmail.com>
 <20190325101945.GD9924@dhcp22.suse.cz>
In-Reply-To: <20190325101945.GD9924@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 25 Mar 2019 13:03:47 -0700
Message-ID: <CAPcyv4iJCgu-akJM_O8ZtscqWQt=CU-fvx-ViGYeau-NJufmSQ@mail.gmail.com>
Subject: Re: [PATCH v5 00/10] mm: Sub-section memory hotplug support
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Logan Gunthorpe <logang@deltatee.com>, Toshi Kani <toshi.kani@hpe.com>, Jeff Moyer <jmoyer@redhat.com>, 
	Vlastimil Babka <vbabka@suse.cz>, stable <stable@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 3:20 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 22-03-19 11:32:11, Dan Williams wrote:
> > On Fri, Mar 22, 2019 at 11:06 AM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Fri 22-03-19 09:57:54, Dan Williams wrote:
> > > > Changes since v4 [1]:
> > > > - Given v4 was from March of 2017 the bulk of the changes result from
> > > >   rebasing the patch set from a v4.11-rc2 baseline to v5.1-rc1.
> > > >
> > > > - A unit test is added to ndctl to exercise the creation and dax
> > > >   mounting of multiple independent namespaces in a single 128M section.
> > > >
> > > > [1]: https://lwn.net/Articles/717383/
> > > >
> > > > ---
> > > >
> > > > Quote patch7:
> > > >
> > > > "The libnvdimm sub-system has suffered a series of hacks and broken
> > > >  workarounds for the memory-hotplug implementation's awkward
> > > >  section-aligned (128MB) granularity. For example the following backtrace
> > > >  is emitted when attempting arch_add_memory() with physical address
> > > >  ranges that intersect 'System RAM' (RAM) with 'Persistent Memory' (PMEM)
> > > >  within a given section:
> > > >
> > > >   WARNING: CPU: 0 PID: 558 at kernel/memremap.c:300 devm_memremap_pages+0x3b5/0x4c0
> > > >   devm_memremap_pages attempted on mixed region [mem 0x200000000-0x2fbffffff flags 0x200]
> > > >   [..]
> > > >   Call Trace:
> > > >     dump_stack+0x86/0xc3
> > > >     __warn+0xcb/0xf0
> > > >     warn_slowpath_fmt+0x5f/0x80
> > > >     devm_memremap_pages+0x3b5/0x4c0
> > > >     __wrap_devm_memremap_pages+0x58/0x70 [nfit_test_iomap]
> > > >     pmem_attach_disk+0x19a/0x440 [nd_pmem]
> > > >
> > > >  Recently it was discovered that the problem goes beyond RAM vs PMEM
> > > >  collisions as some platform produce PMEM vs PMEM collisions within a
> > > >  given section. The libnvdimm workaround for that case revealed that the
> > > >  libnvdimm section-alignment-padding implementation has been broken for a
> > > >  long while. A fix for that long-standing breakage introduces as many
> > > >  problems as it solves as it would require a backward-incompatible change
> > > >  to the namespace metadata interpretation. Instead of that dubious route
> > > >  [2], address the root problem in the memory-hotplug implementation."
> > > >
> > > > The approach is taken is to observe that each section already maintains
> > > > an array of 'unsigned long' values to hold the pageblock_flags. A single
> > > > additional 'unsigned long' is added to house a 'sub-section active'
> > > > bitmask. Each bit tracks the mapped state of one sub-section's worth of
> > > > capacity which is SECTION_SIZE / BITS_PER_LONG, or 2MB on x86-64.
> > >
> > > So the hotplugable unit is pageblock now, right?
> >
> > No, with this patchset the hotplug unit is 2MB.
>
> Which is a pageblock unit on x86 with hugetlb enabled. I was just
> wondering whether this is really bound to pageblock or the math just
> works out to be the same.

Ah, ok just coincidental math.

> > > Why is this sufficient?
> >
> > 2MB is sufficient because it allows mapping a namespace at PMD
> > granularity and there is no practical need to go smaller.
> >
> > > What prevents new and creative HW to come up with alignements that do not fit there?
> >
> > There is a resource in hardware memory controllers called
> > address-decode-registers that control the mapping granularity. The
> > minimum granularity today is 64MB and the pressure as memory sizes
> > increases is to make that granularity larger, not smaller. So the
> > hardware pressure is going in the opposite direction of your concern,
> > at least for persistent memory.
>
> OK, this is good to know and actually against subsection direction.

Seems I forgot to mention timescales. The 64MB granularity is present
on current generation platforms, and I expect multiple platform
generations (potentially years) until it might change in the future.

That does not even take into consideration the configuration
flexibility of PCI BAR ranges and the interaction with the
peer-to-peer DMA facility which maps 'struct page' for physical ranges
that are not memory. There is no pressure for PCI BAR ranges to submit
to a 128MB alignment.

> > User-defined memory namespaces have this problem, but 2MB is the
> > default alignment and is sufficient for most uses.
>
> What does prevent users to go and use a larger alignment?

Given that we are living with 64MB granularity on mainstream platforms
for the foreseeable future, the reason users can't rely on a larger
alignment to address the issue is that the physical alignment may
change from one boot to the next.

No, you can't just wish hardware / platform firmware won't do this,
because there are not enough platform resources to give every hardware
device a guaranteed alignment.

The effect is that even if the driver deploys a software alignment
mitigation when it first sees the persistent memory range, that
alignment can be violated on a subsequent boot leading to data being
unavailable. There is no facility to communicate to the administrator
what went wrong in this scenario as several events can trigger a
physical map layout change. Add / remove of hardware and hardware
failure are the most likely causes.

An additional pain point for users is that EFI pre-boot environment
has little chance to create a namespace that Linux might be able to
use. The section size is an arbitrary Linux constraint and we should
not encode something Linux specific that might change in the future
into OS agnostic software.

> > PCI Address BARs that are also mapped with devm_memremap_pages are
> > aligned to their size and there is no expectation to support smaller
> > than 2MB.
> >
> > All that said, to support a smaller sub-section granularity, just add
> > more bits to the section-active bitmask.
> >
> > > Do not get me wrong but the section
> > > as a unit is deeply carved into the memory hotplug and removing all those
> > > assumptions is a major undertaking
> >
> > Right, as stated in the cover letter, this does not remove all those
> > assumptions, it only removes the ones that impact
> > devm_memremap_pages(). Specifying that sub-section is only supported
> > in the 'want_memblock=false' case to arch_add_memory().
>
> And this is exactly the problem. Having different assumptions depending
> on whether there is a memblock interface or not is utterly wrong and a
> maintainability mess.

In this case I disagree with you. The hotplug code already has the
want_memblock=false semantic in the implementation. The sub-section
hotplug infrastructure is a strict superset of what is there already.
Now, if it created parallel infrastructure that would indeed be a
maintainability burden, but in this case there are no behavior changes
for typical memory hotplug as it just hotplugs full sections at a time
like always. The 'section' concept is not going away.

> > > and I would like to know that you are
> > > not just shifting the problem to a smaller unit and a new/creative HW
> > > will force us to go even more complicated.
> >
> > HW will not do this to us. It's software that has the problem.
> > Namespace creation is unnecessarily constrained to 128MB alignment.
>
> And why is that a problem?

Data loss, inability to cope with some hardware configurations,
difficult to interoperate with non-Linux software.

> A lack of documentation that this is a requirement?

It's not a requirement. It's an arbitrary Linux implementation detail.

> Something will not work with a larger alignment? Someting else?
[..]
> Why do we have to go a mile to tweak the kernel, especially something as
> fragile as memory hotplug, just to support sub mem section ranges. This
> is somthing that is not clearly explained in the cover letter. Sure you
> are talking about hacks at the higher level to deal with this but I do
> not see any fundamental reason to actually support that at all.

Like it or not, 'struct page' mappings for arbitrary hardware-physical
memory ranges is a facility that has grown from the pmem case, to hmm,
and peer-to-peer DMA. Unless you want to do the work to eliminate the
'struct page' requirement across the kernel I think it is unreasonable
to effectively archive the arch_add_memory() implementation and
prevent it from reacting to growing demands.

Note that I did try to eliminate 'struct page' before creating
devm_memremap_pages(), that effort failed because 'struct page' is
just too ingrained into too many kernel code paths.

> > I'm also open to exploring lifting the section alignment constraint
> > for the 'want_memblock=true', but first things first.
>
> I disagree. If you want to get rid of the the section requirement then
> do it first and build on top. This is a normal kernel development
> process.
>
> > > What is the fundamental reason that pmem sections cannot be assigned
> > > to a section aligned memory range? The physical address space is
> > > quite large to impose 128MB sections IMHO. I thought this is merely a
> > > configuration issue.
> >
> > 1) it's not just hardware that imposes this, software wants to be able
> > to avoid the constraint
> >
> > 2) the flexibility of the memory controller initialization code is
> > constrained by address-decode-registers. So while it is simple to say
> > "just configure it to be aligned" it's not that easy in practice
> > without throwing away usable memory capacity.
>
> Yes and we are talking about 128MB is sacrifying that unit worth all the
> troubles?
>
> [...]
>
> > > I will probably have much more question, but it's friday and I am mostly
> > > offline already. I would just like to hear much more about the new
> > > design and resulting assumptions.
> >
> > Happy to accommodate this discussion. The section alignment has been
> > an absolute horror to contend with. So I have years worth of pain to
> > share for as deep as you want to go on probing why this is needed.
>
> I can feel your frustration. I am not entirely happy about the section
> size limitation myself but you have to realize that this is simplicy vs.
> feature set compromise.

You have to realize that arch_add_memory() is no longer just a
front-end for typical memory hotplug. The requirements have changed.
Simplicity should be maintained for as long as it can get the job
done, and the simplicity is currently failing.

> It works reasonably well for many usecases but
> falls flat on some others. But you cannot simply build on top of
> existing foundations and tweak some code paths to handle one particular
> case. This is exactly how the memory hotplug ended in the unfortunate
> state it is now. If you want to make the code more reusable then there
> is a _lot_ of ground work first before you can add a shiny new feature.

This *is* the ground work. It solves the today's hardware page-mapping
pain points with a path to go deeper and enable sub-section hotplug
for typical memory hotplug, but in the meantime the two cases share
common code paths. This is not a tweak on the side, it's a super-set,
and typical memory-hotplug is properly fixed up to use just the subset
that it needs.

