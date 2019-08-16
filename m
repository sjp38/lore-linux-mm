Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED0F4C3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 16:21:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF2EF2086C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 16:21:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="fgp4v8P6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF2EF2086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48CEE6B000A; Fri, 16 Aug 2019 12:21:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43CC76B000C; Fri, 16 Aug 2019 12:21:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 353CE6B000D; Fri, 16 Aug 2019 12:21:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0238.hostedemail.com [216.40.44.238])
	by kanga.kvack.org (Postfix) with ESMTP id 154176B000A
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 12:21:14 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id A1282181AC9B4
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 16:21:13 +0000 (UTC)
X-FDA: 75828805626.05.cry38_44dcc55fde713
X-HE-Tag: cry38_44dcc55fde713
X-Filterd-Recvd-Size: 5137
Received: from mail-lj1-f170.google.com (mail-lj1-f170.google.com [209.85.208.170])
	by imf40.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 16:21:13 +0000 (UTC)
Received: by mail-lj1-f170.google.com with SMTP id x18so5840616ljh.1
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 09:21:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=ymHwSq4wTpjRhSkNkSGTSSHl5As6L3PV3bdJQptYy1o=;
        b=fgp4v8P6AxU+KKUY1EDc5rYVP1G7Mk7BIPRI7oZVb9n5xTGtQUQwxxYGrbtt4g5Gu3
         D4qg2XzBD6zjFtV9FiMyLGBsnngoRe1p7cJuCZFYZmtZ0f0vQtQMdktkSt0/8nrR0Aoz
         iLR92sZEp4yc9Ff9XsWy9gGBabbw281EZw/wg=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=ymHwSq4wTpjRhSkNkSGTSSHl5As6L3PV3bdJQptYy1o=;
        b=sRKzVpF+4QtQ12by21rFsEqTVDsG+JTeQbQkDHy7xzIiHwr4MucelF5C788ZQSbmL2
         xEiVxcU6f7pkX6LTCNQZh0GYFhN6/K8nPyZuzrjLMhd8jLOkAO66HMMJ8g3d0Rlc5Fcd
         CS4pNbJNj1jVilkggYBkEmVStsM7ZMkQpeUSYRDJGORs4t42UsChg/vHkYZWplkoMYa0
         XE9xYmszEVtIsL6QantdQqdjQNxbl14BN/aCLaWKl57dTir1VR9RIytIJ6eqCF4L2quZ
         KNm2JUkbUgwHxKL7Lirl4YRh2B3QiCU+SggfKZAqGJLs/cjrjp1C3mLX86E2JdqMwJ+J
         v4Cw==
X-Gm-Message-State: APjAAAVMNnM6hBAWbLTrLt4K6l/VleBntvikROpR4xHTmigJq+HscaUO
	0Pi5P5mPnCP55F8IT3Rj1yLCXj44CzQ=
X-Google-Smtp-Source: APXvYqycjiIjc0g3j+1H935Ws9U8zIcdaHqPOjd0Uh/flU2X02q93LvV0alurxpZI4cpEVHz9d3qhw==
X-Received: by 2002:a2e:891a:: with SMTP id d26mr6139269lji.26.1565972470766;
        Fri, 16 Aug 2019 09:21:10 -0700 (PDT)
Received: from mail-lj1-f181.google.com (mail-lj1-f181.google.com. [209.85.208.181])
        by smtp.gmail.com with ESMTPSA id s26sm1029266ljs.77.2019.08.16.09.21.08
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 16 Aug 2019 09:21:09 -0700 (PDT)
Received: by mail-lj1-f181.google.com with SMTP id t14so5821562lji.4
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 09:21:08 -0700 (PDT)
X-Received: by 2002:a2e:3a0e:: with SMTP id h14mr6088169lja.180.1565972468547;
 Fri, 16 Aug 2019 09:21:08 -0700 (PDT)
MIME-Version: 1.0
References: <20190808154240.9384-1-hch@lst.de> <CAHk-=wh3jZnD3zaYJpW276WL=N0Vgo4KGW8M2pcFymHthwf0Vg@mail.gmail.com>
 <20190816062751.GA16169@infradead.org> <20190816115735.GB5412@mellanox.com> <20190816123258.GA22140@lst.de>
In-Reply-To: <20190816123258.GA22140@lst.de>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 16 Aug 2019 09:20:52 -0700
X-Gmail-Original-Message-ID: <CAHk-=wiOB5wLWxHe8UDHnBB1DWrZaZ62ZPXnD0KiE8hYoWokNA@mail.gmail.com>
Message-ID: <CAHk-=wiOB5wLWxHe8UDHnBB1DWrZaZ62ZPXnD0KiE8hYoWokNA@mail.gmail.com>
Subject: Re: cleanup the walk_page_range interface
To: Christoph Hellwig <hch@lst.de>
Cc: Jason Gunthorpe <jgg@mellanox.com>, Christoph Hellwig <hch@infradead.org>, 
	Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?Q?Thomas_Hellstr=C3=B6m?= <thomas@shipmail.org>, 
	Jerome Glisse <jglisse@redhat.com>, Steven Price <steven.price@arm.com>, Linux-MM <linux-mm@kvack.org>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 5:33 AM Christoph Hellwig <hch@lst.de> wrote:
>
> I see two new walk_page_range user in linux-next related to MADV_COLD
> support (which probably really should use walk_range_vma), and then
> there is the series from Steven, which hasn't been merged yet.

It does sound like this might as well just be handled in linux-next,
and there's no big advantage in me pulling the walker cleanups early.

Honestly, even if it ends up being handled as a conflict resolution
issue (rather than some shared branch), it probably simply isn't all
that painful. We have those kinds of semantic conflicts all the time,
it doesn't worry me too much.

So I'm not worried about new _users_ of the page walker concurrently
with the page walker interface itself being cleaned up. Those kinds of
conflicts end up being "just make sure to update the new users to the
new interface when they get pulled". Happens all the time.

I'd be more worried about two different branches wanting to change the
internal implementation of the page walker itself, and the actual
*code* itself getting conflicts (as opposed to the interface vs users
kind of conflicts). Those kinds of conflicts can be messy. But it
sounds like Thomas Hellstr=C3=B6m's changes aren't that kind of thing.

I'm still willing to do the early merge if it turns out to be hugely
helpful, but from the discussion so far it does sound like "just merge
during 5.4 merge window" is perfectly fine.

               Linus

