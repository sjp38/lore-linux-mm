Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2EBABC7618F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 20:34:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CBE3621019
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 20:34:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QrW2+V7X"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBE3621019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BD216B000A; Thu, 18 Jul 2019 16:34:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 794A58E0003; Thu, 18 Jul 2019 16:34:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6AB4B8E0001; Thu, 18 Jul 2019 16:34:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4962B6B000A
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 16:34:16 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id k13so24309484qkj.4
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 13:34:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=lUeG90JN23owse4hkCx6s3PvuPmRRtzpsafpqQdcTUA=;
        b=jGW3r+/2PetZbLush4RoHyXtL1mVo7rtBqK0q5tIbINIapg4uZT/cHwkr44QbDEGX8
         IgOkHHwRLLosUtwumzWrz8RqW8eftdaxo8+RDPbZHV5Q/e4KrkYLK9hiRTTV1+BkZBVj
         3bCubo0+tt03aNilKDSYLbyk3yX+mfYxNfjy7TeuxrEkPYZlq0l4oTDQYI38jS1gevhD
         ZiDw5/7cTghDQTwTdkIw1aMEL1TZ+jjZOdJvUJWaMFbxieqsFOfFGaehzzv08pnc/yUx
         OagdwJXc5vMI1lE3bH9/sVyCSOfjtUaRvhqpWeJJwxjkkS3BHV2aPcQOMr7dqX9+1Ejz
         Al6w==
X-Gm-Message-State: APjAAAUiydLDb5AMOdjeSpFa9WoeOLmbo5zoQqSeW6DGO2GC26dDpM0/
	MKAIuoTOFgBf31JBNG797ILsjn9IvU7TVe+yScT6vuoVQStqy54Wv90KLgrCm0sclAcZto+TfYW
	21tSqt/bZhhhTQb2eMeBLXRlns09AUq8m+tQJfUD1rrhczHla2uJBuZ0E2hwl9DSEuA==
X-Received: by 2002:a37:ad0f:: with SMTP id f15mr31587530qkm.68.1563482055999;
        Thu, 18 Jul 2019 13:34:15 -0700 (PDT)
X-Received: by 2002:a37:ad0f:: with SMTP id f15mr31587507qkm.68.1563482055497;
        Thu, 18 Jul 2019 13:34:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563482055; cv=none;
        d=google.com; s=arc-20160816;
        b=BWUn97nI4nv5N+3wU5uXGncmosFKU2RNHo60+sQkzrsZf7DIWh9jjmoqCzvvvKyql1
         qTYIwrSve9tc4liB3N2CvWTdzuayzaf48QCY/6IHjgNomzdfrZZo0qr4Izu7H3UW9sxA
         G5bekykFGIrQAdTPQLK0Wpm7v9OzcurKuDYDf1w+IlcCl11lQxfP9W6RsZj17PvG40Nm
         21aleJIYVOeevcXN0nCpO8/C25+NHwGA10bq1njavOAbEeg9CD3l7n4rvhgQy9LG7hQu
         pEZtzA/spYQHqbm/pVUXyOEtbaQD4/JIDrPcZGR7D8LwOWfgd2U1mDEB5JIqzjCaUoES
         WDNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=lUeG90JN23owse4hkCx6s3PvuPmRRtzpsafpqQdcTUA=;
        b=Aw9a5zghpbs0McN3b+sFrGCqGPI8cqxfFTXv/HrBiqtCN7IcX7ex641iPPqhyk78wT
         oolooUwi5DoA6daRjGsrPDP4Wgc/IF56vIfziI6Cs7bCKzpKs/dlFuqmWWNrRXRRJnsQ
         V6k/fQJr10/KVrPUGyPa9jfAfjqbIDKVFgJTr3PuJuXgEpBZBjdUQnupnkfnzLGeqnun
         7DEs0s7GIrlNwVIPc0TDg1Eq8ZGB8s0Dk4oC6KxZXWgLvW6qZxI4qw+kPvwNDKk71iu4
         fib5uEoYiue0JoyumJSNj4sCTxSnh74Y5IR0DFnvbc7it+mELEHeFqVSagne1JtoQeF4
         aA9g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QrW2+V7X;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e8sor16536308qkg.92.2019.07.18.13.34.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Jul 2019 13:34:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QrW2+V7X;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=lUeG90JN23owse4hkCx6s3PvuPmRRtzpsafpqQdcTUA=;
        b=QrW2+V7Xl/KTpbKakLlvwVZhX3mvxwY8oW2vB8V+YuPlRdScITuH23acCo57C3rm+/
         h14/iR5ajTzevvTZgDQqOGErulK0PjguBwTAsH9Y3EKi7j2DqAkinW13yKCiWiMvwlhz
         G337M9FxyP8xW3prNI+Y46tV6LKGfIKoJnpWP/StoXaJ8VaE6k8S6GraWUdl1DQ0jPVo
         5Nzq45cBYGbC8mYGBvPk+lRY+CeB7ljQ0M/WcypXEL0YLyup+trYqw1VrHc7N+XihAnT
         qSr15Qriyhre6ikVXcxStPhA9GKq5L81kUbOPa4ctMEOcvvh0wTxrAiF0q1LX9t8rDOw
         pMUg==
X-Google-Smtp-Source: APXvYqwjvJkRVs5rf6lR3JoHp630zNQ2CmcMU/UwjepgFtUoHLwCD2p9IdMuPtw8xc2XXrQdtk3z1AdJz1RZ4J6/Kh8=
X-Received: by 2002:a37:9042:: with SMTP id s63mr31248155qkd.344.1563482055130;
 Thu, 18 Jul 2019 13:34:15 -0700 (PDT)
MIME-Version: 1.0
References: <20190716055017-mutt-send-email-mst@kernel.org>
 <CAKgT0Uc-2k9o7pjtf-GFAgr83c7RM-RTJ8-OrEzFv92uz+MTDw@mail.gmail.com>
 <20190716115535-mutt-send-email-mst@kernel.org> <CAKgT0Ud47-cWu9VnAAD_Q2Fjia5gaWCz_L9HUF6PBhbugv6tCQ@mail.gmail.com>
 <20190716125845-mutt-send-email-mst@kernel.org> <CAKgT0UfgPdU1H5ZZ7GL7E=_oZNTzTwZN60Q-+2keBxDgQYODfg@mail.gmail.com>
 <20190717055804-mutt-send-email-mst@kernel.org> <CAKgT0Uf4iJxEx+3q_Vo9L1QPuv9PhZUv1=M9UCsn6_qs7rG4aw@mail.gmail.com>
 <20190718003211-mutt-send-email-mst@kernel.org> <CAKgT0UfQ3dtfjjm8wnNxX1+Azav6ws9zemH6KYc7RuyvyFo3fQ@mail.gmail.com>
 <20190718162040-mutt-send-email-mst@kernel.org>
In-Reply-To: <20190718162040-mutt-send-email-mst@kernel.org>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Thu, 18 Jul 2019 13:34:03 -0700
Message-ID: <CAKgT0UcKTzSYZnYsMQoG6pXhpDS7uLbDd31dqfojCSXQWSsX_A@mail.gmail.com>
Subject: Re: [PATCH v1 6/6] virtio-balloon: Add support for aerating memory
 via hinting
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>, 
	David Hildenbrand <david@redhat.com>, Dave Hansen <dave.hansen@intel.com>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Yang Zhang <yang.zhang.wz@gmail.com>, pagupta@redhat.com, 
	Rik van Riel <riel@surriel.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, lcapitulino@redhat.com, 
	wei.w.wang@intel.com, Andrea Arcangeli <aarcange@redhat.com>, 
	Paolo Bonzini <pbonzini@redhat.com>, dan.j.williams@intel.com, 
	Alexander Duyck <alexander.h.duyck@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 18, 2019 at 1:24 PM Michael S. Tsirkin <mst@redhat.com> wrote:
>
> On Thu, Jul 18, 2019 at 08:34:37AM -0700, Alexander Duyck wrote:
> > > > > For example we allocate pages until shrinker kicks in.
> > > > > Fair enough but in fact many it would be better to
> > > > > do the reverse: trigger shrinker and then send as many
> > > > > free pages as we can to host.
> > > >
> > > > I'm not sure I understand this last part.
> > >
> > > Oh basically what I am saying is this: one of the reasons to use page
> > > hinting is when host is short on memory.  In that case, why don't we use
> > > shrinker to ask kernel drivers to free up memory? Any memory freed could
> > > then be reported to host.
> >
> > Didn't the balloon driver already have a feature like that where it
> > could start shrinking memory if the host was under memory pressure? If
> > so how would adding another one add much value.
>
> Well fundamentally the basic balloon inflate kind of does this, yes :)
>
> The difference with what I am suggesting is that balloon inflate tries
> to aggressively achieve a specific goal of freed memory. We could have a
> weaker "free as much as you can" that is still stronger than free page
> hint which as you point out below does not try to free at all, just
> hints what is already free.

Yes, but why wait until the host is low on memory? With my
implementation we can perform the hints in the background for a low
cost already. So why should we wait to free up memory when we could do
it immediately. Why let things get to the state where the host is
under memory pressure when the guests can be proactively freeing up
the pages and improving performance as a result be reducing swap
usage?

