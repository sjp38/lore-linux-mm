Return-Path: <SRS0=hkLx=PX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E259EC43387
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 06:06:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CCCA2085A
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 06:06:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NWUP1IuV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CCCA2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CEF618E0003; Tue, 15 Jan 2019 01:06:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C9E9E8E0002; Tue, 15 Jan 2019 01:06:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8D1E8E0003; Tue, 15 Jan 2019 01:06:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 922FC8E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 01:06:31 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id m128so1840161itd.3
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 22:06:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=04LD5tnaL6HygrCedJCCK4XNsXVpKMg/caDZ85xc/Og=;
        b=QQjn819pGzLoUePuzMWcLnTIYqFX1K5kNVzw3D1ZO8vDpO0HOD4llLANGSW4VYMzxM
         yt/ArASViC1hXiCM0rM9qGpUQqz2ZVB6YLvhGZkwto8PAN4oHzZiOk9MWfI7pQqbGPrO
         h4l2IYHql2FOWGVwlTNuEMNIed/w/lPhyrl9DabmecW6C+XgCvQQuTs13h6o85wU9qP/
         sSn1uNh8JdaUZsx0YqsRPJhUFqVZ0okq6EezVuNObZX13bPuByVp+TvOoSsMvLyWPT38
         dAWcf/DEHNmHHVWC+LnZWFFLAEqfWwo4n0NpVGTRH9gNzhbl5dHTrr4POmp30+a6pHtb
         +80Q==
X-Gm-Message-State: AJcUukdrDvQZQA+oFtXwi2L7dbozvGPZm5wL1d1DSC0abMX6MRLJ9xhn
	JGB6cdC+yk2afv0zY1Gl+CHyKue0tt9CRuXtdcxWoTU+ujrJWA4gltyY0c79oZm/Cawvk89G5Nk
	36JuRqqMp6BiBhOfsQ0LZq0/ZLGUyYtIi745rYbaDPvP5d4NnQ/pbVIHFKMomTTcGZQdXASK2VI
	kD4PAJSAi+JlYladAXarKq5fdS2edJPtZagLgHdvy7eBeLPxw6Q/NfgB7+U+Nq/0INsG/ufxMfK
	vZw30ZCAdDlnxYDCfWi3hIosKQfish+CFzdU5ap06LeiWNEhqjylBQEGUDYaDgzBKleHEVz5elP
	KEYQrECOq+bvLx1p062IlYrd7a0c1CNcYwRoCsw/IytUkojprjj+WErOiRl6KkoyvUvc8n4Wunm
	Z
X-Received: by 2002:a6b:9089:: with SMTP id s131mr1286373iod.242.1547532391301;
        Mon, 14 Jan 2019 22:06:31 -0800 (PST)
X-Received: by 2002:a6b:9089:: with SMTP id s131mr1286358iod.242.1547532390464;
        Mon, 14 Jan 2019 22:06:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547532390; cv=none;
        d=google.com; s=arc-20160816;
        b=sYnQ5VrRLfP4oqVWmS3j/dI2f1jEFbQPrPZGkQSb2uHlMqzMfsbrKX+Wk7ubz6Id2K
         BKnciOcX5MLWFVAFI2mJwKAZCOjqY/fyO0nYzvwrgr3QVgnsS+JNvLqkoIFCRhiUY9Rg
         Q9cVLYW5GKb6DT55N14O1W3LQwe+zhgloHguqL3puon1FfkIGLrrbWduByEDOExNEE06
         rLvys/i7polsouWTHLy1UumV0qZ+GRpOPkBITQAGMWoVp+cDBxmlXfIpZRnaFw/c7jlf
         It0f0LBlfM2ECw3r7sULFgV4Bi/EKzHGns1usVh2LPEGpWRhuw5fkRZiYIyI7NdWOVFW
         5IKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=04LD5tnaL6HygrCedJCCK4XNsXVpKMg/caDZ85xc/Og=;
        b=biCb4VWtiaxp1kjJxJfk5xrC8f0/lCtA1nYt/4BhA+1s6YCwGXFt4HKIua/ZeOrRzR
         lghqVjjAIUDLPD7zni3JRKInUza/um4f+vMdUdoyKTi7Q0u17zFjk3MHRQh+AE6zeeU4
         2e8DxeBKtNtFdKVKrjmw2Tt+wacjF2Kd3MijFNVePlNzIcBsSMxUc/8YrRwCdDQ8cnBZ
         e5u+Bl3lGEzayRt45gYnbZP6qn+CK4BKgX6LMYkTw/fnYdlGgAVvcBIYTjflBQNWh77K
         c1TueIynCAss9kmLwBnc/egBAILrW6njWT+PvpnkLl0qL/N2yunL+QV1/z6+LQ6fNweX
         FrIw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NWUP1IuV;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 62sor1108925ioc.95.2019.01.14.22.06.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 22:06:30 -0800 (PST)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NWUP1IuV;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=04LD5tnaL6HygrCedJCCK4XNsXVpKMg/caDZ85xc/Og=;
        b=NWUP1IuVIPMrmG00smSS107/8BQbtcDtO7L0kLleNwzqAmebAjWUUCV2JWrJOJIkHo
         7tmpA2T6MIhdW67zkU0exiB4cx4C1OzcP18u0BOXHTr+tc4pH/EHE8T8KVIUO+B6zAmY
         eAOBN6A9x6ZhrMarPobF/GI/f+4ATL/IOG8ANGIkakBrh/1VIYBYiw+AVMCAS7s5WCPU
         X2p3TBWR/iTblrn5HzJ9mNxOIBxc/JjTlLVFDnjpI7FJFrDOksssuBWvqBfn6C/rfdhV
         x76H/IVlYcS0s1bp5UG3aAhIGpHO7B1U0cy7A4aG1H2MSp5QJj+ri/tnpOsOyWewWgvy
         cC/g==
X-Google-Smtp-Source: ALg8bN48jzf4aeD7b0DSZB3vH55RXm3TPmU/PlMMWm8l+Aw0vxaA7CGhidBrJuem97ZNEopmz+DwktVb1+3ouzXdRUM=
X-Received: by 2002:a6b:39c6:: with SMTP id g189mr1049006ioa.255.1547532390132;
 Mon, 14 Jan 2019 22:06:30 -0800 (PST)
MIME-Version: 1.0
References: <1547183577-20309-1-git-send-email-kernelfans@gmail.com> <fe88d6ff-00e1-b65d-f411-64b03227bd17@intel.com>
In-Reply-To: <fe88d6ff-00e1-b65d-f411-64b03227bd17@intel.com>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Tue, 15 Jan 2019 14:06:18 +0800
Message-ID:
 <CAFgQCTtsw9xj3M85HU2GBk5iPSF4h_H43do-rfpXMo8svmgoJg@mail.gmail.com>
Subject: Re: [PATCHv2 0/7] x86_64/mm: remove bottom-up allocation style by
 pushing forward the parsing of mem hotplug info
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, 
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, 
	Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, 
	Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Chao Fan <fanc.fnst@cn.fujitsu.com>, 
	Baoquan He <bhe@redhat.com>, Juergen Gross <jgross@suse.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, x86@kernel.org, 
	linux-acpi@vger.kernel.org, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190115060618.QOrjGXNFWoD_nmq_5uGCCKoOsu_ze9lLac4-jp3k9b0@z>

On Tue, Jan 15, 2019 at 7:02 AM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 1/10/19 9:12 PM, Pingfan Liu wrote:
> > Background
> > When kaslr kernel can be guaranteed to sit inside unmovable node
> > after [1].
>
> What does this "[1]" refer to?
>
https://lore.kernel.org/patchwork/patch/1029376/

> Also, can you clarify your terminology here a bit.  By "kaslr kernel",
> do you mean the base address?
>
It should be the randomization of load address. Googled, and found out
that it is "base address".

> > But if kaslr kernel is located near the end of the movable node,
> > then bottom-up allocator may create pagetable which crosses the boundary
> > between unmovable node and movable node.
>
> Again, I'm confused.  Do you literally mean a single page table page?  I
> think you mean the page tables, but it would be nice to clarify this,
> and also explicitly state which page tables these are.
>
It should be page table pages. The page table is built by init_mem_mapping().

> >  It is a probability issue,
> > two factors include -1. how big the gap between kernel end and
> > unmovable node's end.  -2. how many memory does the system own.
> > Alternative way to fix this issue is by increasing the gap by
> > boot/compressed/kaslr*.
>
> Oh, you mean the KASLR code in arch/x86/boot/compressed/kaslr*.[ch]?
>
Sorry, and yes, code in arch/x86/boot/compressed/kaslr_64.c and kaslr.c

> It took me a minute to figure out you were talking about filenames.
>
> > But taking the scenario of PB level memory, the pagetable will take
> > server MB even if using 1GB page, different page attr and fragment
> > will make things worse. So it is hard to decide how much should the
> > gap increase.
> I'm not following this.  If we move the image around, we leave holes.
> Why do we need page table pages allocated to cover these holes?
>
I means in arch/x86/boot/compressed/kaslr.c, store_slot_info() {
slot_area.num = (region->size - image_size) /CONFIG_PHYSICAL_ALIGN + 1
}.  Let us denote the size of page table as "X", then the formula is
changed to slot_area.num = (region->size - image_size -X)
/CONFIG_PHYSICAL_ALIGN + 1. And it is hard to decide X due to the
above factors.

> > The following figure show the defection of current bottom-up style:
> >   [startA, endA][startB, "kaslr kernel verly close to" endB][startC, endC]
>
> "defection"?
>
Oh, defect.

> > If nodeA,B is unmovable, while nodeC is movable, then init_mem_mapping()
> > can generate pgtable on nodeC, which stain movable node.
>
> Let me see if I can summarize this:
> 1. The kernel ASLR decompression code picks a spot to place the kernel
>    image in physical memory.
> 2. Some page tables are dynamically allocated near (after) this spot.
> 3. Sometimes, based on the random ASLR location, these page tables fall
>    over into the "movable node" area.  Being unmovable allocations, this
>    is not cool.
> 4. To fix this (on 64-bit at least), we stop allocating page tables
>    based on the location of the kernel image.  Instead, we allocate
>    using the memblock allocator itself, which knows how to avoid the
>    movable node.
>
Yes, you get my idea exactly. Thanks for your help to summary it. Hard
for me to express it clearly in English.

> > This patch makes it certainty instead of a probablity problem. It achieves
> > this by pushing forward the parsing of mem hotplug info ahead of init_mem_mapping().
>
> What does memory hotplug have to do with this?  I thought this was all
> about early boot.

Put the info about memory hot plugable to memblock allocator,
initmem_init()->...->acpi_numa_memory_affinity_init(), where
memblock_mark_hotplug() does it. Later when memory allocator works, in
__next_mem_range(), it will check this info by
memblock_is_hotpluggable().

Thanks and regards,
Pingfan

