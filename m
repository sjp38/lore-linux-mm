Return-Path: <SRS0=ysF+=PT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 819D8C43387
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 21:06:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C51C21783
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 21:06:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="iS/86JjL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C51C21783
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C6408E0002; Fri, 11 Jan 2019 16:06:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 99D858E0001; Fri, 11 Jan 2019 16:06:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B4598E0002; Fri, 11 Jan 2019 16:06:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 491438E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 16:06:44 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id t72so11214452pfi.21
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 13:06:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=HDU1PDMdWvZWz0lbUz1AEBxnqbWSAiRzrxve2qVj3xg=;
        b=b5mdkD7UpDqKYYXOsThHUvIpC5QI8uV4oi2n8I9RKbCeKMRy3sssnFHgIbf0iEsiQF
         7yERvCKHBdGY7Pwu0fLvU4OksWjNlEId563LqRIXcDZ+naV1764+Remx6KTmxAqQRqKM
         epv3Qaa4fiNirvidZFncjePzWcdG18vjrG+b33H38otqJe2dBAB5i1do28SjsiN6ScrH
         92FQMcovOKSKcSwJAslp4QrD0fYl6seK2TakZdrWgivQ4DLCwlx3NFrRFLIgJa84hYzG
         RvewioQyqjpgXmOwmkwTfDa6UmUcPbueSzllgxGp8JG5VwLieZZvCLSh+iURIzWQfz1a
         Swaw==
X-Gm-Message-State: AJcUukcGvt8EzBvaOEbPbJK86w7X47R7/QKxHIC3e+2ZkTkVsHZLVYbj
	mHy0LWRClq9bqYVMhPH8vmwG7gqWzrHbH8mlN/sSgN4CleMGyaS6NdbrP9oYX1rUMd08SPHdnee
	2gdSkh9LNhFDtrfJu4/660xvNabaz/gyeTX9sgD/TJfVGe+NjbNl/pUsB4Rbf6Wv+nQ==
X-Received: by 2002:a62:8985:: with SMTP id n5mr16304967pfk.255.1547240803963;
        Fri, 11 Jan 2019 13:06:43 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6MCJ0alVd6U8zdpq9ADeocj0sEC9NmdXu3cKTgvOoqECytir1a1+msv759meZq1TBcfMBu
X-Received: by 2002:a62:8985:: with SMTP id n5mr16304931pfk.255.1547240803210;
        Fri, 11 Jan 2019 13:06:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547240803; cv=none;
        d=google.com; s=arc-20160816;
        b=troyFXYc5aU5Rd5b24pe4dPHFHYnAgHEvwQxG2oTyDbgXe2J/IzYJ6MZeqcvgU6I10
         1sZBfj7e6lup9BrD4SLyzcgydeMBqPFNYzR5O6MVODY35/yT7lSKdSomJYW5fzpxuKv8
         exOtHMpld0AdPwdTmeisZUAfAhxqL+QaeGBC8oqP1+qUT9mFRPCu8HouxaKrGeam48Y4
         /at19LjD26++7CA3kinnUeRL1z0lrvG20BB9YcvLJvuELsANTIVEwp05S24nhBWiwXYy
         ZtygVilSJmL1EankncHkeB/LZnWXExfW4AJyf07AUrMKCSJnvaaVHJxDp6fL/GMYjHZ6
         RZwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=HDU1PDMdWvZWz0lbUz1AEBxnqbWSAiRzrxve2qVj3xg=;
        b=gZ/cMt3XEV42tknN8ErGrr3muvnC/92xqvQRWDucvt520KDyRmkiW0lJZiUA/wiGHu
         lPGhEWWuDR7F81p2I2Yf8FxPv9ITFltvEk8lzdAY6cf69NrfoZ9lQaiXOf+aNlxrzALd
         Z/wbkTDgRBxpeC8V1iHW8YQZeDYeolYOteExV2+eZqN4ddabtakcoMyquiVvobV2eRWf
         ILT/XNhuzEPytjfibPDqXHdRNsgSlZb5xaiN9pO4wJAk7wN2HBFb+hhfeSHDvOfkNa80
         PguEk+paIj/LtTUV+/IoeUIqLvp01fwMBbJlh1p/dUWRtnWePYpKUC/oCwsuqoshaNIp
         NL4A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="iS/86JjL";
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 3si4154052plo.102.2019.01.11.13.06.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 13:06:43 -0800 (PST)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="iS/86JjL";
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f51.google.com (mail-wr1-f51.google.com [209.85.221.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 94E27218E2
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 21:06:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1547240802;
	bh=6jQeBnq89TcqELbCmxN50WFICAEpyjYKrULbIaxa+Ck=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=iS/86JjLz3y3VpdiWB//3a4pu7zv+lE1+4CjwxgcFmTcYjtTN9DZqc3Y9whDvHuVi
	 /vOjeFe5NY12IngK0s7qo3LyG5+/TgKVfVxMpzdXsu6KRMUTUQDT4VlkINWets9dnF
	 3K2zM24EfGS05oZd9UlKU2V79qZPn6J9PnL7GlOE=
Received: by mail-wr1-f51.google.com with SMTP id r10so16613367wrs.10
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 13:06:42 -0800 (PST)
X-Received: by 2002:adf:ea81:: with SMTP id s1mr14599888wrm.309.1547240799072;
 Fri, 11 Jan 2019 13:06:39 -0800 (PST)
MIME-Version: 1.0
References: <cover.1547153058.git.khalid.aziz@oracle.com> <31fe7522-0a59-94c8-663e-049e9ad2bff6@intel.com>
 <7e3b2c4b-51ff-2027-3a53-8c798c2ca588@oracle.com> <8ffc77a9-6eae-7287-0ea3-56bfb61758cd@intel.com>
In-Reply-To: <8ffc77a9-6eae-7287-0ea3-56bfb61758cd@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 11 Jan 2019 13:06:27 -0800
X-Gmail-Original-Message-ID: <CALCETrXqJJq1LMxfBA=LK=PYc5Q7hgeDQGap38h1AUAQuF2VHA@mail.gmail.com>
Message-ID:
 <CALCETrXqJJq1LMxfBA=LK=PYc5Q7hgeDQGap38h1AUAQuF2VHA@mail.gmail.com>
Subject: Re: [RFC PATCH v7 00/16] Add support for eXclusive Page Frame Ownership
To: Dave Hansen <dave.hansen@intel.com>
Cc: Khalid Aziz <khalid.aziz@oracle.com>, Juerg Haefliger <juergh@gmail.com>, 
	Tycho Andersen <tycho@tycho.ws>, jsteckli@amazon.de, Andi Kleen <ak@linux.intel.com>, 
	Linus Torvalds <torvalds@linux-foundation.org>, liran.alon@oracle.com, 
	Kees Cook <keescook@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, 
	deepa.srinivasan@oracle.com, chris hyser <chris.hyser@oracle.com>, 
	Tyler Hicks <tyhicks@canonical.com>, "Woodhouse, David" <dwmw@amazon.co.uk>, 
	Andrew Cooper <andrew.cooper3@citrix.com>, Jon Masters <jcm@redhat.com>, 
	Boris Ostrovsky <boris.ostrovsky@oracle.com>, kanth.ghatraju@oracle.com, 
	Joao Martins <joao.m.martins@oracle.com>, Jim Mattson <jmattson@google.com>, 
	pradeep.vincent@oracle.com, John Haxby <john.haxby@oracle.com>, 
	Thomas Gleixner <tglx@linutronix.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
	Christoph Hellwig <hch@lst.de>, steven.sistare@oracle.com, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, 
	Peter Zijlstra <peterz@infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190111210627.teOATfx4NcM8MTpsnzUKbJ8uQyxMG5mWPRncpqQTySc@z>

On Fri, Jan 11, 2019 at 12:42 PM Dave Hansen <dave.hansen@intel.com> wrote:
>
> >> The second process could easily have the page's old TLB entry.  It could
> >> abuse that entry as long as that CPU doesn't context switch
> >> (switch_mm_irqs_off()) or otherwise flush the TLB entry.
> >
> > That is an interesting scenario. Working through this scenario, physmap
> > TLB entry for a page is flushed on the local processor when the page is
> > allocated to userspace, in xpfo_alloc_pages(). When the userspace passes
> > page back into kernel, that page is mapped into kernel space using a va
> > from kmap pool in xpfo_kmap() which can be different for each new
> > mapping of the same page. The physical page is unmapped from kernel on
> > the way back from kernel to userspace by xpfo_kunmap(). So two processes
> > on different CPUs sharing same physical page might not be seeing the
> > same virtual address for that page while they are in the kernel, as long
> > as it is an address from kmap pool. ret2dir attack relies upon being
> > able to craft a predictable virtual address in the kernel physmap for a
> > physical page and redirect execution to that address. Does that sound right?
>
> All processes share one set of kernel page tables.  Or, did your patches
> change that somehow that I missed?
>
> Since they share the page tables, they implicitly share kmap*()
> mappings.  kmap_atomic() is not *used* by more than one CPU, but the
> mapping is accessible and at least exists for all processors.
>
> I'm basically assuming that any entry mapped in a shared page table is
> exploitable on any CPU regardless of where we logically *want* it to be
> used.
>
>

We can, very easily, have kernel mappings that are private to a given
mm.  Maybe this is useful here.

