Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 369E4C606BD
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 17:58:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2A7F218A3
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 17:58:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Kn+ywXAH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2A7F218A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6BF288E002E; Mon,  8 Jul 2019 13:58:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 66F6D8E0027; Mon,  8 Jul 2019 13:58:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 536DD8E002E; Mon,  8 Jul 2019 13:58:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2FA5F8E0027
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 13:58:12 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id i6so6440065oib.12
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 10:58:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=J6BYXR7+fOdaYBcbsh3ughBec33Q5ZK6pIAnMm20zX4=;
        b=R5U+kt5IilLMlIvHDg6fUXckfjx7HNajoEIowIzQzEFQuTnMWktpMJrQyd4tEoXnbK
         f3kSLNwjod7I6LLDvqgL/tp2YJJpYmh7UQ2psyAbnqxhEVgsQFLdSMnMD3op0ZvQtrVo
         Ny7OArivwgahM7U3/GQSZTpFlJW2EC6mrPLfI41dMV+36gCbg839UJApd2wd2T+A2HsH
         /nT8+SxVMj/KbdX6SNU3tR3iHNffKq9zxYQiPavFsj8pVgdTS/E3YE17Vh0+Jb6JXGvp
         bzWAtsFNqoElSfzsQXiTAwbcNulEU/anWVZWeiZWdfftUxdm3sp5NZpgRGzbaBcHnYY4
         CwBw==
X-Gm-Message-State: APjAAAVIQoYENN1C51nBr7lj8on/lnLweV9z7wQP0l8W+ItUBbFHsM8a
	vJQXznj28DSijjRqNjP9Jac7EFxqIHon5s/e8q/j7d4jwLgPZbxNpbqIYRU0dTVSKPzyM96ozZ6
	YtkK7IHjng/pF4BtI8HoGkkBSYhkpqwgkipWIaG834/hNztloNAN1ZpHYUdhyYPyhcA==
X-Received: by 2002:aca:3509:: with SMTP id c9mr10668103oia.179.1562608691914;
        Mon, 08 Jul 2019 10:58:11 -0700 (PDT)
X-Received: by 2002:aca:3509:: with SMTP id c9mr10668081oia.179.1562608691260;
        Mon, 08 Jul 2019 10:58:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562608691; cv=none;
        d=google.com; s=arc-20160816;
        b=051SqQ9FGpknNh7EtulCD3mQ2MtZ8wsI3rvMM8+mKu4ieznppjnMAMVJWzWCcZ1EhC
         OYsAOg1s00+JgdMnE4w6A9/22Ay7NAHtEqdM8ypT4makr9anRWx2kKy9uBfgX2yiWDMt
         lbqjxAd+DEgCROBf050NH3GpWkLl8wCa1u1FisHnTlZqoAxpyL39UZA1wNp7zMgsc63g
         tmlZHjviu2KQiZ9dcYgU0FFeGHokGE/ogKier8bmJD+lxg37XPqyuXEVK8CYf4idkk9N
         xiPbG9TtHoVBamujIdWUoCtokkQBQTunoZn9fXvko2nYHu2i7afSBb3xnMOtibEFxyKh
         52fQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=J6BYXR7+fOdaYBcbsh3ughBec33Q5ZK6pIAnMm20zX4=;
        b=vvt83YhR5Cdyst67u4oW5N+h49SU/7tZdZ+VrUeINAk24U3gW8o5VSr/z1npy8/ohy
         S87OGSkgVnC+bXtdORb5BFV6F+dc0AqU+O+dWdoU5BnDdZAqstfIyYlfALkcr7SC7XOi
         3c5k13VMoYw9r61Acr8U69xJz/pxC1pUtR1ltq4zrAbvFC3AlyawwMgYVnYuPNcuL9/3
         4N68yuD3uGwrj0sMkeAByPQttOtItq1dA9kUaLlo10DpV3Cl5MNQXyS0Vk9gCPGvlg3i
         +yEH/Pocd3VR1wGL45lBoz+56pMZupILxnToEO9gYme+Ic6xM2nJK1EaQ9rszVe1eEhg
         cfyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Kn+ywXAH;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i17sor3638866oik.92.2019.07.08.10.58.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jul 2019 10:58:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Kn+ywXAH;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=J6BYXR7+fOdaYBcbsh3ughBec33Q5ZK6pIAnMm20zX4=;
        b=Kn+ywXAHUiDPK5+TJCW6kotSSgpd2BHUDV/2hUkPZNa+N4r5coXiFuu3l6K3D1Zbwj
         FI9bcHWA1ajVrR3Y0W6Xix4ewCKitv2pdqvT1+r1V7z72PVfPoRnL84Euav+NXe19qT4
         rODKJZieMLdDEq4CRj7FZ4/qJRAduZpTAFy697lgHDkcdIi0A2biKe3/IuvACWtpEJ3G
         Mg54FTPHln+5J8ONLpPXf6a0oVi1rYUU6poMXe1I2pCulaFXMsEWq2Cl5zVGjyCoCpiY
         i5TEN97zqBk2QVfWX0w/bn/A8w0ZSYvne/1WI777j8ypcyqwQ3zrUNeBVZsLeYWnTF46
         cEog==
X-Google-Smtp-Source: APXvYqzFB5NdeTU13L7Fv1wsmPdbONbYZrMIHrL7iJKHItGJ2/5APvUtcBxAYOTpZCxb/9YdP2bFcEtzFfvwSBY3QTo=
X-Received: by 2002:aca:4d12:: with SMTP id a18mr10154747oib.33.1562608690964;
 Mon, 08 Jul 2019 10:58:10 -0700 (PDT)
MIME-Version: 1.0
References: <20190708170631.2130-1-lpf.vector@gmail.com> <20190708173534.GF32320@bombadil.infradead.org>
In-Reply-To: <20190708173534.GF32320@bombadil.infradead.org>
From: Pengfei Li <lpf.vector@gmail.com>
Date: Tue, 9 Jul 2019 01:57:59 +0800
Message-ID: <CAD7_sbEog0OQ+Bxg1nNt2CWgHHLqf602dzhAHTAThPjwK3yitQ@mail.gmail.com>
Subject: Re: [PATCH] mm/vmalloc.c: Remove always-true conditional in vmap_init_free_space
To: Matthew Wilcox <willy@infradead.org>
Cc: akpm@linux-foundation.org, Uladzislau Rezki <urezki@gmail.com>, rpenyaev@suse.de, 
	peterz@infradead.org, guro@fb.com, rick.p.edgecombe@intel.com, 
	rppt@linux.ibm.com, aryabinin@virtuozzo.com, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 9, 2019 at 1:35 AM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Tue, Jul 09, 2019 at 01:06:31AM +0800, Pengfei Li wrote:
> > When unsigned long variables are subtracted from one another,
> > the result is always non-negative.
> >
> > The vmap_area_list is sorted by address.
> >
> > So the following two conditions are always true.
> >
> > 1) if (busy->va_start - vmap_start > 0)
> > 2) if (vmap_end - vmap_start > 0)
> >
> > Just remove them.
>
> That condition won't be true if busy->va_start == vmap_start.

Yes, you're right.
Sorry for my bad job.

