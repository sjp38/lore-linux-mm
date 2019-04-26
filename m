Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03BE0C43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 18:10:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BDE1F208CA
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 18:10:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="cOF+nEDn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BDE1F208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 715066B000D; Fri, 26 Apr 2019 14:10:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69DE66B000E; Fri, 26 Apr 2019 14:10:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5682B6B0010; Fri, 26 Apr 2019 14:10:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2FEB36B000D
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 14:10:35 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id e126so3250199ioa.8
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 11:10:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=j+1TnrYeykZ4uHOkP1fnZ3zoGVUTu6KjEnh502A5YIM=;
        b=tMMVUwoTKsg88qlurHGAbLVeyt+p5iWep6Hxe5RFq3BgqFKHQdVcwwWgIWxkhfFWK0
         EhROQ4OqzVm8YW8Rr6zQ8VMKguVr0Zr0gRYDFIXO/30p+frWiE4IZQA/OsygDxE4S5Ob
         Ymtv/AJyqnEIYR/fI1UAk/GYprnqHrU/TDaASPFNhZkl46O6lM3XISQv7XgPTp0mLp+X
         b+M0DrlDTD1gzknxaqGLyxPwtS1bdBuXbtyCcBqjmuxA4uHxlXpek0mBmh7/hktSVUoA
         /Sn2Pc5gMCHmjQ/uc2inDrmtyJu/JLFfA3Z7viKThqi/LkWr1O32r2kZ0GahUXlVw/5M
         zmig==
X-Gm-Message-State: APjAAAVZyCaJiGpOZ5bF7A/2jnO0UvG94ovA491I7BrHW0djdqkD8h/Z
	e4bifQ/zUwx3L/aph3wVKh0a/sSqPNh6C3ADwhnKMA3QD7CGgSPT/SNx+a2Sad98xbvtL0W/d7r
	ZbZAckp0a4ChYGSiD2gQDBoqY447ujrZ4p57NT2s2qHhnGYv6pol3m4AEb0cGHdW4hQ==
X-Received: by 2002:a24:7688:: with SMTP id z130mr9294871itb.57.1556302234954;
        Fri, 26 Apr 2019 11:10:34 -0700 (PDT)
X-Received: by 2002:a24:7688:: with SMTP id z130mr9294822itb.57.1556302234383;
        Fri, 26 Apr 2019 11:10:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556302234; cv=none;
        d=google.com; s=arc-20160816;
        b=e/ImrM9L5p4eJqzjSigCUH2q4bunOr2F67FIUxT/Z4ks2PowIxuUZkd1cDZvSKCQmT
         qgUsKIPMKwQo+qeQjD7Gt2F+cniC7OTC03oe4GsgVZg6sKndVo8ZKtAEL7saY5jNvxSX
         vmOzz1rqU1cUaxQVhTmApv/rw8ewY/ISIVvOLOPSxvNKJM7R8PNScyJymcp8qkuxiAJ+
         7pnkike/mAvwqKYpj8o5TaQlaDQGNXU4E8wHhU7P+74mRV9AqtPIZiFWoJQO2alnzx2I
         cq1zEpnuB7BoXvptwgjO/AzlaYVU80evSuiZ+HzwB0LiZatyY9E7Sf1JoTofRGuCaA1e
         Tesg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=j+1TnrYeykZ4uHOkP1fnZ3zoGVUTu6KjEnh502A5YIM=;
        b=WHEZrHA5i2/J8Lb54gZreTNvL4n/RQs011ARy4UI6DLdoZqLjOgAe+W7IO0pCTUcvd
         BJzohW6SZ2lizftpwxCMi4Ec86Fp3YE99WLmbZnLMCPwruWy5eQMOrQ7DFN1CifiRPOk
         Cc3fAM7yjuLVmehzqjdMSrr4TGqcx9+KEPu15DdRZ2lK0HGdVDDkJ6bmePInU9qgknOS
         ehH2BQq84mB4FR8jQifCm9Pn8Llbea0nF0HosvaQC9W0aSEjj9NB2C0202Crq4lnzBK+
         ZeTM+kAMc5E21oLVLL9/LCwX60C3+E1z5+MF80agEb/6pS+84sAoSZ8UKxRFKgugq5e1
         C8LA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=cOF+nEDn;
       spf=pass (google.com: domain of matthewgarrett@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matthewgarrett@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w6sor11027937iow.69.2019.04.26.11.10.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 11:10:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of matthewgarrett@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=cOF+nEDn;
       spf=pass (google.com: domain of matthewgarrett@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matthewgarrett@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=j+1TnrYeykZ4uHOkP1fnZ3zoGVUTu6KjEnh502A5YIM=;
        b=cOF+nEDnMUUOqxE73YvBiwt86yz8lSrgN7pJFcFltp7Szi/juxPAOUEjPFkZe0St7U
         tfrBCfFodDqWr51SR3SPHuVR0ZEp5+2JiGpL+Th9c1wFPnGCRLzquk974x+tmBeaSM7u
         DCvtl15T4RdTgXMnV4LkzxBThQm/I6NRmwUcQSHQWa1MeGJcdyM2a1IAueWcOI40lPBM
         AsiOaGphER60exUeIGBFZ5uY7MU6oo6GdoiqDJp2EQ28fn23FlV2OHZPlJwxJInSbzHC
         9p+aH6qWKQuAOz+gPW++vz5QKeqqTsHMFoAto/VhJsPqfPkvnyEtSd3zxojZFNFiccRp
         6V+w==
X-Google-Smtp-Source: APXvYqw9FqsrcyyRhofNPMOp0DaWFEzjGmXZ0ypA/9YtxC7xYINHKyX0ZOVcOKvPw9yYKmyTAEH16t3P1q/qOzodMVc=
X-Received: by 2002:a5e:8348:: with SMTP id y8mr29478399iom.88.1556302233694;
 Fri, 26 Apr 2019 11:10:33 -0700 (PDT)
MIME-Version: 1.0
References: <CACdnJuup-y1xAO93wr+nr6ARacxJ9YXgaceQK9TLktE7shab1w@mail.gmail.com>
 <20190425225828.212472-1-matthewgarrett@google.com> <d058d1ef-994f-ea6b-b6b4-bcd838a9fe2f@suse.cz>
In-Reply-To: <d058d1ef-994f-ea6b-b6b4-bcd838a9fe2f@suse.cz>
From: Matthew Garrett <mjg59@google.com>
Date: Fri, 26 Apr 2019 11:10:22 -0700
Message-ID: <CACdnJuuVBb8bOUGGq0H+Ask_ufT3X9YH42o5nAGQK0TCf+aKWg@mail.gmail.com>
Subject: Re: [PATCH V3] mm: Allow userland to request that the kernel clear
 memory on release
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 26, 2019 at 12:45 AM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 4/26/19 12:58 AM, Matthew Garrett wrote:
> > Updated based on feedback from Jann - for now let's just prevent setting
> > the flag on anything that has already mapped some pages, which avoids
> > child processes being able to interfere with the parent. In addition,
>
> That makes the API quite tricky and different from existing madvise()
> modes that don't care. One would for example have to call
> madvise(MADV_WIPEONRELEASE) before mlock(), otherwise mlock() would
> fault the pages in (unless MLOCK_ONFAULT). As such it really looks like
> a mmap() flag, but that's less flexible.
>
> How bout just doing the CoW on any such pre-existing pages as part of
> the madvise(MADV_WIPEONRELEASE) call?

I'll look into the easiest way to do that.

