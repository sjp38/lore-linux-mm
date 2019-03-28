Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A21FC10F06
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 21:32:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2FE582184E
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 21:32:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="XUSFmkDp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2FE582184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C92F56B028E; Thu, 28 Mar 2019 17:32:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C67F16B0292; Thu, 28 Mar 2019 17:32:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B56406B0293; Thu, 28 Mar 2019 17:32:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 81DD36B028E
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 17:32:55 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id n2so178189otk.19
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 14:32:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=RRoz1sH8AOofMZyH/MnRoYJlFBjef59CBPNfTKquYe0=;
        b=TmX99CavYxHZVNG8pqJ57AEH8+Dw1GW+53BVO6JYVu59l8kMN4ffmSzGPxXwWSaahr
         LHIAWv2mMx5H30wrQhVnBvTe1oey6W/5kuAWl6eeG+YIGnRNYTf3AtZnwtRZN7hUxfDN
         M9EoYaGhEBtcIiu31TvRXzbB+K+CJqe2nIWuioapifxEKLdSbz8XKl69gnjFLvi0BGpn
         dkEVWLUYd+MRo9ZZO1pz3MBjh571zdp/Z7FeGCMaMnCLUu3hPskL4JnC1SDhRonBDAMm
         HYC9E9esYdnLLvg1MvA/yDq3vpw4/SsOpKTyO1BHyi+VPq+ONYkb9uB7kmZ+9Tw3ckrX
         vStA==
X-Gm-Message-State: APjAAAW399xygnh0JXHpO5F6dt9CrOsI08bfXJDANyTm5GAWeaRm9PFz
	ESD96F+MNp1Cx6g3uB0fXBASXJdAlsoKFSF/lCtw4SZnB12k9SHy6Uof4tJg+v9wW0WEGh+juR0
	lel3HP22zpmDL+ijzbrb2JD/CmqDVOt+ANMcyM6MBg9htqPVobXFzzTa1zaN1EwviAg==
X-Received: by 2002:aca:f105:: with SMTP id p5mr1598667oih.172.1553808775039;
        Thu, 28 Mar 2019 14:32:55 -0700 (PDT)
X-Received: by 2002:aca:f105:: with SMTP id p5mr1598609oih.172.1553808773699;
        Thu, 28 Mar 2019 14:32:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553808773; cv=none;
        d=google.com; s=arc-20160816;
        b=RD8fTPTE0rlxahRA3HCmYYikqeFbZMOyHRKhYd9g4oMHxSz00Geh2OBV1itR3Ia7gB
         BvyJ9hToVwZXQxUXxWnMyc2mvmTzY4Ubp7haDAqpOZfowsLG5+HjH0TQQud75QFrTOXx
         IvLqVLYFksocYAkHHp6URWfGyTZs3rMrReQFeMRS/HdMSAzoC3Du5wwfaK8SeeQWdzFa
         BwW3xVI4g6j2pldQ2azTYPOdgJpZ6ldB8T5Ucp4i2DFQgG60JmGQGHbLwToU0wyG017C
         CnMvikcydYVGHq+7qOtE5JABOlyeA/QmQtJfsJ+Jw75inIsgs0XIasrrCi/uBnXsbrb1
         NLRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=RRoz1sH8AOofMZyH/MnRoYJlFBjef59CBPNfTKquYe0=;
        b=l9DQk+eWAit+EOaGFcF+XsXkjRoCrPCr7mZz/R9pxbMm+w5hNl8f166EvjTEhw4qyM
         aXSES2HsC04iN6NM9uzw9Yh8+KJruRZNJt/dY8go9mrb8FfPj1ZT/48jBxZVLaw0OX1+
         7SLm1O8YkE671/IMbo/r5JZoxah8Lz7z41M9fZp5i2M0Lp16uUeOhHTRwDwF6um6QT3b
         YpuuDYRd6sSX3f/GV1wANmMA88e7FR2hLTQiocYR6uJX8Qs4jtKo9NaJwvb9M/zeUDyu
         LWHLH2NbBMkpgI/JJ9drr/58ghYXqOXqgTJS+kV+STiLIj7dnO3B4yqjfoXChNt+Rqxc
         9JZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=XUSFmkDp;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p124sor15799571oia.101.2019.03.28.14.32.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Mar 2019 14:32:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=XUSFmkDp;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=RRoz1sH8AOofMZyH/MnRoYJlFBjef59CBPNfTKquYe0=;
        b=XUSFmkDpyT1FlmTVuJgj8AVeBKaifRG50kAWV2XVx1ZSbspXYH/stLc58OnC8J6CFm
         /ty5nihn/W3YNpRhmPaVs/5w2gcTBkydt/gis8VHVR9VlX+TepxgfRvCYTEGCzVjvd++
         I7DhOv9kbOqFuMgFml173hKY7f3blb/ng6FKqkyjRl1UYff7tgasvA72sBVCgr+E3Oy4
         z3RLbTYXJR7DyP4ZdGQalj82e/4fION5qdG5Oaq/vZ6rGiFl23k9Ag/OUdWGL1PWysT7
         jVd/xFg120XvqaZmXDD5I0pxQCpHDRrp13LdWfLyyGJ53+KBwvUyfqGA3VvI+kHI5T0C
         lvyA==
X-Google-Smtp-Source: APXvYqxqLnrUqVLmH+LUT6WoSkbGJrNWil1XO16wT4zRg/nNkV4EjSSHUQ8yfhx/VHyBOly9bybJR+XutJw5+D+MRzQ=
X-Received: by 2002:aca:f581:: with SMTP id t123mr1614964oih.0.1553808772940;
 Thu, 28 Mar 2019 14:32:52 -0700 (PDT)
MIME-Version: 1.0
References: <155327387405.225273.9325594075351253804.stgit@dwillia2-desk3.amr.corp.intel.com>
 <cf304a31-70a6-e701-ec3e-c47dc84b81d2@redhat.com> <CAPcyv4hgAM=ex0B4EBZ40RNf=bXk2WkEzySTUV4ZzOWd_HZwSQ@mail.gmail.com>
 <24c163f2-3b78-827f-257e-70e5a9655806@redhat.com>
In-Reply-To: <24c163f2-3b78-827f-257e-70e5a9655806@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 28 Mar 2019 14:32:42 -0700
Message-ID: <CAPcyv4ivBagzsZ1fCDb2Cr3scz+R8ZVgyie5c=LWNd6QZuw36g@mail.gmail.com>
Subject: Re: [PATCH v5 00/10] mm: Sub-section memory hotplug support
To: David Hildenbrand <david@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Logan Gunthorpe <logang@deltatee.com>, Toshi Kani <toshi.kani@hpe.com>, Jeff Moyer <jmoyer@redhat.com>, 
	Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, stable <stable@vger.kernel.org>, 
	Linux MM <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 2:17 PM David Hildenbrand <david@redhat.com> wrote:
>
> >> You are using the term "Sub-section memory hotplug support", but is it
> >> actually what you mean? To rephrase, aren't we talking here about
> >> "Sub-section device memory hotplug support" or similar?
> >
> > Specifically it is support for passing @start and @size arguments to
> > arch_add_memory() that are not section aligned. It's not limited to
> > "device memory" which is otherwise not a concept that
> > arch_add_memory() understands, it just groks spans of pfns.
>
> Okay, so everything that does not have a memory block devices as of now.
>
> >
> >> Reason I am asking is because I wonder how that would interact with the
> >> memory block device infrastructure and hotplugging of system ram -
> >> add_memory()/add_memory_resource(). I *assume* you are not changing the
> >> add_memory() interface, so that one still only works with whole sections
> >> (or well, memory_block_size_bytes()) - check_hotplug_memory_range().
> >
> > Like you found below, the implementation enforces that add_memory_*()
> > interfaces maintain section alignment for @start and @size.
> >
> >> In general, mix and matching system RAM and persistent memory per
> >> section, I am not a friend of that.
> >
> > You have no choice. The platform may decide to map PMEM and System RAM
> > in the same section because the Linux section is too large compared to
> > typical memory controller mapping granularity capability.
>
> I might be very wrong here, but do we actually care about something like
> 64MB getting lost in the cracks? I mean if it simplifies core MM, let go
> of the couple of MB of system ram and handle the PMEM part only. Treat
> the system ram parts like memory holes we already have in ordinary
> sections (well, there we simply set the relevant struct pages to
> PG_reserved). Of course, if we have hundreds of unaligned devices and
> stuff will start to add up ... but I assume this is not the case?

That's precisely what we do today and it has become untenable as the
collision scenarios pile up. This thread [1] is worth a read if you
care about  some of the gory details why I'm back to pushing for
sub-section support, but most if it has already been summarized in the
current discussion on this thread.

[1]: https://lore.kernel.org/lkml/155000671719.348031.2347363160141119237.stgit@dwillia2-desk3.amr.corp.intel.com/

>
> >
> >> Especially when it comes to memory
> >> block devices. But I am getting the feeling that we are rather targeting
> >> PMEM vs. PMEM with this patch series.
> >
> > The collisions are between System RAM, PMEM regions, and PMEM
> > namespaces (sub-divisions of regions that each need their own mapping
> > lifetime).
>
> Understood. I wonder if that PMEM only mapping (including separate
> lifetime) could be handled differently. But I am absolutely no expert,
> just curious.

I refer you to the above thread trying to fix the libnvdimm-local hacks.

>
> >
> >>> Quote patch7:
> >>>
> >>> "The libnvdimm sub-system has suffered a series of hacks and broken
> >>>  workarounds for the memory-hotplug implementation's awkward
> >>>  section-aligned (128MB) granularity. For example the following backtrace
> >>>  is emitted when attempting arch_add_memory() with physical address
> >>>  ranges that intersect 'System RAM' (RAM) with 'Persistent Memory' (PMEM)
> >>>  within a given section:
> >>>
> >>>   WARNING: CPU: 0 PID: 558 at kernel/memremap.c:300 devm_memremap_pages+0x3b5/0x4c0
> >>>   devm_memremap_pages attempted on mixed region [mem 0x200000000-0x2fbffffff flags 0x200]
> >>>   [..]
> >>>   Call Trace:
> >>>     dump_stack+0x86/0xc3
> >>>     __warn+0xcb/0xf0
> >>>     warn_slowpath_fmt+0x5f/0x80
> >>>     devm_memremap_pages+0x3b5/0x4c0
> >>>     __wrap_devm_memremap_pages+0x58/0x70 [nfit_test_iomap]
> >>>     pmem_attach_disk+0x19a/0x440 [nd_pmem]
> >>>
> >>>  Recently it was discovered that the problem goes beyond RAM vs PMEM
> >>>  collisions as some platform produce PMEM vs PMEM collisions within a
> >>
> >> As side-noted by Michal, I wonder if PMEM vs. PMEM cannot rather be
> >> implemented "on top" of what we have right now. Or is this what we
> >> already have that you call "hacks in nvdimm" code? (no NVDIMM expert,
> >> sorry for the stupid questions)
> >
> > It doesn't work, because even if the padding was implemented 100%
> > correct, which thus far has failed to be the case, the platform may
> > change physical alignments from one boot to the next for a variety of
> > reasons.
>
> Would ignoring the System RAM parts (as mentioned above) help or doesn't
> it make any difference in terms of complexity?

Doesn't help much, that's only one of many collision sources.

> >>>  given section. The libnvdimm workaround for that case revealed that the
> >>>  libnvdimm section-alignment-padding implementation has been broken for a
> >>>  long while. A fix for that long-standing breakage introduces as many
> >>>  problems as it solves as it would require a backward-incompatible change
> >>>  to the namespace metadata interpretation. Instead of that dubious route
> >>>  [2], address the root problem in the memory-hotplug implementation."
> >>>
> >>> The approach is taken is to observe that each section already maintains
> >>> an array of 'unsigned long' values to hold the pageblock_flags. A single
> >>> additional 'unsigned long' is added to house a 'sub-section active'
> >>> bitmask. Each bit tracks the mapped state of one sub-section's worth of
> >>> capacity which is SECTION_SIZE / BITS_PER_LONG, or 2MB on x86-64.
> >>>
> >>> The implication of allowing sections to be piecemeal mapped/unmapped is
> >>> that the valid_section() helper is no longer authoritative to determine
> >>> if a section is fully mapped. Instead pfn_valid() is updated to consult
> >>> the section-active bitmask. Given that typical memory hotplug still has
> >>> deep "section" dependencies the sub-section capability is limited to
> >>> 'want_memblock=false' invocations of arch_add_memory(), effectively only
> >>> devm_memremap_pages() users for now.
> >>
> >> Ah, there it is. And my point would be, please don't ever unlock
> >> something like that for want_memblock=true. Especially not for memory
> >> added after boot via device drivers (add_memory()).
> >
> > I don't see a strong reason why not, as long as it does not regress
> > existing use cases. It might need to be an opt-in for new tooling that
> > is aware of finer granularity hotplug. That said, I have no pressing
> > need to go there and just care about the arch_add_memory() capability
> > for now.
>
> Especially onlining/offlining of memory might end up very ugly. And that
> goes hand in hand with memory block devices. They are either online or
> offline, not something in between. (I went that path and Michal
> correctly told me why it is not a good idea)

Thread reference?

> I was recently trying to teach memory block devices who their owner is /
> of which type they are. Right now I am looking into the option of using
> drivers. Memory block devices that could belong to different drivers at
> a time are well ... totally broken.

Sub-section support is aimed at a similar case where different
portions of an 128MB span need to handed out to devices / drivers with
independent lifetimes.

> I assume it would still be a special
> case, though, but conceptually speaking about the interface it would be
> allowed.
>
> Memory block devices (and therefore 1..X sections) should have one owner
> only. Anything else just does not fit.

Yes, but I would say the problem there is that the
memory-block-devices interface design is showing its age and is being
pressured with how systems want to deploy and use memory today.

