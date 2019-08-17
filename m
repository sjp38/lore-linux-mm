Return-Path: <SRS0=ZelW=WN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 135E9C3A59F
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 07:38:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A14FD2086C
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 07:38:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="ROBhpTcY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A14FD2086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B1B46B0007; Sat, 17 Aug 2019 03:38:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 33B826B000A; Sat, 17 Aug 2019 03:38:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DE076B000C; Sat, 17 Aug 2019 03:38:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0072.hostedemail.com [216.40.44.72])
	by kanga.kvack.org (Postfix) with ESMTP id E8D586B0007
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 03:38:09 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 914BB181AC9CB
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 07:38:09 +0000 (UTC)
X-FDA: 75831116298.04.shelf60_4726fd5dc5c5a
X-HE-Tag: shelf60_4726fd5dc5c5a
X-Filterd-Recvd-Size: 5136
Received: from mail-lj1-f193.google.com (mail-lj1-f193.google.com [209.85.208.193])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 07:38:08 +0000 (UTC)
Received: by mail-lj1-f193.google.com with SMTP id f9so7196285ljc.13
        for <linux-mm@kvack.org>; Sat, 17 Aug 2019 00:38:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=qjmefjZhoyebLftZlaWwOgZmDLyOFDxgkvKQNDD6muU=;
        b=ROBhpTcYE5sMsKscWoxHvuN7/rDEB2KBhTYVGBrSf8McXkjaPUHTa+vvnR7jS1c/98
         Yu6WhN2x/RHdyfcAwhc/BsVF52q/Dl9W3Rtsq3Qr7rrbg5HT3lgtH2ByzJiZhVIANWGB
         WyzMcJJ8ndT8ewyDylRfnDShKXqexN+HkPk/E=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=qjmefjZhoyebLftZlaWwOgZmDLyOFDxgkvKQNDD6muU=;
        b=Tb6coyKGRqvs+XbbwXs0fRVpL5EyC5K35HgcwjDG60kZn8eYMR8XwuPcIO6QxsJgZ8
         Zn6Qyz8yFIDc/yE5/mh9idoKGHJiFtu/8LXuO/iwMc0Kmgds2y5iMbskoECQ9DyRMpDv
         ltYf+hWC0AYKHUyIUpE5HNcT9u7KyxE6xnpWiPplME47f77AXgwEnZUlqKNznpgmN1jW
         2qYfD7tzmkPTmybRpos4E9MQaZkIy6R2SoyXalF7WALOFJuAEsGS+OtY6qMUX/Gs7Dmn
         jbKtIabg6CFGm0qzny8VzWEPciIx+RmkrBnqzNzqAhj5dwIfKsvpVU2UKkTP2dlBIfRh
         m73Q==
X-Gm-Message-State: APjAAAVS0iXp85FSC+bZWMEvqHxNIC7UNb5ffFiyTneFjlL+xz0QoHqP
	ffkKRIj/DxW3X9c5gVaqEk4/uhT8Pqs=
X-Google-Smtp-Source: APXvYqzApNSfTmMfPdfxEGxNibzU4AhMV9alI08GvMdCLlA5GCzoRIO2GcTwEc2M1GpYaDssXdqHIw==
X-Received: by 2002:a2e:8e99:: with SMTP id z25mr7546276ljk.121.1566027486951;
        Sat, 17 Aug 2019 00:38:06 -0700 (PDT)
Received: from mail-lj1-f169.google.com (mail-lj1-f169.google.com. [209.85.208.169])
        by smtp.gmail.com with ESMTPSA id j21sm1284241lfb.38.2019.08.17.00.38.05
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sat, 17 Aug 2019 00:38:05 -0700 (PDT)
Received: by mail-lj1-f169.google.com with SMTP id e27so7220064ljb.7
        for <linux-mm@kvack.org>; Sat, 17 Aug 2019 00:38:05 -0700 (PDT)
X-Received: by 2002:a2e:3a0e:: with SMTP id h14mr7640810lja.180.1566027485396;
 Sat, 17 Aug 2019 00:38:05 -0700 (PDT)
MIME-Version: 1.0
References: <20190808154240.9384-1-hch@lst.de> <CAHk-=wh3jZnD3zaYJpW276WL=N0Vgo4KGW8M2pcFymHthwf0Vg@mail.gmail.com>
 <20190816062751.GA16169@infradead.org> <20190816115735.GB5412@mellanox.com>
 <20190816123258.GA22140@lst.de> <20190816140623.4e3a5f04ea1c08925ac4581f@linux-foundation.org>
 <20190817164124.683d67ff@canb.auug.org.au>
In-Reply-To: <20190817164124.683d67ff@canb.auug.org.au>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 17 Aug 2019 00:37:49 -0700
X-Gmail-Original-Message-ID: <CAHk-=wheUwELKxhouLs4b==w9DxMrCPh2R_FTsTeVi0=d0S_OA@mail.gmail.com>
Message-ID: <CAHk-=wheUwELKxhouLs4b==w9DxMrCPh2R_FTsTeVi0=d0S_OA@mail.gmail.com>
Subject: Re: cleanup the walk_page_range interface
To: Stephen Rothwell <sfr@canb.auug.org.au>, David Howells <dhowells@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, 
	Jason Gunthorpe <jgg@mellanox.com>, Christoph Hellwig <hch@infradead.org>, 
	=?UTF-8?Q?Thomas_Hellstr=C3=B6m?= <thomas@shipmail.org>, 
	Jerome Glisse <jglisse@redhat.com>, Steven Price <steven.price@arm.com>, Linux-MM <linux-mm@kvack.org>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 11:41 PM Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>
> I certainly prefer that method of API change :-)
> (see the current "keys: Replace uid/gid/perm permissions checking with
> an ACL" in linux-next

Side note: I will *not* be pulling that again.

It was broken last time, and without more people reviewing the code,
I' m not pulling it for 5.4 either even if David has an additional
commit on top that might have fixed the original problem.

There's still a pending kernel test report on commit f771fde82051
("keys: Simplify key description management") from another of David's
pulls for 5.3 - one that didn't get reverted.

David, look in your inbox for a kernel test report about

  kernel BUG at security/keys/keyring.c:1245!

(It's the

        BUG_ON(index_key->desc_len == 0);

line - the line numbers have since changed, and it's line 1304 in the
current tree).

I'm not sure why _that_ BUG_ON() now triggers, but I wonder if it's
because 'desc_len' went from a 'size_t' to an 'u8', and now a desc_len
of 256 is 0. Or something. The point being that there have been too
many bugs in the pulls and nobody but David apparently ever had
anything to do with any of the development. This code needs more eyes,
not more random changes.

So I won't be compounding on that workflow problem next merge window.

                  Linus

