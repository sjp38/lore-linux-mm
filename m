Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 52A306B0038
	for <linux-mm@kvack.org>; Sun, 18 Dec 2016 03:15:11 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id 2so25284276uax.4
        for <linux-mm@kvack.org>; Sun, 18 Dec 2016 00:15:11 -0800 (PST)
Received: from mail-ua0-x243.google.com (mail-ua0-x243.google.com. [2607:f8b0:400c:c08::243])
        by mx.google.com with ESMTPS id o1si1509630uaf.63.2016.12.18.00.15.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Dec 2016 00:15:10 -0800 (PST)
Received: by mail-ua0-x243.google.com with SMTP id y13so3323264uay.1
        for <linux-mm@kvack.org>; Sun, 18 Dec 2016 00:15:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161129143916.f24c141c1a264bad1220031e@linux-foundation.org>
References: <20161126201534.5d5e338f678b478e7a7b8dc3@gmail.com>
 <CALZtONCzseKs22189B3b+TEPKu8JPQ4WcGGB0zPj4KNuKiUAig@mail.gmail.com> <20161129143916.f24c141c1a264bad1220031e@linux-foundation.org>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Sun, 18 Dec 2016 09:15:09 +0100
Message-ID: <CAMJBoFNDw6gpnxrk35o9OW4qLJ87RHDfbYzhA9fqWr9WnuTVWw@mail.gmail.com>
Subject: Re: [PATCH 0/2] z3fold fixes
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Streetman <ddstreet@ieee.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Dan Carpenter <dan.carpenter@oracle.com>

On Tue, Nov 29, 2016 at 11:39 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Tue, 29 Nov 2016 17:33:19 -0500 Dan Streetman <ddstreet@ieee.org> wrot=
e:
>
>> On Sat, Nov 26, 2016 at 2:15 PM, Vitaly Wool <vitalywool@gmail.com> wrot=
e:
>> > Here come 2 patches with z3fold fixes for chunks counting and locking.=
 As commit 50a50d2 ("z3fold: don't fail kernel build is z3fold_header is to=
o big") was NAK'ed [1], I would suggest that we removed that one and the ne=
xt z3fold commit cc1e9c8 ("z3fold: discourage use of pages that weren't com=
pacted") and applied the coming 2 instead.
>>
>> Instead of adding these onto all the previous ones, could you redo the
>> entire z3fold series?  I think it'll be simpler to review the series
>> all at once and that would remove some of the stuff from previous
>> patches that shouldn't be there.
>>
>> If that's ok with Andrew, of course, but I don't think any of the
>> z3fold patches have been pushed to Linus yet.
>
> Sounds good to me.  I had a few surprise rejects when merging these
> two, which indicates that things might be out of sync.
>
> I presently have:
>
> z3fold-limit-first_num-to-the-actual-range-of-possible-buddy-indexes.patc=
h
> z3fold-make-pages_nr-atomic.patch
> z3fold-extend-compaction-function.patch
> z3fold-use-per-page-spinlock.patch
> z3fold-discourage-use-of-pages-that-werent-compacted.patch
> z3fold-fix-header-size-related-issues.patch
> z3fold-fix-locking-issues.patch

My initial suggestion was to have it the following way:
z3fold-limit-first_num-to-the-actual-range-of-possible-buddy-indexes.patch
z3fold-make-pages_nr-atomic.patch
z3fold-extend-compaction-function.patch
z3fold-use-per-page-spinlock.patch
z3fold-fix-header-size-related-issues.patch
z3fold-fix-locking-issues.patch

I would prefer to keep the fix-XXX patches separate since e. g.
z3fold-fix-header-size-related-issues.patch concerns also the problems
that have been in the code for a while now. I am ok with folding these
into the relevant main patches but once again, given that some fixes
are related to the code that is already merged, I don't see why it
would be better.

~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
