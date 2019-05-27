Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6468C07542
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 10:54:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B76020859
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 10:54:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dR84Z3nu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B76020859
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C95D6B0271; Mon, 27 May 2019 06:54:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 87A8E6B0272; Mon, 27 May 2019 06:54:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 767BA6B0273; Mon, 27 May 2019 06:54:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0DCD26B0271
	for <linux-mm@kvack.org>; Mon, 27 May 2019 06:54:38 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id q29so1231053lfn.6
        for <linux-mm@kvack.org>; Mon, 27 May 2019 03:54:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=T2n4gBNEt3oKhgRBGoBZWnyBBkiJxP3xEBbVU5SxBlY=;
        b=Eg/oXojf6uW6EUzRY5Vfn7mrVioBSguvMJf/PRtaWKjQdkhivYybZCRKLaKPGlym55
         1z+tisaA4P78Vw5CbYrGnGauE7m+GETnT+a6NihTAeUJokWf9eKMMjB0qWsgmbEwDoZk
         yBt77yKe010YQQeAbquPDM0uhOZf3qEVBcSWc5EobZe/um0uRbRL662Guaco1f2wmFF0
         p36WVRZjtfBFl5JCic4MH4o2fzY3uHLvLRsw+TgwpeUSrfSR4DnWuFPbOqwh5urZ6C2b
         F9eXkj6W0MsCyHP4JWQuZ3g6YVpnL4Pa0zyPfvdPs5jUDZ2AkWDD6pEagJqnvZt4VVmP
         LRkw==
X-Gm-Message-State: APjAAAVscGsYB72FHROjWwZBFTiTxPoWzXQla0BtZtJjF9jVhRzQkMQ0
	i14gtFe6F2ERqngP6hb/PW/wJgkHfhTbMhqP9tojhheWeYNsS2b86FB2bMbca2RjNwmOVYRXZTP
	rqARjs6G8n8VCwV0tmn55C86smR1zGcVljOumVcYLwmScCP1FVFj1+X+kWiWC/GkMGQ==
X-Received: by 2002:ac2:546a:: with SMTP id e10mr3606765lfn.75.1558954477109;
        Mon, 27 May 2019 03:54:37 -0700 (PDT)
X-Received: by 2002:ac2:546a:: with SMTP id e10mr3606711lfn.75.1558954475992;
        Mon, 27 May 2019 03:54:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558954475; cv=none;
        d=google.com; s=arc-20160816;
        b=xh6Q9NtAf/w9M67Bt1ZcuA9rVN1WhIouFgqk99/VPqYjnbNbfQP878JW29KSQplBxj
         YX3i1HqUjRdFRopiGSnxR/+aOTkW87L9MjLZqtjAkYL1lODH8HZ3KB81lklSG8XwGtel
         1RdlMkdACYQTzSUI5LPJFHp6Tn6bql12PnSKPkaQQzloefs+SXN2FD/84y3Lw8xuVm+X
         Pr/nh3Zom/WPPmPWQ2x1k6xJ+f9GcbIscEH4EIgMuvREM3+OeCD0jaVB2qioBryKx3D8
         f+1A9pETgaxrYL4GOdRANcT1J2L8NFiUYKCiAa+E+aXpiZL2kRrhLNn8tqnP5q1tgkSP
         AH6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=T2n4gBNEt3oKhgRBGoBZWnyBBkiJxP3xEBbVU5SxBlY=;
        b=oLU3b+PkX50xT7m3dFhDCNSLeyiTuMWMfcbdc0I6fiFAa2EhJc4a362i276UU2nUW3
         0ZZu5YlfTtd+eW4HTl56x3EqTy7BMDyaFcsiASVsVg2xb9OHHQKXfM5YPRpUfBrQQwnA
         mbJst+4/A0UajFRKkxm6mhdJvPuwcWQ2Ir6pph0jLjiTTCXrcnkWknfZRYaaVdV6+cQo
         Tu/Fah3oIP0oRd06Ebw51y9yv9BOaYZz7p4nTjX2hgmgorwetP1IbeqOqUiBvn3KJwDk
         M6BOe7PfzMmYkTqOVT/k4hbjb5GJ9+zIV9tqEDFkJzEEHx6haUqLgR8tCY4bnTBkcDa6
         RsWg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=dR84Z3nu;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z9sor2609890lfh.44.2019.05.27.03.54.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 May 2019 03:54:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=dR84Z3nu;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=T2n4gBNEt3oKhgRBGoBZWnyBBkiJxP3xEBbVU5SxBlY=;
        b=dR84Z3nuv3s5YOrQqiLB6Ix9wMQyT82iqcq3wrUTRa/kZxr+uBwRmuVxh7hx4Lj3FM
         KEhFHkxTmGv6Kam6nBU+3HqKorCFNvjw9OKzYn2VNr6iYG7Vd9fuyzf40YRt32xz2mSg
         bOlKoojrSHXP5UsyZ7jQAqUTsUqLpKSgzi5DR4/VRyJe0G/djkI1+RjUawiyvAvHZEv3
         3XP1nkgpkAxPkHG7+BRQVTg9/MdbHsZdjvMS8pi4eVrG7fJTgAEcOXKiSiV6YDPNq6jw
         6xUNJqhwJr+anTyRiB+gdR3lBXp1Y/etJgAXzlqqmzfgEdAxjIYaFfuQhg6wQqVmQwf3
         vXaQ==
X-Google-Smtp-Source: APXvYqxlu5SnIBVa0aUlRiEJtdFyNmXZap0vDJRssM/5GGdUmvTYcWWazIPXEdPkaGYaXb7kqt5b4zLGBxOPmONRBqE=
X-Received: by 2002:a19:9e46:: with SMTP id h67mr8374590lfe.120.1558954475111;
 Mon, 27 May 2019 03:54:35 -0700 (PDT)
MIME-Version: 1.0
References: <20190524174918.71074b358001bdbf1c23cd77@gmail.com> <20190525150948.e1ff1a2a894ca8110abc8183@linux-foundation.org>
In-Reply-To: <20190525150948.e1ff1a2a894ca8110abc8183@linux-foundation.org>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Mon, 27 May 2019 12:54:23 +0200
Message-ID: <CAMJBoFNXVc3BBdEOsKTSHO51reHL93GPQNO4Tjkx+OaDcpb22g@mail.gmail.com>
Subject: Re: [PATCH] z3fold: add inter-page compaction
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Dan Streetman <ddstreet@ieee.org>, Oleksiy.Avramchenko@sony.com, 
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Uladzislau Rezki <urezki@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, May 26, 2019 at 12:09 AM Andrew Morton
<akpm@linux-foundation.org> wrote:

<snip>
> Forward-declaring inline functions is peculiar, but it does appear to work.
>
> z3fold is quite inline-happy.  Fortunately the compiler will ignore the
> inline hint if it seems a bad idea.  Even then, the below shrinks
> z3fold.o text from 30k to 27k.  Which might even make it faster....

It is faster with inlines, I'll try to find a better balance between
size and performance in the next version of the patch though.

<snip>
> >
> > ...
> >
> > +static inline struct z3fold_header *__get_z3fold_header(unsigned long handle,
> > +                                                     bool lock)
> > +{
> > +     struct z3fold_buddy_slots *slots;
> > +     struct z3fold_header *zhdr;
> > +     unsigned int seq;
> > +     bool is_valid;
> > +
> > +     if (!(handle & (1 << PAGE_HEADLESS))) {
> > +             slots = handle_to_slots(handle);
> > +             do {
> > +                     unsigned long addr;
> > +
> > +                     seq = read_seqbegin(&slots->seqlock);
> > +                     addr = *(unsigned long *)handle;
> > +                     zhdr = (struct z3fold_header *)(addr & PAGE_MASK);
> > +                     preempt_disable();
>
> Why is this done?
>
> > +                     is_valid = !read_seqretry(&slots->seqlock, seq);
> > +                     if (!is_valid) {
> > +                             preempt_enable();
> > +                             continue;
> > +                     }
> > +                     /*
> > +                      * if we are here, zhdr is a pointer to a valid z3fold
> > +                      * header. Lock it! And then re-check if someone has
> > +                      * changed which z3fold page this handle points to
> > +                      */
> > +                     if (lock)
> > +                             z3fold_page_lock(zhdr);
> > +                     preempt_enable();
> > +                     /*
> > +                      * we use is_valid as a "cached" value: if it's false,
> > +                      * no other checks needed, have to go one more round
> > +                      */
> > +             } while (!is_valid || (read_seqretry(&slots->seqlock, seq) &&
> > +                     (lock ? ({ z3fold_page_unlock(zhdr); 1; }) : 1)));
> > +     } else {
> > +             zhdr = (struct z3fold_header *)(handle & PAGE_MASK);
> > +     }
> > +
> > +     return zhdr;
> > +}
> >
> > ...
> >
> >  static unsigned short handle_to_chunks(unsigned long handle)
> >  {
> > -     unsigned long addr = *(unsigned long *)handle;
> > +     unsigned long addr;
> > +     struct z3fold_buddy_slots *slots = handle_to_slots(handle);
> > +     unsigned int seq;
> > +
> > +     do {
> > +             seq = read_seqbegin(&slots->seqlock);
> > +             addr = *(unsigned long *)handle;
> > +     } while (read_seqretry(&slots->seqlock, seq));
>
> It isn't done here (I think).

handle_to_chunks() is always called with z3fold header locked which
makes it a lot easier in this case. I'll add some comments in V2.

Thanks,
   Vitaly

