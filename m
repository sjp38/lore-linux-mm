Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78F29C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 20:32:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2615B2075E
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 20:32:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="obydRoeE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2615B2075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A65696B0273; Tue,  2 Apr 2019 16:32:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A15176B0274; Tue,  2 Apr 2019 16:32:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 92AC86B0275; Tue,  2 Apr 2019 16:32:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 741D56B0273
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 16:32:16 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id s21so3953758ite.6
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 13:32:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=tc8hZ8L4fi++Tw9DLZC3eVfYKxd9pX9rhYuoyQAvDdY=;
        b=h6+PFhsX+g/9GOfObZG4nNcqPysPRN6rTV8Kjmy8BN3TwTN3WZkWtlsXrfQTqpMeGK
         LMK0/2Fbiu0EFQH2H2CNJ3fZkuCyq+ed/eaBdlKeCcRFWLembCnrNv6nC5p95JCGBmGw
         amjDarhs+dijOtckT8hfdQFJjYzl9EyQqtfzzWXr2oeWZ/J+5tvpJT4NMD6MY3Sp22N9
         vL7Mj0CQmJitDu+b6tDnH9hMiDSs0KwIODV1GawjAq0O1Vdz2KkAL+l9miNuc200LI8Y
         1Vw/t0OWSenAAvenNRagAZjiR6beyGiwkKxJmxNxEcPf65RaMnzMwtUTMeuOUNO+rFH/
         6yrw==
X-Gm-Message-State: APjAAAWMk8TyrtCo17vWc+hZtb+sJtcYf04OT0ZHO04DdWJ7skuvSgW9
	LwVUXzLavnVPse5cwqxA6r5NlFqpelOzohJXoq4fYwtmSfXRjGnT2FDPvazUcjxviyoGrHFdypu
	Im/sxn1JTopOgJNzqjMNxRzgCqcs1B3qtRG0lmj4DtoiCllRHc3hpepBnzGZz73hSaw==
X-Received: by 2002:a24:424a:: with SMTP id i71mr5897122itb.135.1554237135463;
        Tue, 02 Apr 2019 13:32:15 -0700 (PDT)
X-Received: by 2002:a24:424a:: with SMTP id i71mr5897092itb.135.1554237134817;
        Tue, 02 Apr 2019 13:32:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554237134; cv=none;
        d=google.com; s=arc-20160816;
        b=Vw6NDRTxH/maZT29lrB+gHj1wv9DKbyvEilgEEtlthxlKuVxj3rpVyQwi2kXZhZUdY
         bHuCV5MSjBeW9V+LEy0n0K+WfpQqlB0WSFmsxVawtsdOceM5dZgSQgWc8D8LHs60INUG
         mzLE7E1Jskj/+2Q0Kkm4ciJzY0teIiDm/EPmp4qML6int5ubcLXjoo1Ng693RquA9iwf
         9RYbu9Obg2r9zSq8sBvc+Cz1wHS7WHg6wCyn23PhqegBkpZtoMES7v3q3vWcSAVzIsK9
         GVoISwpG/1Is1CxXUpyTzPJNVgnZn2BGrn6NPuVye8zJ6NkxaH8iFUrVyGqi26qeQsYf
         gieQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=tc8hZ8L4fi++Tw9DLZC3eVfYKxd9pX9rhYuoyQAvDdY=;
        b=RAnKq9KEH7/YBxIoW+nj/jwTIt+iq8Mpknhn1+N0emuhOLM75Z6lmASOT9pYmIJ2gd
         y6ipX+vQ2SiIGV4khNbVHzu64fMQTsbzVxqEzMdHlzn9SNvGt5r1uYpyRlsDnk8L+iTV
         hTEU+nl75EPj6w4PxFVdklSzZcIEjWupUdyITsF8pbJs2bjb9J1MNENK0BzRoQHFX5qO
         zfrJxDXyzrmZiDcuGHhuqDgaB6dEozceW23wBKBc9l+BowCyLaU5lwpoeuGuspHfKS9h
         Z2zJ5/QFqdPFDfWyDyIQZPTm2GOThBt56JqB4ySdy6bUeRmVsOWPgKZfpn0IrlhqE0dA
         6LJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=obydRoeE;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k184sor7832200itb.31.2019.04.02.13.32.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Apr 2019 13:32:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=obydRoeE;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=tc8hZ8L4fi++Tw9DLZC3eVfYKxd9pX9rhYuoyQAvDdY=;
        b=obydRoeEGZnksP9jGuzxEUd2LyttqTQ2VETVqPXmM4wAYfnphVjfMih2mLqbJoIdR2
         dGMx5GcmRJDkFrndo0+wJfhVUVLWyD55SB4dX/3ij2kNPWne5pnutCUU4eMobhcW0WMR
         SWFMjxyLfOgEH84bPK/rV4XDQupb4/83BNMzeUJJLBgD8PG0DevnjydxXTnHHETQc87B
         Ocd5QpAzQ9NfF07daUzLZ3J9hnjz4Vy/NmqzlVIR5YOHtkFfGf8Wpibo7VHP4c4BaGr7
         At8YCrFhTm/etCxfjb7ezt4EJiKdBSsXtlckoO5OW7tFQW3zxJC1HdgxgFiMyNKjwRO7
         1UGQ==
X-Google-Smtp-Source: APXvYqxC1u78KAXj8zZQ3IqH24rndQYPRU5w27rDMpCPRpJr/Q00SxbPZ9VNpm2UZeX41ObAYByqBsJ8PtxwORJ5BF8=
X-Received: by 2002:a05:660c:243:: with SMTP id t3mr5942207itk.124.1554237134400;
 Tue, 02 Apr 2019 13:32:14 -0700 (PDT)
MIME-Version: 1.0
References: <dc14a711-a306-d00b-c4ce-c308598ee386@redhat.com>
 <20190401104608-mutt-send-email-mst@kernel.org> <CAKgT0UcJuD-t+MqeS9geiGE1zsUiYUgZzeRrOJOJbOzn2C-KOw@mail.gmail.com>
 <6a612adf-e9c3-6aff-3285-2e2d02c8b80d@redhat.com> <CAKgT0Ue_By3Z0=5ZEvscmYAF2P40Bdyo-AXhH8sZv5VxUGGLvA@mail.gmail.com>
 <20190402112115-mutt-send-email-mst@kernel.org> <3dd76ce6-c138-b019-3a43-0bb0b793690a@redhat.com>
 <CAKgT0Uc78NYnva4T+G5uas_iSnE_YHGz+S5rkBckCvhNPV96gw@mail.gmail.com>
 <6b0a3610-0e7b-08dc-8b5f-707062f87bea@redhat.com> <CAKgT0UdHA66z1j=3H06AfgtiF4ThFdXwQ6i8p1MszdL2bRHeZQ@mail.gmail.com>
 <20190402134722-mutt-send-email-mst@kernel.org>
In-Reply-To: <20190402134722-mutt-send-email-mst@kernel.org>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 2 Apr 2019 13:32:03 -0700
Message-ID: <CAKgT0UeZE29qBOAxDb2EmLr_hr1_W-m3Rw3gKs-UAPbD80K_+Q@mail.gmail.com>
Subject: Re: On guest free page hinting and OOM
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: David Hildenbrand <david@redhat.com>, Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com, pagupta@redhat.com, 
	Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>, dodgen@google.com, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com, 
	Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 2, 2019 at 10:53 AM Michael S. Tsirkin <mst@redhat.com> wrote:
>
> On Tue, Apr 02, 2019 at 10:45:43AM -0700, Alexander Duyck wrote:
> > We went through this back in the day with
> > networking. Adding more buffers is not the solution. The solution is
> > to have a way to gracefully recover and keep our hinting latency and
> > buffer bloat to a minimum.
>
> That's an interesting approach, I think that things that end up working
> well are NAPI (asychronous notifications), limited batching, XDP (big
> aligned buffers) and BQL (accounting). Is that your perspective too?
>

Yes, that is kind of what I was getting at.

Basically we could have a kthread running somewhere that goes through
and pulls something like 64M of pages out of the MAX_ORDER - 1
freelist, does what is necessary to isolate them, puts them on a queue
somewhere, kicks the virtio ring, and waits for the response to come
back indicating that the hints have been processed. We would just have
to keep it running until the list doesn't have enough non-"Offline"
memory to fulfill the request. Then we just wait until we again reach
a level necessary to justify waking the thread back up and repeat.

In my mind it looks a lot like your standard Rx ring in that we
allocate some fixed number of buffers and wait for hardware to tell us
when the buffers are ready. The only extra complexity is having to add
tracking using the PageType "Offline" bit which should be cheap when
we are already having to manipulate the "Buddy" PageType anyway.

It would let us get away from having to do the per-cpu queues and
complicated coordination logic to translate free pages to their buddy.

