Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61DEDC43381
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 20:56:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0BDE420857
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 20:56:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="W10vcUCU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0BDE420857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 934386B0003; Mon,  1 Apr 2019 16:56:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E4636B0005; Mon,  1 Apr 2019 16:56:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7FAC86B0007; Mon,  1 Apr 2019 16:56:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5C89C6B0003
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 16:56:43 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id l140so745484ita.4
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 13:56:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=AT3+Y+13K2Cpfxn61ywWivlGpkV37QTXmmh6edUQOcE=;
        b=rkOeLd2jitSL2NvoAgMMgk/dHSeHMdBy0VC2XUK5kra0v0don/9/1NaKxGZJeDeKVx
         7HXsMdKgcb/djsE0/ck7rE+riAaLcUasrB7PVlHRxS1GhUvcKOHvw0Q+ayz/4RQthbis
         kxUZrGF2Ta14okz4vy3liYw6TTxOB3PHdFf32pQb3ys8CX/4Am9Y34WuJwMs7Ps9icp+
         yY2z1E/9bffPA4IB6LSLajMUtBGQ9C3vHgVUfxVu8ZpL101CoWFVwq83t1e38hRV6cs2
         PhxYkS8zEYffX/6XW11lyn9HkUfkesRDiYwQkhm6OVMDONnUIh146XAFrbt4/gI3c4UB
         N1Dw==
X-Gm-Message-State: APjAAAW72tWYUrR56KYMZnf4BxqIg3JNSWsff6HYXAUORNr7kV+fVN4w
	8XDTZUTWUV8voN8FQUgBKBPIZpZqPI5bJPnBHAefOhmZPkYx7Eo0YFczpxNeuFqcAynCfkbVBBq
	96X6Ryj/MBsooru+JmB+FIRTR3B7F0+Uy0AZn5/17qH2gkTn2ceN1mqbb2AWMDcUJ+w==
X-Received: by 2002:a02:6019:: with SMTP id i25mr26277243jac.66.1554152203136;
        Mon, 01 Apr 2019 13:56:43 -0700 (PDT)
X-Received: by 2002:a02:6019:: with SMTP id i25mr26277197jac.66.1554152202144;
        Mon, 01 Apr 2019 13:56:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554152202; cv=none;
        d=google.com; s=arc-20160816;
        b=KnIZnMPLVA0ateOLDmgvMNOVNp2hEn5nc4+zU00xxg0TMoezn528GtPLku04wcFTFW
         FadvfgD8YOXz33UiAI19Tz/sF3MZLNhx4bYYhMRQXzsxtKClvafww/7LiTw5mymsBr8+
         XO+eFH4iydO2pDtEn7WL4Gp5zdaJbdS82BukBJ+hHAAzuGG07fcH8zS5H43yaX33BmtG
         JlQF7xXJ2Kik/a57hwDeWgPPEsKWhTHI/ZKR8SiGuudXrBN1Iz7FH1eO0ARkd4Wg2zP9
         2ubgWDZlmm6lehGBtLvmv007A48NL6tRRM5igzkuunMEyn1J6j68PcFQj4REcrHx8CNO
         MGVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=AT3+Y+13K2Cpfxn61ywWivlGpkV37QTXmmh6edUQOcE=;
        b=NhLp5jFeuUahEeN+7vVu1nkk/XMDSoRTIawBdwDFR0q/90w5oW1VWbQezc3A8GFPcI
         hXT0Dh7Exo/PAQBLzpDQ4twDPcR1/LVCgDf2/QKrR5u1nz6hOySIU5Ddq35d0Ri43FV0
         qQVrDwOg7c3Rm3ywUanVfsi6a13ORLhS0efpHBgDXsYKqEU3zYm4AoQ2gPNgTi69SUFd
         zSsCjWT7boE5fqJBKh8V/btOPx/5MFX512aOw4GfsbXCIKmsczNVqF6B7EcTGfTo2VC+
         WgPxy8+oLiW6ziYVPpE8VxluD14U3fk0Wt6mpKm0nsyC/6AyIFrdiZpamqmRRvYiAxVG
         7qwA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=W10vcUCU;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i9sor11298085itb.34.2019.04.01.13.56.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Apr 2019 13:56:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=W10vcUCU;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=AT3+Y+13K2Cpfxn61ywWivlGpkV37QTXmmh6edUQOcE=;
        b=W10vcUCUuNW1SvLmkUv5TN0rM6YlxTZNQHJlOVFW6lFlV6+7A7UiFbLhHsCF3kunLF
         sGG53Tf/H/Ug1a3d4q44Ic7BoAgN1iw2sEeeMjNaB7QdSagIUpwzc/3Pc1o+X2/CuFBD
         migPFwxO+q0sQAUSL9GNPgyok5+pfEYxGPZq0AotXywWvFhm/25T6S10XepBLJHr7vcb
         wZBCW/RvB8GVAVVzQ4UehYd535fsDGlaKBv+JFU3wzBEQvA0wuccZZPpFAHFxmFsAYkJ
         wHkSkJ1K3WAZ3l3S40zRQV3EtZdwF/Uh9qBSXZHmpCgzpph9XbQ0CqKWsd48lqZrd/dW
         /z4A==
X-Google-Smtp-Source: APXvYqxPdFADHjAK+0CFde23ZbwoLf1eXIIt4cdtDXo08VhKkesuIbGveqz+tqbUfBYlEaVHfcg+WTsTVB9Qcl5JDSk=
X-Received: by 2002:a24:7c52:: with SMTP id a79mr1507399itd.51.1554152201716;
 Mon, 01 Apr 2019 13:56:41 -0700 (PDT)
MIME-Version: 1.0
References: <20190329084058-mutt-send-email-mst@kernel.org>
 <f6332928-d6a4-7a75-245d-2c534cf6e710@redhat.com> <20190329104311-mutt-send-email-mst@kernel.org>
 <7a3baa90-5963-e6e2-c862-9cd9cc1b5f60@redhat.com> <f0ee075d-3e99-efd5-8c82-98d53b9f204f@redhat.com>
 <20190329125034-mutt-send-email-mst@kernel.org> <fb23fd70-4f1b-26a8-5ecc-4c14014ef29d@redhat.com>
 <20190401073007-mutt-send-email-mst@kernel.org> <29e11829-c9ac-a21b-b2f1-ed833e4ca449@redhat.com>
 <dc14a711-a306-d00b-c4ce-c308598ee386@redhat.com> <20190401104608-mutt-send-email-mst@kernel.org>
In-Reply-To: <20190401104608-mutt-send-email-mst@kernel.org>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Mon, 1 Apr 2019 13:56:30 -0700
Message-ID: <CAKgT0UcJuD-t+MqeS9geiGE1zsUiYUgZzeRrOJOJbOzn2C-KOw@mail.gmail.com>
Subject: Re: On guest free page hinting and OOM
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: David Hildenbrand <david@redhat.com>, Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com, pagupta@redhat.com, 
	wei.w.wang@intel.com, Yang Zhang <yang.zhang.wz@gmail.com>, 
	Rik van Riel <riel@surriel.com>, dodgen@google.com, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com, 
	Andrea Arcangeli <aarcange@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 1, 2019 at 7:47 AM Michael S. Tsirkin <mst@redhat.com> wrote:
>
> On Mon, Apr 01, 2019 at 04:11:42PM +0200, David Hildenbrand wrote:
> > > The interesting thing is most probably: Will the hinting size usually be
> > > reasonable small? At least I guess a guest with 4TB of RAM will not
> > > suddenly get a hinting size of hundreds of GB. Most probably also only
> > > something in the range of 1GB. But this is an interesting question to
> > > look into.
> > >
> > > Also, if the admin does not care about performance implications when
> > > already close to hinting, no need to add the additional 1Gb to the ram size.
> >
> > "close to OOM" is what I meant.
>
> Problem is, host admin is the one adding memory. Guest admin is
> the one that knows about performance.

The thing we have to keep in mind with this is that we are not dealing
with the same behavior as the balloon driver. We don't need to inflate
a massive hint and hand that off. Instead we can focus on performing
the hints on much smaller amounts and do it incrementally over time
with the idea being as the system sits idle it frees up more and more
of the inactive memory on the system.

With that said, I still don't like the idea of us even trying to
target 1GB of RAM for hinting. I think it would be much better if we
stuck to smaller sizes and kept things down to a single digit multiple
of THP or higher order pages. Maybe something like 64MB of total
memory out for hinting.

All we really would need to make it work would be to possibly look at
seeing if we can combine PageType values. Specifically what I would be
looking at is a transition that looks something like Buddy -> Offline
-> (Buddy | Offline). We would have to hold the zone lock at each
transition, but that shouldn't be too big of an issue. If we are okay
with possibly combining the Offline and Buddy types we would have a
way of tracking which pages have been hinted and which have not. Then
we would just have to have a thread running in the background on the
guest that is looking at the higher order pages and pulling 64MB at a
time offline, and when the hinting is done put them back in the "Buddy
| Offline" state.

I view this all as working not too dissimilar to how a standard Rx
ring in a network device works. Only we would want to allocate from
the pool of "Buddy" pages, flag the pages as "Offline", and then when
the hint has been processed we would place them back in the "Buddy"
list with the "Offline" value still set. The only real changes needed
to the buddy allocator would be to add some logic for clearing/merging
the "Offline" setting as necessary, and to provide an allocator that
only works with non-"Offline" pages.

