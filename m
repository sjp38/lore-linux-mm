Return-Path: <SRS0=B01V=PM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0F4DC43387
	for <linux-mm@archiver.kernel.org>; Fri,  4 Jan 2019 08:58:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 821B02184B
	for <linux-mm@archiver.kernel.org>; Fri,  4 Jan 2019 08:58:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="vuKrCxhZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 821B02184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 373848E00C7; Fri,  4 Jan 2019 03:58:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F8D58E00AE; Fri,  4 Jan 2019 03:58:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C5028E00C7; Fri,  4 Jan 2019 03:58:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id E3E2E8E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 03:58:06 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id o205so485478itc.2
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 00:58:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=20usoIc4RkJRiBEBTyYQHbq1Jt7l3TB1S1E8Xf7YN58=;
        b=tPVsse7FwVdK0th2gvXOgKMhrjgqZ0nlBCmG/aZz2RCOZQu2N4WK90h600hPpOa/Jz
         lmtAuO0seOgY89eSvTeBGEiEo//WcwvD/U6UNJMpD2YLarLqYM4mZvgWrXdogjwk7yiU
         1W3ccspIqHerQQuZHwzGtrgJxKjx0ZPzDv4bJeX3akqscLI5HItBhXY7OXVRWuroy+Ss
         FX6KpTF+yOb4VCe1RuPgoxoLeUNBD+mZzWtuC9gJ09NCgnxcZ/nDoO6R71FUpTp71MI5
         E8dX3nASRCdopzCJHpsjyKt1ByXNl1QSG6Mz96vM0U0snDBqXajooV4bAprqKR/XbtHe
         7lvQ==
X-Gm-Message-State: AJcUukdP1KGKyASUXTIbeVk9WRVetT6/C9bSmhfV85lLWc1RWth977ZN
	gjf0SAbHU9u+esG8imxQOo3TSufoOdXYKQaX7MgnYHp4RF3UlebVm7Y2skocRZlH9PlJom1Esi3
	cYiT9fdyHYl1AO7acnsPIS+BMIPyimOCDS8oc0aGd99cXR6Bwg4mz5jX8KqLPjiWkj/sEXGvuTw
	vRYtf3zljVjCIKoBYn4euqNk9Y+nB54FjQcAKxCFrtfVJuS5Wc0cEyaIx1AoGEWkK6hB0S/WH1N
	Cu7prozDUHqllJQ4vP/Uuf1wcLeRiwEYjlUDPJoO7NjouqmoxqEmdE3tCbL8mFUvtRb0whwl4tj
	luBlQuGhbGjJclcggWAmf50kfxa2h6l1qWh8/fZ6QvB9GB64xIroa9ILKUVcrnyG3xNaOqq7nOH
	m
X-Received: by 2002:a5d:9a84:: with SMTP id c4mr36720508iom.123.1546592286683;
        Fri, 04 Jan 2019 00:58:06 -0800 (PST)
X-Received: by 2002:a5d:9a84:: with SMTP id c4mr36720487iom.123.1546592286006;
        Fri, 04 Jan 2019 00:58:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546592286; cv=none;
        d=google.com; s=arc-20160816;
        b=vPTQajHHrWYP79+QMmG3ULyWwSrQTiMYlaqaCm9PBlaH8gABm+lpzPKyNQlECoE4aA
         hhcmoBwGULHpBG7S3bCbG+RNYgTVP1iP6HD1ujOQmciLuP4NFreKBr5hR3LhnGSbtcvo
         7GMFybZbhnml/3Xu644BW/qEV+ChDZqxAJnz5WRWXJFmg+y8WVmY+iM7Cwee+gzoDcP7
         589SIwN6rwkqa0y6LMYYQKv5LFJe4s3qqY8VELqSqCLLNNVy0LMf1BC3OWGH9NzomM5o
         q62nsUBsuViuZYZC6MNpT3X2kL+Wb61hChGOdI2dYq15EJ5eZaWCDfqFPHzUugERQzvy
         uz3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=20usoIc4RkJRiBEBTyYQHbq1Jt7l3TB1S1E8Xf7YN58=;
        b=NylaaLBaAhvMYWX3/zIijd+HoFh+666Xc5Cpj6KPGjwMyRUPpEe0QNJWn/fov5tS7A
         TLVv0+YH8DVsT8PtrTw/BOQi/bffRj3anAVXDWN4731OhoXLEOljRw7FstxoHE0V7fov
         vn4TkW28Q9kyvwEQbKsqRitN3D6YtxPe47uDbD9kyrR9OhTpbbW+y7kN1yh45EFK4KXD
         sDY4XzMMZhUKI3hrgkBLh8v4Leix0Zxlv8kYauDAKTNgjZ04bwcPG0AUxBTGCdAcDZSJ
         aHaYBwtn/TFMdyVowILYhKpo3upl/osiSHXhJZhGaQ7C7Wv28GeKta80XXbfI7xGHO0J
         VWAg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vuKrCxhZ;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b13sor1394383itc.1.2019.01.04.00.58.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 04 Jan 2019 00:58:05 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vuKrCxhZ;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=20usoIc4RkJRiBEBTyYQHbq1Jt7l3TB1S1E8Xf7YN58=;
        b=vuKrCxhZqA5l7H5Wi+/TUYqUIT95OSOWtAWoBrvDLvSO5SI5x3x/eBuYd9vJhnCLs/
         EUp3sByD67cqNh7z/YYEaPeuxexh+JQ2jscIS75yDSM08A5aeNnrnL4kO/5uGDv11haY
         pAWFl2sPWBkVjK8Ftz44xGAZThIt7RjzNB7JuHzRe+zs61hdpVJPsUt3Ms00gGJ032aO
         kUmzuoo6i3tFqR6blir6YsOEk7oO0Oy4xjc5en/u/vdanYrYLW4sik/8tL4Xkszq4biU
         b+AYUB+2W5VV0Qy3TFbfHt0STnZi+CnpuaLWJ6RpJ3rKTxFl+1qv+K/AgXxg6vx6uR1+
         FpIw==
X-Google-Smtp-Source: ALg8bN6Cy6jiOwdeoPsYLCKaE7+c5pzwCJpP999/XZx+O44Ih0ik7j+lZ+wuGIz97quRKepGhThWGzgD+Ezw/aqeyO8=
X-Received: by 2002:a05:660c:f94:: with SMTP id x20mr406231itl.144.1546592285557;
 Fri, 04 Jan 2019 00:58:05 -0800 (PST)
MIME-Version: 1.0
References: <000000000000c06550057e4cac7c@google.com> <a71997c3-e8ae-a787-d5ce-3db05768b27c@suse.cz>
 <CACT4Y+bRvwxkdnyRosOujpf5-hkBwd2g0knyCQHob7p=0hC=Dw@mail.gmail.com> <52835ef5-6351-3852-d4ba-b6de285f96f5@suse.cz>
In-Reply-To: <52835ef5-6351-3852-d4ba-b6de285f96f5@suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 4 Jan 2019 09:57:54 +0100
Message-ID:
 <CACT4Y+YazhPjqkTRgAkyTFTDujcUEm32TxCUxSGG2tu5zb1Xtw@mail.gmail.com>
Subject: Re: KMSAN: uninit-value in mpol_rebind_mm
To: Vlastimil Babka <vbabka@suse.cz>
Cc: syzbot <syzbot+b19c2dc2c990ea657a71@syzkaller.appspotmail.com>, 
	Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Alexander Potapenko <glider@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	linux@dominikbrodowski.net, Michal Hocko <mhocko@suse.com>, 
	David Rientjes <rientjes@google.com>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, 
	xieyisheng1@huawei.com, zhong jiang <zhongjiang@huawei.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190104085754.8uhmPQyGhYuDNNS0p3CaJVHu5pap7q-ZCn60owm-920@z>

On Fri, Jan 4, 2019 at 9:50 AM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 1/3/19 9:42 AM, Dmitry Vyukov wrote:
> > On Thu, Jan 3, 2019 at 9:36 AM Vlastimil Babka <vbabka@suse.cz> wrote:
> >>
> >>
> >> On 12/31/18 8:51 AM, syzbot wrote:
> >>> Hello,
> >>>
> >>> syzbot found the following crash on:
> >>>
> >>> HEAD commit:    79fc24ff6184 kmsan: highmem: use kmsan_clear_page() in cop..
> >>> git tree:       kmsan
> >>> console output: https://syzkaller.appspot.com/x/log.txt?x=13c48b67400000
> >>> kernel config:  https://syzkaller.appspot.com/x/.config?x=901dd030b2cc57e7
> >>> dashboard link: https://syzkaller.appspot.com/bug?extid=b19c2dc2c990ea657a71
> >>> compiler:       clang version 8.0.0 (trunk 349734)
> >>>
> >>> Unfortunately, I don't have any reproducer for this crash yet.
> >>>
> >>> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> >>> Reported-by: syzbot+b19c2dc2c990ea657a71@syzkaller.appspotmail.com
> >>>
> >>> ==================================================================
> >>> BUG: KMSAN: uninit-value in mpol_rebind_policy mm/mempolicy.c:353 [inline]
> >>> BUG: KMSAN: uninit-value in mpol_rebind_mm+0x249/0x370 mm/mempolicy.c:384
> >>
> >> The report doesn't seem to indicate where the uninit value resides in
> >> the mempolicy object.
> >
> > Yes, it doesn't and it's not trivial to do. The tool reports uses of
> > unint _values_. Values don't necessary reside in memory. It can be a
> > register, that come from another register that was calculated as a sum
> > of two other values, which may come from a function argument, etc.
>
> I see. BTW, the patch I sent will be picked up for testing, or does it
> have to be in mmotm/linux-next first?

It needs to be in upstream tree. Since KMSAN is not upstream, we have
only 1 branch that is based on upstream and is periodically rebased:
https://github.com/google/kmsan
If the bug would have a repro, then we could ask syzbot to test this
patch on top of KMSAN tree. But unfortunately it doesn't.

