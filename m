Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64B99C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 23:12:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0676D20663
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 23:12:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ccTd2CEU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0676D20663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A59C8E0003; Wed,  6 Mar 2019 18:12:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 856928E0002; Wed,  6 Mar 2019 18:12:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 76B668E0003; Wed,  6 Mar 2019 18:12:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4DF018E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 18:12:47 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id q192so6955301itb.9
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 15:12:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=1yYY+hlDrFnFfX0Lw0YllZ9KuunWzLXQegi/MDoLIIQ=;
        b=Z+2mbIVLBoJtWzEvslIABXvugM/ZSe4X9d3eYmUXbS1zjQfZW1g9PhD/B/iXX1b2tx
         KZu+O7d7yg+DAa5LYAui9GWeokmpN1qUe11AXIfgfcipUHUoMw371SSCqL+6jTvCDS8C
         uFhHtiUX3Xx3AB0vSa3QOEML/5ymXVFCTAsBjHFscOuJ6fQMDTlzLVYHeIWDWaOvTqAq
         t3twBu0TNxwnqawdc8mh2rzTQH5CPkBS17EbuMrYiZFbAniAH6909I7PG5tDgIyU44sR
         DOl27LaP0rCITHNvMOML4BfW7hmot9bIqvQCQ/4c7NiW3jqsOD9e39sjlYvcMhHR6grL
         zP0w==
X-Gm-Message-State: APjAAAUVcY0R8+6mNP1i676HWAusv5R8B6ALVh6+tGdLvRURuSCLNTNg
	9J7Tx7ySP+QgDZWS5B/3j4zXF11nRza17KcnMS9tD4PjGwRWeUZkNoUh1QuWHjqcPszYnDQq+OS
	YLwyY9YgVM3JwB3ZAiA3qoYSSL4rpOd7mclKPvpeoSb1UrAbKP2GDigz5CsOdTkivnqOP5f/mgH
	lKpyZRfPp0S6bOvH5zrvRK4WeC12tfRAHYmSgrIRed4gFUfMW+oLFo1PEzroWetI+4onx1sgHyO
	xmSZhFYSURgUrFf0Bkp+JBFtnmh3PXxZE1FobmeMZTvkhrTbc1cVr1vE7Tbio2SFe4PIPP8oS81
	rXJ49bkMD4emRfp693xaIEuR/2etrHEfn3ggPMZLvHn/hLxblKI8RYTp7QNlKf9Qy0aqVCHeYzL
	V
X-Received: by 2002:a5e:8347:: with SMTP id y7mr4446172iom.136.1551913967008;
        Wed, 06 Mar 2019 15:12:47 -0800 (PST)
X-Received: by 2002:a5e:8347:: with SMTP id y7mr4446122iom.136.1551913965968;
        Wed, 06 Mar 2019 15:12:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551913965; cv=none;
        d=google.com; s=arc-20160816;
        b=S8GG+M2Mkbe29UrsjJD7RHB+pzO0+n+RU++Tvc2q054UQwhHzN4/n7QjBjUx5H4Aec
         QqaRT8EOfaeoBeZBattoe+3z6d/Vvc67ahAdHrLJO4CR4p7B8DtyyxiLb4FW5H3vv2jE
         QZQy22Kxj7SqFyUVo054kZBfKtjSa+FXdgpyV4SV9+lJQtBWmT2OOlrDW94xmlGjFfGh
         cydNJ7qsOsRE8GEtVXMVj357cdZsrs3rPkIYwox5cQpRaGq0huUNNQI5Dv3JskcsYO9y
         Q0nSEL5UPYgaDjcK5KSG8ojfy/HLNG2vpPpOtRgiKEaJk0YtqiXssN5di8JE26AG+gf2
         p97A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=1yYY+hlDrFnFfX0Lw0YllZ9KuunWzLXQegi/MDoLIIQ=;
        b=t0yaI6QQdPLXxOrYG/SUvw3PSXIXxuTEasXuKj2igOvxIfAu3v30MES+RQryQL2d4o
         EH6Wqo7Yqu8PY7sL2R6IhFuhxkJzXBTuAkI5fnA1NzuRekTCXxzkF/tQoc9QP2NJsb0r
         McEXYnCaS+qYWjCbGqS6hMKp9+gSMq4pswQkuCBaCl3LDzcowAIPV/r1z5bMzuSLgZFv
         MRDlCfRSgQGfE+JaweCcnjIM81jvohndZgzYft0/gQ7VHbu96DyJKUrgtLDvQsmV0cTa
         ZhHddKoHZr9jFdVSXd0rOCS5YcIYsOFhOxb56UtVxwZmrGLzO3XG5B4oaYpu0ToXG/3I
         XldQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ccTd2CEU;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j196sor5418549itb.8.2019.03.06.15.12.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Mar 2019 15:12:45 -0800 (PST)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ccTd2CEU;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=1yYY+hlDrFnFfX0Lw0YllZ9KuunWzLXQegi/MDoLIIQ=;
        b=ccTd2CEUfadVkqIG5F21ppkpCDRJhwZ3sYqJxWp40HMveZiw+EzC5GaPHkRuOCpSsD
         x0YbSGJUWygD2/GMqjpx3Sx/hxJHRaypd8iPifQsJKeYjJOTWuqYsBNCpCFEAMc9utcz
         zJt7OIAwM3u0iZTkxyJ+y9OAKhTfeIwkmDjsMxLAjyQBfv/H0rQ4aIvtGUELFmltZw/R
         bM++BG9zip81E0geoEqpOMjiyhf+rFmCJNYQnV4Tc3VulYIqUA/QYMfGd9+YzRYuc4Qj
         VFrb4RXnvuh25j1c0bnx5rDK/WAtihwwzOj4omul9UmHE5TPOTpC4a2CSVtx+Nodcqo1
         e74Q==
X-Google-Smtp-Source: APXvYqzQsJp2+41k/pIeJ0VDstp4dM3UZ2CNqmpIYH9+63MK2mMWrd/7nWmxDo3vKjdieKVRBF6vFO68MeK1xnPtYjc=
X-Received: by 2002:a24:4650:: with SMTP id j77mr3611316itb.6.1551913965195;
 Wed, 06 Mar 2019 15:12:45 -0800 (PST)
MIME-Version: 1.0
References: <20190306155048.12868-1-nitesh@redhat.com> <20190306110501-mutt-send-email-mst@kernel.org>
 <bd029eb2-501a-8d2d-5f75-5d2b229c7e75@redhat.com> <20190306130955-mutt-send-email-mst@kernel.org>
 <afc52d00-c769-01a0-949a-8bc96af47fab@redhat.com> <20190306133826-mutt-send-email-mst@kernel.org>
 <3f87916d-8d18-013c-8988-9eb516c9cd2e@redhat.com> <20190306140917-mutt-send-email-mst@kernel.org>
 <9ead968e-0cc6-0061-de5c-42a3cef46339@redhat.com> <20190306165223-mutt-send-email-mst@kernel.org>
In-Reply-To: <20190306165223-mutt-send-email-mst@kernel.org>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 6 Mar 2019 15:12:33 -0800
Message-ID: <CAKgT0UeN=o0NratKSmhBhBBmwQ06qo9tiU9sqvpq_u8uMZPM1w@mail.gmail.com>
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
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

On Wed, Mar 6, 2019 at 2:18 PM Michael S. Tsirkin <mst@redhat.com> wrote:
>
> On Wed, Mar 06, 2019 at 10:40:57PM +0100, David Hildenbrand wrote:
> > On 06.03.19 21:32, Michael S. Tsirkin wrote:
> > > On Wed, Mar 06, 2019 at 07:59:57PM +0100, David Hildenbrand wrote:
> > >> On 06.03.19 19:43, Michael S. Tsirkin wrote:
> > >>> On Wed, Mar 06, 2019 at 01:30:14PM -0500, Nitesh Narayan Lal wrote:
> > >>>>>> Here are the results:
> > >>>>>>
> > >>>>>> Procedure: 3 Guests of size 5GB is launched on a single NUMA node with
> > >>>>>> total memory of 15GB and no swap. In each of the guest, memhog is run
> > >>>>>> with 5GB. Post-execution of memhog, Host memory usage is monitored by
> > >>>>>> using Free command.
> > >>>>>>
> > >>>>>> Without Hinting:
> > >>>>>>                  Time of execution    Host used memory
> > >>>>>> Guest 1:        45 seconds            5.4 GB
> > >>>>>> Guest 2:        45 seconds            10 GB
> > >>>>>> Guest 3:        1  minute               15 GB
> > >>>>>>
> > >>>>>> With Hinting:
> > >>>>>>                 Time of execution     Host used memory
> > >>>>>> Guest 1:        49 seconds            2.4 GB
> > >>>>>> Guest 2:        40 seconds            4.3 GB
> > >>>>>> Guest 3:        50 seconds            6.3 GB
> > >>>>> OK so no improvement.
> > >>>> If we are looking in terms of memory we are getting back from the guest,
> > >>>> then there is an improvement. However, if we are looking at the
> > >>>> improvement in terms of time of execution of memhog then yes there is none.
> > >>>
> > >>> Yes but the way I see it you can't overcommit this unused memory
> > >>> since guests can start using it at any time.  You timed it carefully
> > >>> such that this does not happen, but what will cause this timing on real
> > >>> guests?
> > >>
> > >> Whenever you overcommit you will need backup swap.
> > >
> > > Right and the point of hinting is that pages can just be
> > > discarded and not end up in swap.
> > >
> > >
> > > Point is you should be able to see the gain.
> > >
> > > Hinting patches cost some CPU so we need to know whether
> > > they cost too much. How much is too much? When the cost
> > > is bigger than benefit. But we can't compare CPU cycles
> > > to bytes. So we need to benchmark everything in terms of
> > > cycles.
> > >
> > >> There is no way
> > >> around it. It just makes the probability of you having to go to disk
> > >> less likely.
> > >
> > >
> > > Right and let's quantify this. Does this result in net gain or loss?
> >
> > Yes, I am totally with you. But if it is a net benefit heavily depends
> > on the setup. E.g. what kind of storage used for the swap, how fast, is
> > the same disk also used for other I/O ...
> >
> > Also, CPU is a totally different resource than I/O. While you might have
> > plenty of CPU cycles to spare, your I/O throughput might already be
> > limited. Same goes into the other direction.
> >
> > So it might not be as easy as comparing two numbers. It really depends
> > on the setup. Well, not completely true, with 0% CPU overhead we would
> > have a clear winner with hinting ;)
>
> I mean users need to know about this too.
>
> Are these hinting patches a gain:
> - on zram
> - on ssd
> - on a rotating disk
> - none of the above
> ?
>
> If users don't know when would they enable hinting?
>
> Close to one is going to try all possible configurations, test
> exhaustively and find an optimal default for their workload.
> So it's our job to figure it out and provide guidance.

Right. I think for now I will stick to testing on what I have which is
a SSD for swap, and no-overcommit for the "non of the above" case.

BTW it looks like this patch set introduced a pretty heavy penalty for
the no-overcommit case. For a 32G VM with no overcommit a 32G memhog
test is now taking over 50 seconds whereas without the patch set I can
complete the test in around 20 seconds.

> >
> > >
> > >
> > >> If you assume that all of your guests will be using all of their memory
> > >> all the time, you don't have to think about overcommiting memory in the
> > >> first place. But this is not what we usually have.
> > >
> > > Right and swap is there to support overcommit. However it
> > > was felt that hinting can be faster since it avoids IO
> > > involved in swap.
> >
> > Feels like it, I/O is prone to be slow.
> >
> >
> > --
> >
> > Thanks,
> >
> > David / dhildenb
>
> OK so should be measureable.
>
> --
> MST

