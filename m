Return-Path: <SRS0=Jdrj=PS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17C84C43444
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 05:26:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C75C7214DA
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 05:26:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="jD/02zRq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C75C7214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4FF2A8E009D; Thu, 10 Jan 2019 00:26:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 487EB8E0038; Thu, 10 Jan 2019 00:26:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32A918E009D; Thu, 10 Jan 2019 00:26:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E2F1C8E0038
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 00:26:56 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id p9so6951651pfj.3
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 21:26:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=9u3C8NsSo0x9v2wiJfScrUNLdHkNf+XKWpTuuOQtYfk=;
        b=Vx53IJ5766N46J5QFuF7YgLZUFUXS9m1KielLR6gr+6H+VAEg7LTvdYZ9UkFgAfkTx
         owmrryLvJa1np2qrooABXyt8JI6OwyUblkjHgJqQSe7xL+NzTi/C0y5XJbEh1SVKfzcA
         jzYomX+bF7NIFaXrhoT0EJ6/yEH8FghfhrkCDaf3u+jU3iesQ1ggiyThrUbbJbNKSToD
         cdykVqAHfDerqr9Dv7yoI3peiV/EL0AUCUM9G3eNQKYj3DiebpUB9AGEjxt/S+Vvdr3M
         D8EO8r1p9n6+m1GGW8olAeoXDSudSq/74uJQ87+noygp9oiFkfOc5Wy4T0rf+Y4KZn8t
         PMFA==
X-Gm-Message-State: AJcUukdttiRZowr5TWhVFBtWAxTxN7GXC22JMv2nDTqomyAOHiYD9yCT
	r2CcQCYVXkHtCMEMeidl9PuTs2/8EYSse9VLxfnN4Wx3rzpNHSV7L7ohLGH8dENGPKw+Qg80xLD
	geQvoASVFeFd4DG/MbG0Y0HjFkECC8RCMU/jGejZ5fzBcEa348bRzo5juWGyJKjTcrg==
X-Received: by 2002:a17:902:8641:: with SMTP id y1mr8962660plt.159.1547098016454;
        Wed, 09 Jan 2019 21:26:56 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5GxY/O6TjivOLN+VVQqMj7Ceq9EikZ05OitR35vJmv4gCadSbPFIF0Zfw2fqAuN/LrBGYi
X-Received: by 2002:a17:902:8641:: with SMTP id y1mr8962613plt.159.1547098015378;
        Wed, 09 Jan 2019 21:26:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547098015; cv=none;
        d=google.com; s=arc-20160816;
        b=tLv5iLA7TT4BMU2P4ew54A0F0d16DyVkKCq2QNwq1fanzsroqztGazu8Kj68DikNgD
         gKe27wUSEIPLlgWf7b2ziZJRkuP46Ip77Dc3qvYR8SHP6yKgtvruJ7hPjb1mQDKki4uw
         KNbNYZvSu6n9AEZm+TYv2nHoAn+CaL9EcQidTSTXTZItPl96CXqIbGArq3YfX9F8wzNI
         KfBgS65P/YJ7cXc8QbkHq1C1C3dzxJ+JivkgQP50YPFoMc9gi95k7sWhRNUJwHMMG1Or
         KASvLMaGW8M4JF2je7hzIRu0RIUeKH4sya9pYxGdZYaqMUU3xVgtaCpFVu+PK+/gBpom
         w31g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=9u3C8NsSo0x9v2wiJfScrUNLdHkNf+XKWpTuuOQtYfk=;
        b=NezIFR1T+5oaq9tLx9yH+KnIat7Pvdn5AWpOf47bGqW3hUt5fA56JH5raRd9FKTPoE
         lXF1mcjgSZLjquT+yCSqiia1zUg7quXP18hULOLMamVUjOjBQmH/ZG14zHgLgiY4VYI0
         AgCAAbxoXT4tgh3nq9vEuEGcFnADQr0M0zAg5cG8bkasglm7EXwHt8UJIFdgHLMnfKtn
         qki/7KI9DV5Y6QnBPHfc5UnxUG+FEyD20Eb2FTTluDK2T2wLqCY/8fCGVeokYRp/c3Su
         R+9HNBYlR8cb6UOAnkA9gd654K4rMTu7QVkhhI3Rx0UuSCOkRhZd2fHqY5gTHm+vuokk
         0pPg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="jD/02zRq";
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y73si32638733pgd.478.2019.01.09.21.26.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 21:26:55 -0800 (PST)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="jD/02zRq";
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f47.google.com (mail-wr1-f47.google.com [209.85.221.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A2F7F2173B
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 05:26:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1547098014;
	bh=wLCgdOnFpGnaabfvxmw/GIzvBYL8EOsxdXCRQtu+b6k=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=jD/02zRqVYSLcRrm0k2aZShqQUWWW+GD3v9RvxvyhPy6GmZ0TU1ixnEOsH+MLsHq9
	 o/vzoNGEdLYBQaDc6ZfcDAodXLaP1QD4Bfr3XjPvXw8yRkwWpWDIbSBiZZiORkJYh5
	 NXMLOhIPnKggXexhrPZmXTupic4JfR08yVnP/9YE=
Received: by mail-wr1-f47.google.com with SMTP id z5so9847954wrt.11
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 21:26:54 -0800 (PST)
X-Received: by 2002:adf:f0c5:: with SMTP id x5mr7264313wro.77.1547098013084;
 Wed, 09 Jan 2019 21:26:53 -0800 (PST)
MIME-Version: 1.0
References: <20190106001138.GW6310@bombadil.infradead.org> <CAHk-=wiT=ov+6zYcnw_64ihYf74Amzqs67iVGtJMQq65PxiVYw@mail.gmail.com>
 <CAHk-=wg1A44Roa8C4dmfdXLRLmNysEW36=3R7f+tzZzbcJ2d2g@mail.gmail.com>
 <CAHk-=wiqbKEC5jUXr3ax+oUuiRrp=QMv_ZnUfO-SPv=UNJ-OTw@mail.gmail.com>
 <20190108044336.GB27534@dastard> <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com>
 <20190109022430.GE27534@dastard> <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm>
 <20190109043906.GF27534@dastard> <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
 <20190110004424.GH27534@dastard> <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
In-Reply-To: <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 9 Jan 2019 21:26:41 -0800
X-Gmail-Original-Message-ID: <CALCETrWxwaBUYMg=aLySJByMgXzuzV4gHS0n6O6Oet2Jm6SAbw@mail.gmail.com>
Message-ID:
 <CALCETrWxwaBUYMg=aLySJByMgXzuzV4gHS0n6O6Oet2Jm6SAbw@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Jiri Kosina <jikos@kernel.org>, 
	Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, 
	Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, 
	kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190110052641.-QM9FJqxudpddrLR23zHbQ6j_2HAqT8fonSXCeIq9Mw@z>

On Wed, Jan 9, 2019 at 5:18 PM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> On Wed, Jan 9, 2019 at 4:44 PM Dave Chinner <david@fromorbit.com> wrote:
> >
> > I wouldn't look at ext4 as an example of a reliable, problem free
> > direct IO implementation because, historically speaking, it's been a
> > series of nasty hacks (*cough* mount -o dioread_nolock *cough*) and
> > been far worse than XFS from data integrity, performance and
> > reliability perspectives.
>
> That's some big words from somebody who just admitted to much worse hacks.
>
> Seriously. XFS is buggy in this regard, ext4 apparently isn't.
>
> Thinking that it's better to just invalidate the cache  for direct IO
> reads is all kinds of odd.
>

This whole discussion seems to have gone a little bit off the rails...

Linus, I think I agree with Dave's overall sentiment, though, and I
think you should consider reverting your patch.  Here's why.  The
basic idea behind the attack is that the authors found efficient ways
to do two things: evict a page from page cache and detect, *without
filling the cache*, whether a page is cached.  The combination lets an
attacker efficiently tell when another process reads a page.  We need
to keep in mind that this attack is a sophisticated attack, and anyone
using it won't have any problem using a nontrivial way to detect
whether a page is in page cache.

So, unless we're going to try for real to make it hard to tell whether
a page is cached without causing that page to become cached, it's not
worth playing whack-a-mole.  And, right now, mincore is whacking a
mole.  RWF_NOWAIT appears to do essentially the same thing at very
little cost.  I haven't really dug in, but I assume that various
prefaulting tricks combined with various pagetable probing tricks can
do similar things, but that's at least a *lot* more complicated.

So unless we're going to lock down RWF_NOWAIT as well, I see no reason
to lock down mincore().  Direct IO is a red herring -- O_DIRECT is
destructive enough that it seems likely to make the attacks a lot less
efficient.


--- begin digression ---

Since direct IO has been brought up, I have a question.  I've wondered
for years why direct IO works the way it does.  If I were implementing
it from scratch, my first inclination would be to use the page cache
instead of fighting it.  To do a single-page direct read, I would look
that page up in the page cache (i.e. i_pages these days).  If the page
is there, I would do a normal buffered read.  If the page is not
there, I would insert a record into i_pages indicating that direct IO
is in progress and then I would do the IO into the destination page.
If any other read, direct or otherwise, sees a record saying "under
direct IO", it would wait.

To do a single-page direct write, I would look it up in i_pages.  If
it's there, I would do a buffered write followed by a sync (because
applications expect a sync).  If it's not there, I would again add a
record saying "under direct IO" and do the IO.

The idea is that this works as much like buffered IO as possible,
except that the pages backing the IO aren't normal sharable page cache
pages.

The multi-page case would be just an optimization on top of the
single-page case.  The idea would be to somehow mark i_pages with
entire extents under direct IO.  It's a radix tree -- this can, at
least in theory, be done efficiently.  As long as all direct IO
operations run in increasing order of offset, there shouldn't be lock
ordering problems.

Other than history and possibly performance, is there any reason that
direct IO doesn't work this way?

P.S. What, if anything, prevents direct writes from causing trouble
when the underlying FS or backing store needs stable pages?
Similarly, what, if anything, prevents direct reads from temporarily
exposing unintended data to user code if the fs or underlying device
transforms the data during the read process (e.g. by decrypting
something)?

--- end digression ---

