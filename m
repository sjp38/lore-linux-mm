Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B163BC43140
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 12:24:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 76791218AC
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 12:24:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sPVCnusf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76791218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 044E06B0007; Fri,  6 Sep 2019 08:24:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F369D6B0008; Fri,  6 Sep 2019 08:24:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E24C86B000A; Fri,  6 Sep 2019 08:24:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0237.hostedemail.com [216.40.44.237])
	by kanga.kvack.org (Postfix) with ESMTP id BBE566B0007
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 08:24:35 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 63C02824CA32
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 12:24:35 +0000 (UTC)
X-FDA: 75904414110.05.vein88_6235a046b350c
X-HE-Tag: vein88_6235a046b350c
X-Filterd-Recvd-Size: 5050
Received: from mail-lj1-f196.google.com (mail-lj1-f196.google.com [209.85.208.196])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 12:24:34 +0000 (UTC)
Received: by mail-lj1-f196.google.com with SMTP id d5so5804291lja.10
        for <linux-mm@kvack.org>; Fri, 06 Sep 2019 05:24:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=uEuqyoR6pX9WcKO2lv8Qx9uofetASJrnmmBj7HQZAO0=;
        b=sPVCnusfoWpyRZ2QVHQwTwTXqVDSLABe1kb/Mev99Hg2vqfHfoVLATzkVRi2+ZQlU/
         jUe4bKWmFENp+T5qqbKfZENo1l8dvYqIfw+OK9uKx8yblxrFiCq65laNMqVAldjVdmmu
         1GzOuoVP5R+l+wfB6mShSS7GmPqISpD/ueZPYKZfKCo4BCRz7iD18iYuQ9oIlLVoA3Ah
         /NpIXrmXWC8JrXAC3FFaQ/G2EWcWlJXui2gM4J+oZH/lDDSMKALFRDkn2EyJjthC+RdX
         ZLl3lqv9OoD5ojMhnCCfHGU7MR8CdPT6nkoAHaWC5Fw6UNvT81yS99ZKj8c7hFrkikKG
         +JZw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=uEuqyoR6pX9WcKO2lv8Qx9uofetASJrnmmBj7HQZAO0=;
        b=A0ZuhwrrQ+Zz/I6YSQh+5Y2MrHROqW3eXDrbcseJFJQYirHAXZgTTjVaZKmB4ydz5G
         vtuLE+nr52z4d3XQcvVOtwbUSS2F4J5mhrMCVCIKV+65BfGszZCQ892Nj4b1VT+6IBSz
         BXghurblD87DRnstEYwT+OQWJMu2dcnaT7Bf/gBQitFyyLj+lFo2xRMdXbocvHJ1lwPv
         o1nTAMMDfWUDswMtx9URKLv3ALCqEJjk+/Yy07hdrnjv6/rdeUm3dHBvxnwyyCq/LF8J
         aBnlq+lnfQQCxAj8Hg7xv551A0edvUtCM8uaaf8dJ8bpptJjtSWVGRvrPwk+KfjWtXN9
         c7WQ==
X-Gm-Message-State: APjAAAWW3a63oS8l6RcPcw0zrPC2usPz/x1BL0l2Z0TPF0sKf4RS+M8M
	2RboKGCihBQIOa8GVixEgZbNA4Pz9sxKd/s9APg=
X-Google-Smtp-Source: APXvYqygEaAWPMGIe4tWR6VpyFc1DI2SYZ2tryPFQlAxF5bTrdZ+Bc90vgs+nITDv56N7g83GkVN1pcDuglS9Aq6kkY=
X-Received: by 2002:a2e:9104:: with SMTP id m4mr5521513ljg.28.1567772673112;
 Fri, 06 Sep 2019 05:24:33 -0700 (PDT)
MIME-Version: 1.0
References: <1567708980-8804-1-git-send-email-jrdr.linux@gmail.com> <20190905185910.GS29434@bombadil.infradead.org>
In-Reply-To: <20190905185910.GS29434@bombadil.infradead.org>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Fri, 6 Sep 2019 17:54:21 +0530
Message-ID: <CAFqt6zZ_M3_Jr_08SO+OnnurWNbLJJsNZvVDZOnjh88vzaiXGg@mail.gmail.com>
Subject: Re: [PATCH] mm/memory.c: Convert to use vmf_error()
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ralph Campbell <rcampbell@nvidia.com>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Michal Hocko <mhocko@suse.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, 
	Peter Zijlstra <peterz@infradead.org>, airlied@redhat.com, 
	Thomas Hellstrom <thellstrom@vmware.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 6, 2019 at 12:29 AM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Fri, Sep 06, 2019 at 12:13:00AM +0530, Souptick Joarder wrote:
> > +++ b/mm/memory.c
> > @@ -1750,13 +1750,10 @@ static vm_fault_t __vm_insert_mixed(struct vm_area_struct *vma,
> >       } else {
> >               return insert_pfn(vma, addr, pfn, pgprot, mkwrite);
> >       }
> > -
> > -     if (err == -ENOMEM)
> > -             return VM_FAULT_OOM;
> > -     if (err < 0 && err != -EBUSY)
> > -             return VM_FAULT_SIGBUS;
> > -
> > -     return VM_FAULT_NOPAGE;
> > +     if (!err || err == -EBUSY)
> > +             return VM_FAULT_NOPAGE;
> > +     else
> > +             return vmf_error(err);
> >  }
>
> My plan is to convert insert_page() to return a VM_FAULT error code like
> insert_pfn() does.  Need to finish off the vm_insert_page() conversions
> first ;-)

Previously we have problem while converting vm_insert_page() to return
vm_fault_t.

vm_insert_page() is called from different drivers. Some of them are
already converted
to use vm_map_pages()/ vm_map_pages_zero(). But still we left with few users.

drivers/media/usb/usbvision/usbvision-video.c#L1045
mm/vmalloc.c#L2969

These 2 can be converted with something like vm_map_vmalloc_pages().
I am working on it. Will post it in sometime.

drivers/android/binder_alloc.c#L259 (have objection)
drivers/infiniband/hw/efa/efa_verbs.c#L1701
drivers/infiniband/hw/mlx5/main.c#L2085 (have objection as using
vm_map_pages_zero() doesn't make sense)
drivers/xen/gntalloc.c#L548 (have limitation)
kernel/kcov.c#L297 (have objection)
net/ipv4/tcp.c#L1799
net/packet/af_packet.c#L4453

But these are the places where replacing vm_insert_page() is bit
difficult/ have objection.
In some cases, maintainers/ reviewers will not agree to replace
vm_insert_page().

In  other scenario, if we change return type of vm_insert_page() to vm_fault_t,
we end up with adding few lines of conversion code from vm_fault_t to errno
in drivers which is not a correct way to go with.

Any suggestion, how to solve this ?

