Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21437C48BD7
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 02:00:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AACDC21655
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 02:00:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="VwxNwghj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AACDC21655
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20B8F6B0003; Tue, 25 Jun 2019 22:00:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 193408E0003; Tue, 25 Jun 2019 22:00:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 00C808E0002; Tue, 25 Jun 2019 22:00:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 900A66B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 22:00:20 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id r21so168259ljr.5
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 19:00:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ZsgDSI95KqePAPPmaFBiHY1206TOaDNoZExEWQf1Sgo=;
        b=mbkV3Taf7yO8J5M4JARVI4N5dBHpk58vziANU6QsYbh0TOyDno054Lk7D1aGkNN2uf
         EqzyVkoxdn5rc6Iza4g7CNa4BvmXYYsG7ppMPqY4YnXVh1yxEQsmiTVxVuKwtUoyXTaG
         24hvnSaigPAci6XT/y/BCGtDH5cAdxeXT6I77sHud5aCRo/aiLIgJaK9XBSLXi2/A9IF
         rxnnS444y5tP0tPfr29zL/PYkWcpNt1HSYDuLR/06SqJ6LdfOG9yBFn4aSOTMtlIseB1
         PTiYe+rXXZf6fGUK5TDZtw7Fh8gAFq5gUXZ1Clf6ZUqmoO6bpTOFLUb98UWk1IQK0VZi
         z7nQ==
X-Gm-Message-State: APjAAAU76GdcVu5w4I6jPWDy5RF58T66gc9TIo+Z/4zceA3U77zJvkLG
	xmHP2GdE07H57/l7EOWZhyCSY+f9a3EVG2oUZkjRfAUzdnrlHLF+WAQ85DLRmubZsRmTXUP8sMj
	0cBKu4eF8NYzFPr94Zpj5sF2d/w8lC5cUY9xH7pB8aANUSKzX7FmUmPq5mLa5+abOFw==
X-Received: by 2002:a19:4a49:: with SMTP id x70mr926499lfa.151.1561514419693;
        Tue, 25 Jun 2019 19:00:19 -0700 (PDT)
X-Received: by 2002:a19:4a49:: with SMTP id x70mr926462lfa.151.1561514418588;
        Tue, 25 Jun 2019 19:00:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561514418; cv=none;
        d=google.com; s=arc-20160816;
        b=V5CkRPR3eGhZH9xuQh0p1yU4vqMbfz9QD1zGijYJhujTKHGz1DXyWyAA35wn6Rj2sP
         ZpxmXR0tRzty9Uos35GqHUb+ed0LdSLTBBi7+uyw28Cug6TGwqMc0lfGMNSru4Ok5He0
         M2RZ13HV+WTwLcZWDHaVV5YFrxfVxJNCi2zGaAp6S4LNpPW6shaCyJHDo42F/igx7itk
         PZuzmBuQCjzmcKt3uJBfZB7D8SgADGW0FGFjBFNwv/ZH14ajYUbvs9J1t5tMq1r+9yAY
         kx1wV1Wikntn+XwBksvKg7Di2nFpMOicQ2Exefp6rVHsZ+Hl9iRehGmErCSzs3rF9I1z
         lHVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ZsgDSI95KqePAPPmaFBiHY1206TOaDNoZExEWQf1Sgo=;
        b=mmhCmNf3r/0xNPfoYyAlJ16ALrQoxARrdw3ZkNDfLrKsMos+AtddWxmq4ZJb5q13zC
         +dIEwIFj8lMGkFwvpL96D+KYOU42OHeQoI450R/M6SGthXcnqDdea46cDs3emQy7iuY/
         bVTDj+Sjjtm5+VlO7aMzMItOzAxxznUutwi57Y23SlRMg3kIKeBRNadHtMgU0lJ1jQ3o
         pPnyAowu7cnubHaTynymDeJcfB8DvMNWjZIOY6tjj3+HwZ8u1jJsB3v4PQF4knY1o2H9
         yMXbeq6iz9uz6Zjt6/6R4KrPPVlHy/AIikMD4aepqpKj7SCOMNGQiV/7wurYYuWXAFGZ
         Uepg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=VwxNwghj;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q7sor8419040lje.0.2019.06.25.19.00.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Jun 2019 19:00:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=VwxNwghj;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ZsgDSI95KqePAPPmaFBiHY1206TOaDNoZExEWQf1Sgo=;
        b=VwxNwghjBlw6GDL//RFARFoXaDXKpoQaUs6zJSY4ZWsCZaI26bo7Npqkcj1+QDQtcx
         GVs1+ScO8o6NledD1rJbu3+AA5VOwqzSvHJzkC9ABBvPoIuMq+feRogzt1wHTnXJbjmu
         We4/fXRgj5n6LY0T1QL70h/w/6qH6xvQq668w=
X-Google-Smtp-Source: APXvYqzh81bKaizG62L2LPmPZM21yC0r8fGUBAcHaGhpjBTihcDUBW+o+QS+mZHGl7UW5r/Arci8eQ==
X-Received: by 2002:a2e:9e81:: with SMTP id f1mr956434ljk.29.1561514416893;
        Tue, 25 Jun 2019 19:00:16 -0700 (PDT)
Received: from mail-lf1-f48.google.com (mail-lf1-f48.google.com. [209.85.167.48])
        by smtp.gmail.com with ESMTPSA id 24sm2986327ljs.63.2019.06.25.19.00.14
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 19:00:14 -0700 (PDT)
Received: by mail-lf1-f48.google.com with SMTP id a25so406371lfg.2
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 19:00:14 -0700 (PDT)
X-Received: by 2002:ac2:44c5:: with SMTP id d5mr993375lfm.134.1561514414187;
 Tue, 25 Jun 2019 19:00:14 -0700 (PDT)
MIME-Version: 1.0
References: <20190620022008.19172-1-peterx@redhat.com> <20190620022008.19172-3-peterx@redhat.com>
 <CAHk-=wiGphH2UL+To5rASyFoCk6=9bROUkGDWSa_rMu9Kgb0yw@mail.gmail.com>
 <20190624074250.GF6279@xz-x1> <CAHk-=whRw_6ZTj=AT=cRoSTyoEk2-hiqJoNkqgWE-gSRVE5YwQ@mail.gmail.com>
 <20190625053047.GC10020@xz-x1>
In-Reply-To: <20190625053047.GC10020@xz-x1>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 26 Jun 2019 09:59:58 +0800
X-Gmail-Original-Message-ID: <CAHk-=wjxOz5RXpFTU=wSJg4Mjg1ugOBhBVppSTH6qjZPxpGOKg@mail.gmail.com>
Message-ID: <CAHk-=wjxOz5RXpFTU=wSJg4Mjg1ugOBhBVppSTH6qjZPxpGOKg@mail.gmail.com>
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

On Tue, Jun 25, 2019 at 1:31 PM Peter Xu <peterx@redhat.com> wrote:
>
> Yes that sounds reasonable to me, and that matches perfectly with
> TASK_INTERRUPTIBLE and TASK_KILLABLE.  The only thing that I am a bit
> uncertain is whether we should define FAULT_FLAG_INTERRUPTIBLE as a
> new bit or make it simply a combination of:
>
>   FAULT_FLAG_KILLABLE | FAULT_FLAG_USER

It needs to be a new bit, I think.

Some things could potentially care about the difference between "can I
abort this thing because the task will *die* and never see the end
result" and "can I abort this thing because it will be retried".

For a regular page fault, maybe FAULT_FLAG_INTERRUPTBLE will always be
set for the same things that set FAULT_FLAG_KILLABLE when it happens
from user mode, but at least conceptually I think they are different,
and it could make a difference for things like get_user_pages() or
similar.

Also, I actually don't think we should ever expose FAULT_FLAG_USER to
any fault handlers anyway. It has a very specific meaning for memory
cgroup handling, and no other fault handler should likely ever care
about "was this a user fault". So I'd actually prefer for people to
ignore and forget that hacky flag entirely, rather than give it subtle
semantic meaning together with KILLABLE.

[ Side note: this is the point where I may soon lose internet access,
so I'll probably not be able to participate in the discussion any more
for a while ]

             Linus

