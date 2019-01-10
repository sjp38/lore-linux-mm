Return-Path: <SRS0=Jdrj=PS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43ADAC43387
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 01:18:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EEAE0214C6
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 01:18:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="KxLo6GfD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EEAE0214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 769C58E009D; Wed,  9 Jan 2019 20:18:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6EFE48E0038; Wed,  9 Jan 2019 20:18:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E20E8E009D; Wed,  9 Jan 2019 20:18:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id E2E2D8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 20:18:42 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id v74-v6so2290658lje.6
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 17:18:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=82vvuXTKjvPXqY9eZYLT5Juayyl3yZ2lLShppvfB5ig=;
        b=f2u6b/QBX/6wynvadIAPNEg0s9Pgiy0aa+Hf+pG+cSIMAH0m5HvBpffpTi4LcUF6Ps
         ThnzgmTAyB59JLrakSuzLw0QruMNrt3eXM/Ng+Fwua7yqVEXUnkMd+BeFQ0w9s8DCn2v
         Jnl1kiu0uifo68pOZJar0whMOTipcgyu/qvXavEH9Q4q6XGrBtYL4c2eu8jRfuEV61jU
         CknRm+lJp0dlwE+SxsfRD++W8UyUn65IUFLM7+9B7d7+LZSuReerDbLU7I8gjYxMdCjv
         WBO+fIYVC9plvOqnqKiyWNG3y631jEIc65WtlQQyQg3k/84OyBIvKr5LBBV4yjYqv1bT
         /ooA==
X-Gm-Message-State: AJcUukeXdA5rRzzAEva9hv6OLM3yfIhXDJz2gwFGVUOtbdu0uxFqVnKq
	d6g9lJJd5OesJwkT1es9RHhSRJyrpTxQ1uErYYZ/QUesACZmFihUuI5hrIgVVnVgY1Dcscn2WKx
	JDtBwsD+evsbUm8xLiqfDDbrWfgSxckJcfGVCp6OjGiFkpS8pNMg2e3Hm4u6oxARO+SoJYcy4pS
	InuDH9ifN9Y9/XqkTNC1TBerPPors2xdWg9Z0qUtF9BIcYNJqGPUmAjYH6YcwUrWc5pBI66YEzi
	DIep8qO9itu3FEXVai3LqID3RESjcvH+NI0Puf8+U8D2wGk4wCxLKP5U6JNgP//aa/BAMPsTF/C
	k/p9tMfe7ydeMpk7wcXDZHJSuGvUr975Ad/D9OOCqvxZMI/M2bxjA9216u0mIYmGsbMs2zg50WR
	u
X-Received: by 2002:a2e:92:: with SMTP id e18-v6mr5148984lji.130.1547083122032;
        Wed, 09 Jan 2019 17:18:42 -0800 (PST)
X-Received: by 2002:a2e:92:: with SMTP id e18-v6mr5148965lji.130.1547083120914;
        Wed, 09 Jan 2019 17:18:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547083120; cv=none;
        d=google.com; s=arc-20160816;
        b=PRlebNHG76dAMmZDHBRdtVVk3ivFzWSgFbyI9UCn0qlwTIzQ1r4TVr5qtaBxWl91uI
         Es4j9B7Hd5A5T50MxTpxzNPd0vKycZ7cQXKtTi/JsMEiRivBfmd4E75h0T/J7ZWLGhgF
         BC450kRUYWIVWIcLEgh/6KbraUvZD/03TTAK6Omq3eaVqOGS0g6/uTupbbjIfMNfmPiw
         E3hLXKANR1QRiWGv4t5nTK3I7oBKPFkN4XhipqEx2OwGo6Z+keeArO+HPP/rYslFVmX1
         xZWHZDCzzTnbzH5CWrAMfFN/V3MfbLJGLeCNDsnau6dyxYN4TCQd85qkXuHIerDNQbjB
         TQ1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=82vvuXTKjvPXqY9eZYLT5Juayyl3yZ2lLShppvfB5ig=;
        b=ML4EEXWbVg5NWWrmDqd9Qt6JEyfGKSloukDvjZn6MNfqZ28mUshp2XSgCau0rk8F0K
         7gmTGjr2xSPwMVjuytgo98ntQohXKMcWCIKrIpyqN2VpxITXHMgCZkQig60fYG2AG3E+
         84Eh5ItxC+kQFniq+ZOoLdfTuJksL7f2Wgn122vZDJT9By9Bb69Y6Q3JFZAvSL57AMXp
         PCvrdc1oIfPmW8gDIwjTCEMcfAg4zjw89zl6LZHXRMJOCSw5HkO6y4OtLq260zIwFQZi
         fOvXdIcJ+DuozdDzesfRagOkVO31RbvQ+LEFjTmUb0Hv+XdDMdY/eaf+rZFh97+b1L01
         eNhg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=KxLo6GfD;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x66-v6sor42680003ljb.20.2019.01.09.17.18.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 Jan 2019 17:18:40 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=KxLo6GfD;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=82vvuXTKjvPXqY9eZYLT5Juayyl3yZ2lLShppvfB5ig=;
        b=KxLo6GfDAV4uZwzb+AO0y4CW2SQaTeb7bSKg4sPn3tU31Sj3xClf3pkssmSIEVKj4a
         5tF2/WBR0ojdrQFPchyj/usU5H+/Tw49cSOH3RO66Otti6ncYBzubdwbAf5k2zbRCna8
         Ge53H/XsQVHszxlmK6fPk+u/GyLt3eVNUiq+E=
X-Google-Smtp-Source: ALg8bN5nBNRP8+owMmTB2KrApStVjCwkk2CHzlqTaVMrUtX3hmlXYphj8E9Lt2qzevNH1dfKBiHywQ==
X-Received: by 2002:a2e:7615:: with SMTP id r21-v6mr4491616ljc.131.1547083119586;
        Wed, 09 Jan 2019 17:18:39 -0800 (PST)
Received: from mail-lj1-f170.google.com (mail-lj1-f170.google.com. [209.85.208.170])
        by smtp.gmail.com with ESMTPSA id p10-v6sm15007636ljh.59.2019.01.09.17.18.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 17:18:38 -0800 (PST)
Received: by mail-lj1-f170.google.com with SMTP id t18-v6so8202115ljd.4
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 17:18:38 -0800 (PST)
X-Received: by 2002:a2e:95c6:: with SMTP id y6-v6mr4534294ljh.59.1547083117840;
 Wed, 09 Jan 2019 17:18:37 -0800 (PST)
MIME-Version: 1.0
References: <20190106001138.GW6310@bombadil.infradead.org> <CAHk-=wiT=ov+6zYcnw_64ihYf74Amzqs67iVGtJMQq65PxiVYw@mail.gmail.com>
 <CAHk-=wg1A44Roa8C4dmfdXLRLmNysEW36=3R7f+tzZzbcJ2d2g@mail.gmail.com>
 <CAHk-=wiqbKEC5jUXr3ax+oUuiRrp=QMv_ZnUfO-SPv=UNJ-OTw@mail.gmail.com>
 <20190108044336.GB27534@dastard> <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com>
 <20190109022430.GE27534@dastard> <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm>
 <20190109043906.GF27534@dastard> <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
 <20190110004424.GH27534@dastard>
In-Reply-To: <20190110004424.GH27534@dastard>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 9 Jan 2019 17:18:21 -0800
X-Gmail-Original-Message-ID: <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
Message-ID:
 <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
To: Dave Chinner <david@fromorbit.com>
Cc: Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, 
	Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, 
	kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190110011821.LVav8y44Uutbq46x3JLXPRN43e3H1uHcWGn2cTMUHCo@z>

On Wed, Jan 9, 2019 at 4:44 PM Dave Chinner <david@fromorbit.com> wrote:
>
> I wouldn't look at ext4 as an example of a reliable, problem free
> direct IO implementation because, historically speaking, it's been a
> series of nasty hacks (*cough* mount -o dioread_nolock *cough*) and
> been far worse than XFS from data integrity, performance and
> reliability perspectives.

That's some big words from somebody who just admitted to much worse hacks.

Seriously. XFS is buggy in this regard, ext4 apparently isn't.

Thinking that it's better to just invalidate the cache  for direct IO
reads is all kinds of odd.

                Linus

