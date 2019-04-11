Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15750C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 20:54:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C63222184B
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 20:54:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="iaIquvyL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C63222184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 690BB6B0269; Thu, 11 Apr 2019 16:54:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63E3C6B026A; Thu, 11 Apr 2019 16:54:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 52F586B026B; Thu, 11 Apr 2019 16:54:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2E32A6B0269
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 16:54:13 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id w7so5270701ybp.13
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 13:54:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=mjcGkq0ThHXR8z8Gn+yNWN//rh9kKOgwfdqe4C4W07c=;
        b=tMZWo+WJSLM4kXM8gAVm5IYWV0c8T5dHbsJEU1uIDfL+uMGN5P4zWpsUByTLx7So8Z
         BukjGIMpel10jIdFvKPQ4381m0nM4wBykwE4GTAJZvIpJY60aBKmiSBeX33hsJFm9qwN
         CtBk1XXxDbmOcAAeZuftVVTQjBo+9BKBFcWz736urmNHTsYFpTiUcaODs95AeYuCHHqO
         jd6Ht9ii9BJZeh0WHBJFhzYjO6REXhidqZq0HvJ8IhgPvhc6CF4nyMwxtN7RvW8N+hxm
         /LOmUhAfrb4cNbfDUrGoF4XvzkjEQyJpAya+5y044xFAGiPyp7KhnSJhwP8++DlG3vuu
         98pQ==
X-Gm-Message-State: APjAAAUkK1D43h46xhZ+JHXOryp5qFaV/IleeN/v1xKyv8eB+CJyiJB1
	aLWNhAdycXujTQLDn8ZDuqqVXHuJDY0EkkcQqd/e33UqAsuB59sectCZZSbBHXa1xPowRaKPVJX
	60ScWXCGhGVyiWNwmu3chPY6bo0X+TFS5iTWn4zFjCF9Q7URlhFOeciwP0e0oeWwKPg==
X-Received: by 2002:a25:b004:: with SMTP id q4mr42591147ybf.34.1555016052904;
        Thu, 11 Apr 2019 13:54:12 -0700 (PDT)
X-Received: by 2002:a25:b004:: with SMTP id q4mr42591110ybf.34.1555016052216;
        Thu, 11 Apr 2019 13:54:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555016052; cv=none;
        d=google.com; s=arc-20160816;
        b=JyPIkyhxO5gCj1ZLOS97EgnBED32B10p2Ys28a5yn3uDqo0EOUGyBovyvUsi/2KGsh
         CV0PMy+u6/u9xV+C3+JpDXdcZWYjObahVEx/gSrZ+St5ej6L3WVZTU/bZtHndFUEM9iW
         nbRiQQ6QrKXrgpn8V+Lua91eCMLDzbmpdEN5ZMeXgswKpC9eT3CB0SMzz02fZfYwDm6n
         iVKVK2+8LURwMqZWH7zs2P7LpLMZKx7aM4AOQ7PbSuq6kwN2hd4kUiqlxIo3BaN2lA+J
         24HSd7FxLfKY1S2IT1gK1ExfRiJIajPhGzK3pn9MKkDPQrftfdtBzQljSyRZwYfqnLkR
         W9cw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=mjcGkq0ThHXR8z8Gn+yNWN//rh9kKOgwfdqe4C4W07c=;
        b=R6avjIg66IliXHtTDrINjrtki8+kdLf1/DAcCE8q5xb/RG+shdJ4Jv2v5wg9onh1JI
         U17DYGUTBXEu0WPLgM89/24kTh/Su9JLavcrE8qVXsQ6RiblEk3LZ1QpXDr/c56HKEKQ
         PcNGVkFguJ0c8n8SfuQZ48CgzaxUNIHLFSyNvu+vCsyWaesOnwl7WBUKbJrPXnetjXXK
         0IEarLy0tc3ld+8iP3YN36WJi+ZHL94XiMkSoWLM8B26vs5VU+Paxv9IiJOe4bf5lYbV
         2h/nsPGpXolFZ+qog+KU3ljiMwTqCBbyPz5iyBpMYq7DYL6qpshy7xy5QwSudK4cZmfF
         b0gQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=iaIquvyL;
       spf=pass (google.com: domain of groeck@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 125sor9718671ybm.194.2019.04.11.13.54.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 13:54:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of groeck@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=iaIquvyL;
       spf=pass (google.com: domain of groeck@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=mjcGkq0ThHXR8z8Gn+yNWN//rh9kKOgwfdqe4C4W07c=;
        b=iaIquvyLqd7wLNVw1PX9hcVTfBK0jdts+OLXHRzY8EMNbzaYuo+dE1I1AGN5IHQh8f
         adWzezztXAyzEIvK9/FIWyE56RWVsAhwE8RaZuwpNzmYTQgI9HW1LrGw9MLBdrStJ3MG
         19hoLZBZVZxwE3jhTkmssKN2b2lJjaqiMzFz+M2TfRVkvvJfm4jYtthsixa6bFr2thK6
         yU0wl2QS/HRVFSyAzp4RX8dfZ2Gh+1EB2nG9/OD1Loym5ZzXi3VlgxulbQzfcNrygP1m
         Lp2fgAwPvZqEMQnWYAbqU5LO9bDXklO/6kD3gmlEWDnMceIdNafu248Hpz/GM6dvOUdT
         ewdQ==
X-Google-Smtp-Source: APXvYqyNXODOXnsXBh6Ic9JgOpk1LrGIazsxDmYWmIrQQEBp50RmzfENOooW5jzzjboHz4qQDS/7T75uvNedJWIK+0A=
X-Received: by 2002:a25:8106:: with SMTP id o6mr44113476ybk.53.1555016051682;
 Thu, 11 Apr 2019 13:54:11 -0700 (PDT)
MIME-Version: 1.0
References: <20190215185151.GG7897@sirena.org.uk> <20190226155948.299aa894a5576e61dda3e5aa@linux-foundation.org>
 <CAPcyv4ivjC8fNkfjdFyaYCAjGh7wtvFQnoPpOcR=VNZ=c6d6Rg@mail.gmail.com>
 <20190228151438.fc44921e66f2f5d393c8d7b4@linux-foundation.org>
 <CAPcyv4hDmmK-L=0txw7L9O8YgvAQxZfVFiSoB4LARRnGQ3UC7Q@mail.gmail.com>
 <026b5082-32f2-e813-5396-e4a148c813ea@collabora.com> <20190301124100.62a02e2f622ff6b5f178a7c3@linux-foundation.org>
 <3fafb552-ae75-6f63-453c-0d0e57d818f3@collabora.com> <CAPcyv4hMNiiM11ULjbOnOf=9N=yCABCRsAYLpjXs+98bRoRpCA@mail.gmail.com>
 <36faea07-139c-b97d-3585-f7d6d362abc3@collabora.com> <20190306140529.GG3549@rapoport-lnx>
 <21d138a5-13e4-9e83-d7fe-e0639a8d180a@collabora.com> <CAPcyv4jBjUScKExK09VkL8XKibNcbw11ET4WNUWUWbPXeT9DFQ@mail.gmail.com>
 <CAGXu5jLAPKBE-EdfXkg2AK5P=qZktW6ow4kN5Yzc0WU2rtG8LQ@mail.gmail.com>
 <CABXOdTdVvFn=Nbd_Anhz7zR1H-9QeGByF3HFg4ZFt58R8=H6zA@mail.gmail.com>
 <CAGXu5j+Sw2FyMc8L+8hTpEKbOsySFGrCmFtVP5gt9y2pJhYVUw@mail.gmail.com>
 <CABXOdTcXWf9iReoocaj9rZ7z17zt-62iPDuvQQSrQRtMeeZNiA@mail.gmail.com> <CAPcyv4i8xhA6B5e=YBq2Z5kooyUpYZ8Bv9qov-mvqm4Uz=KLWQ@mail.gmail.com>
In-Reply-To: <CAPcyv4i8xhA6B5e=YBq2Z5kooyUpYZ8Bv9qov-mvqm4Uz=KLWQ@mail.gmail.com>
From: Guenter Roeck <groeck@google.com>
Date: Thu, 11 Apr 2019 13:53:59 -0700
Message-ID: <CABXOdTc5=J7ZFgbiwahVind-SNt7+G_-TVO=v-Y5SBVPLdUFog@mail.gmail.com>
Subject: Re: next/master boot bisection: next-20190215 on beaglebone-black
To: Dan Williams <dan.j.williams@intel.com>
Cc: Kees Cook <keescook@chromium.org>, kernelci@groups.io, 
	Guillaume Tucker <guillaume.tucker@collabora.com>, Mike Rapoport <rppt@linux.ibm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Mark Brown <broonie@kernel.org>, Tomeu Vizoso <tomeu.vizoso@collabora.com>, 
	Matt Hart <matthew.hart@linaro.org>, Stephen Rothwell <sfr@canb.auug.org.au>, 
	Kevin Hilman <khilman@baylibre.com>, 
	Enric Balletbo i Serra <enric.balletbo@collabora.com>, Nicholas Piggin <npiggin@gmail.com>, 
	Dominik Brodowski <linux@dominikbrodowski.net>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, Adrian Reber <adrian@lisas.de>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, 
	Linux MM <linux-mm@kvack.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, 
	Richard Guy Briggs <rgb@redhat.com>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, info@kernelci.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 1:22 PM Dan Williams <dan.j.williams@intel.com> wrote:
>
> On Thu, Apr 11, 2019 at 1:08 PM Guenter Roeck <groeck@google.com> wrote:
> >
> > On Thu, Apr 11, 2019 at 10:35 AM Kees Cook <keescook@chromium.org> wrote:
> > >
> > > On Thu, Apr 11, 2019 at 9:42 AM Guenter Roeck <groeck@google.com> wrote:
> > > >
> > > > On Thu, Apr 11, 2019 at 9:19 AM Kees Cook <keescook@chromium.org> wrote:
> > > > >
> > > > > On Thu, Mar 7, 2019 at 7:43 AM Dan Williams <dan.j.williams@intel.com> wrote:
> > > > > > I went ahead and acquired one of these boards to see if I can can
> > > > > > debug this locally.
> > > > >
> > > > > Hi! Any progress on this? Might it be possible to unblock this series
> > > > > for v5.2 by adding a temporary "not on ARM" flag?
> > > > >
> > > >
> > > > Can someone send me a pointer to the series in question ? I would like
> > > > to run it through my testbed.
> > >
> > > It's already in -mm and linux-next (",mm: shuffle initial free memory
> > > to improve memory-side-cache utilization") but it gets enabled with
> > > CONFIG_SHUFFLE_PAGE_ALLOCATOR=y (which was made the default briefly in
> > > -mm which triggered problems on ARM as was reverted).
> > >
> >
> > Boot tests report
> >
> > Qemu test results:
> >     total: 345 pass: 345 fail: 0
> >
> > This is on top of next-20190410 with CONFIG_SHUFFLE_PAGE_ALLOCATOR=y
> > and the known crashes fixed.
>
> In addition to CONFIG_SHUFFLE_PAGE_ALLOCATOR=y you also need the
> kernel command line option "page_alloc.shuffle=1"
>
> ...so I doubt you are running with shuffling enabled. Another way to
> double check is:
>
>    cat /sys/module/page_alloc/parameters/shuffle

Yes, you are right. Because, with it enabled, I see:

Kernel command line: rdinit=/sbin/init page_alloc.shuffle=1 panic=-1
console=ttyAMA0,115200 page_alloc.shuffle=1
------------[ cut here ]------------
WARNING: CPU: 0 PID: 0 at ./include/linux/jump_label.h:303
page_alloc_shuffle+0x12c/0x1ac
static_key_enable(): static key 'page_alloc_shuffle_key+0x0/0x4' used
before call to jump_label_init()
Modules linked in:
CPU: 0 PID: 0 Comm: swapper Not tainted
5.1.0-rc4-next-20190410-00003-g3367c36ce744 #1
Hardware name: ARM Integrator/CP (Device Tree)
[<c0011c68>] (unwind_backtrace) from [<c000ec48>] (show_stack+0x10/0x18)
[<c000ec48>] (show_stack) from [<c07e9710>] (dump_stack+0x18/0x24)
[<c07e9710>] (dump_stack) from [<c001bb1c>] (__warn+0xe0/0x108)
[<c001bb1c>] (__warn) from [<c001bb88>] (warn_slowpath_fmt+0x44/0x6c)
[<c001bb88>] (warn_slowpath_fmt) from [<c0b0c4a8>]
(page_alloc_shuffle+0x12c/0x1ac)
[<c0b0c4a8>] (page_alloc_shuffle) from [<c0b0c550>] (shuffle_store+0x28/0x48)
[<c0b0c550>] (shuffle_store) from [<c003e6a0>] (parse_args+0x1f4/0x350)
[<c003e6a0>] (parse_args) from [<c0ac3c00>] (start_kernel+0x1c0/0x488)
[<c0ac3c00>] (start_kernel) from [<00000000>] (  (null))

I'll re-run the test, but I suspect it will drown in warnings.

Guenter

