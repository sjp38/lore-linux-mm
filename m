Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5FDEC43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 13:40:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78DEB208E4
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 13:40:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="fP2Ot5P/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78DEB208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EFD556B0005; Mon, 24 Jun 2019 09:40:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EAE9F8E0003; Mon, 24 Jun 2019 09:40:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D27708E0002; Mon, 24 Jun 2019 09:40:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 67C8A6B0005
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 09:40:03 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id 22so1925271lft.2
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 06:40:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=CCHpK1CZOVMMRr9wyoLp/eyfAndWJItR7EDWf+w9QSU=;
        b=NJEVuuovjK/t95UlnWbKFO8YI1HFJWF2GnuYFvT6x6Hwo9ypI9x2gLr0cQLNpVa9lM
         vvafKEJfW4VXvT7mu3Iwha55ZwTHp3sYyK9TZRlpIeD5aByn6aO85beza+iDzPZmE1Cg
         UKRzbQpk6Mw5KuaIWuDk81mmla4C49fa3S6gcfEtkaA99WZ/ByESrefRMyiVlY9QqTvb
         9VUUxH6i7gncD4CavgkMClYWQVdVeUv44fKliIEKkPvEuMSt65ddX7B1c6Yc4kmge7pF
         sSMZllae9443gJpEsfPGy2kP5mdgnp58c7gq3WZJHdsYyCHAOAwpXI4NxsncladV4rIH
         60Qw==
X-Gm-Message-State: APjAAAVXTXSdU9oCfU4gxNSCGfHHIIRjhb/aek73bvpEMyM73cW1k6v3
	qrFPaEZzGal7iOd8HGpWPKXaqb5XC37iNQMuUY2/nuWTwJRje/ogNpG+Mf/eIlFulfY0gBwrov/
	babUiTZWdBHEF1vYVwmCa1tiit6AkGVAEybHQ75rCzR9vmIx01ajy7Lm57DASkV+J7Q==
X-Received: by 2002:a2e:9b81:: with SMTP id z1mr18152125lji.101.1561383602665;
        Mon, 24 Jun 2019 06:40:02 -0700 (PDT)
X-Received: by 2002:a2e:9b81:: with SMTP id z1mr18152090lji.101.1561383601924;
        Mon, 24 Jun 2019 06:40:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561383601; cv=none;
        d=google.com; s=arc-20160816;
        b=G8vJqxUD5vX9owIRvTf5Sn+8nuqEDhr2RTBDHWNxM8eVg5Vavct7+awtvRx9UH9Rm3
         75Nw/BQxvT4CGpYUSqel2Pwk86gnfnXoE1VKX1w3JqAWpme9aDbGPwX9RYQndlZiIB35
         ARUAdx0GDGWmIxA9QSU8HSSoOAWOlgpO/r4Oij7XO/tHbUeqGoxUhsAqUsEIV7trYYe3
         h/EfRzchBraseqS8Ilm+2OWnqz67T4V+aaqWf9XO1HMopYvS9quz9qJiQwfWMBNfCulz
         +ycJJMH6WQsqtXD+1MuN1f84tLHxB3vIWTyMcveeqTA3Jtznlpx1mfkykc2Za405oR+h
         Bsdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=CCHpK1CZOVMMRr9wyoLp/eyfAndWJItR7EDWf+w9QSU=;
        b=StzogdHo7KiRVHxzHZx8wnarOIrtE0A7IcDpiEKxpPbWOMwkuqHhivhbDC8RcVJ5G4
         xWcRa3PkxYVhqTBeIoPt1G6wo3Uy3o+j9tGsWHRAnpvrv7SK9D191s/0/jCakXoOxIWT
         JUawhEMmJy6gmy6/UDqFCr8xOxzaHTk0dj/nEw/7wWOSwKTQTSlQQpbkxt9iAFHd3Zwp
         hktUNM8fppdgJBYLaCpDu/y9Q9WQkzZbWjZQ8JzLfIqas0vW1tixWXe+VujZb+ABB8wB
         c/ZP4cDcykw0sRsgQ88Z2f84iecI0H6ty6PGnYoZFJYcLfwfp3DMjbRpS0MbBryx1uvY
         7onw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b="fP2Ot5P/";
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k19sor5274279ljj.5.2019.06.24.06.40.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 06:40:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b="fP2Ot5P/";
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=CCHpK1CZOVMMRr9wyoLp/eyfAndWJItR7EDWf+w9QSU=;
        b=fP2Ot5P/h6IfQPNnkVaknnZvAAp4gjmHLWg6mRMP+CMZ9YAztqfCuIF7zICgw8PE7u
         /C5LdKfScbPHPRwoC7oBsNOwoCQQK/AfSEDzYLOxSTacOSmZz5MIf7KYY0IaZD9cXmtQ
         J7BnzTNhxal/KCJBAvzgxW3R7HKTgQazjdJ9I=
X-Google-Smtp-Source: APXvYqxe3/6CzzzR4gqJmON9bleLRt6tjIA/Xd8vMWrt/qMZrE6mZsWn5jqP2T0jgi1lJiNXhDo48Q==
X-Received: by 2002:a2e:8846:: with SMTP id z6mr31548465ljj.20.1561383601131;
        Mon, 24 Jun 2019 06:40:01 -0700 (PDT)
Received: from mail-lj1-f172.google.com (mail-lj1-f172.google.com. [209.85.208.172])
        by smtp.gmail.com with ESMTPSA id n1sm1531626lfl.77.2019.06.24.06.40.00
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 06:40:00 -0700 (PDT)
Received: by mail-lj1-f172.google.com with SMTP id v18so12644121ljh.6
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 06:40:00 -0700 (PDT)
X-Received: by 2002:a2e:95d5:: with SMTP id y21mr63467183ljh.84.1561383118160;
 Mon, 24 Jun 2019 06:31:58 -0700 (PDT)
MIME-Version: 1.0
References: <20190620022008.19172-1-peterx@redhat.com> <20190620022008.19172-3-peterx@redhat.com>
 <CAHk-=wiGphH2UL+To5rASyFoCk6=9bROUkGDWSa_rMu9Kgb0yw@mail.gmail.com> <20190624074250.GF6279@xz-x1>
In-Reply-To: <20190624074250.GF6279@xz-x1>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 24 Jun 2019 21:31:42 +0800
X-Gmail-Original-Message-ID: <CAHk-=whRw_6ZTj=AT=cRoSTyoEk2-hiqJoNkqgWE-gSRVE5YwQ@mail.gmail.com>
Message-ID: <CAHk-=whRw_6ZTj=AT=cRoSTyoEk2-hiqJoNkqgWE-gSRVE5YwQ@mail.gmail.com>
Subject: Re: [PATCH v5 02/25] mm: userfault: return VM_FAULT_RETRY on signals
To: Peter Xu <peterx@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, David Hildenbrand <david@redhat.com>, 
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>, Jerome Glisse <jglisse@redhat.com>, 
	Pavel Emelyanov <xemul@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Martin Cracauer <cracauer@cons.org>, Denis Plotnikov <dplotnikov@virtuozzo.com>, Shaohua Li <shli@fb.com>, 
	Andrea Arcangeli <aarcange@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, 
	Marty McFadden <mcfadden8@llnl.gov>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Mel Gorman <mgorman@suse.de>, "Kirill A . Shutemov" <kirill@shutemov.name>, 
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 3:43 PM Peter Xu <peterx@redhat.com> wrote:
>
> Should we still be able to react on signal_pending() as part of fault
> handling (because that's what this patch wants to do, at least for an
> user-mode page fault)?  Please kindly correct me if I misunderstood...

I think that with this patch (modulo possible fix-ups) then yes, as
long as we're returning to user mode we can do signal_pending() and
return RETRY.

But I think we really want to add a new FAULT_FLAG_INTERRUPTIBLE bit
for that (the same way we already have FAULT_FLAG_KILLABLE for things
that can react to fatal signals), and only do it when that is set.
Then the page fault handler can set that flag when it's doing a
user-mode page fault.

Does that sound reasonable?

               Linus

