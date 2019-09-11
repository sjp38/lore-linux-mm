Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EDA1C5ACAE
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 09:48:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B31412082C
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 09:48:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="GBg+WG4t"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B31412082C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4CDF46B0006; Wed, 11 Sep 2019 05:48:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4805F6B0007; Wed, 11 Sep 2019 05:48:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 346416B0008; Wed, 11 Sep 2019 05:48:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0127.hostedemail.com [216.40.44.127])
	by kanga.kvack.org (Postfix) with ESMTP id 0EF3F6B0006
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 05:48:21 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id B78F1180AD802
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 09:48:20 +0000 (UTC)
X-FDA: 75922164360.15.cork96_2baf3dc3a1e10
X-HE-Tag: cork96_2baf3dc3a1e10
X-Filterd-Recvd-Size: 6535
Received: from mail-lf1-f68.google.com (mail-lf1-f68.google.com [209.85.167.68])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 09:48:20 +0000 (UTC)
Received: by mail-lf1-f68.google.com with SMTP id q11so976753lfc.11
        for <linux-mm@kvack.org>; Wed, 11 Sep 2019 02:48:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=BX2UgWIYaZS7GTCdolEhAhZHFFy6otxnhMgv6RCaPJY=;
        b=GBg+WG4tmzlhXfbndZfH+tCEkx7MdTOMJWwACCf6jNvjYMxvAvxAWixx9vqpoArYjd
         MUyL45LzIccC8KYScLWsw6AqvNnf8TuOB9+Tx5MzVtLZ76TzUymunajVI6T4C3O55uwa
         OrlWaOg4WGa1pxlojNeYinPvEPcvknjjqYgA4=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=BX2UgWIYaZS7GTCdolEhAhZHFFy6otxnhMgv6RCaPJY=;
        b=hqZmVd00VbxwyhjefKd9lGXoWmTxnd1cK2G5QkNHxO2JAC2CDTJ+JQgik17XcaFBzx
         Pm1Ilkm/o4OgPkdm3djH2ZDE69AldYkoCpIlV6urmcXe1ODFp2OtROObyo8Rez5wS8ww
         2rMeY8ElVSpNV4IBp2rVWCG+Ijw4RqPe2Qfv8djqjUnNklSs30r+1V2rpmG7Hzi3iqC1
         6TTZW8MLO6itZPhUB4iIii0s4sTpY6QQrGGY5cXbW4YoZ7znKlNVpQGtNjYQwvNg3O6z
         YOIy2n4g5vOcSa6rRW85OLjPLHDmFbVqe5B9tdXvDPItpjdVL38qxm66XZmPAWRBbGZQ
         DFTQ==
X-Gm-Message-State: APjAAAWfN7mZMqxzB/hi+OwpaZ11V6BfOEMmfT/+bp2laAtelZCsvIV0
	CkPo2b6hAM6IdZzjy1iwXa+pK+JPbI00/A==
X-Google-Smtp-Source: APXvYqzdFcKIB8OgCaz8zw/IRUfOPcODfwDrlXWtSdr0T3CWAXdOf4VYO2phMtFhE7YfAlO6nxSJYg==
X-Received: by 2002:ac2:42c3:: with SMTP id n3mr24223191lfl.142.1568195297731;
        Wed, 11 Sep 2019 02:48:17 -0700 (PDT)
Received: from mail-lj1-f181.google.com (mail-lj1-f181.google.com. [209.85.208.181])
        by smtp.gmail.com with ESMTPSA id r11sm4438480ljh.23.2019.09.11.02.48.15
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 11 Sep 2019 02:48:16 -0700 (PDT)
Received: by mail-lj1-f181.google.com with SMTP id y23so19330613lje.9
        for <linux-mm@kvack.org>; Wed, 11 Sep 2019 02:48:15 -0700 (PDT)
X-Received: by 2002:a2e:988e:: with SMTP id b14mr9258852ljj.52.1568195295684;
 Wed, 11 Sep 2019 02:48:15 -0700 (PDT)
MIME-Version: 1.0
References: <20190911071007.20077-1-peterx@redhat.com> <20190911071007.20077-8-peterx@redhat.com>
In-Reply-To: <20190911071007.20077-8-peterx@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 11 Sep 2019 10:47:59 +0100
X-Gmail-Original-Message-ID: <CAHk-=wh03Qx6zNS_yhhsf5gPah=2=mi7+dKMNCVrKhw6+894ag@mail.gmail.com>
Message-ID: <CAHk-=wh03Qx6zNS_yhhsf5gPah=2=mi7+dKMNCVrKhw6+894ag@mail.gmail.com>
Subject: Re: [PATCH v3 7/7] mm/gup: Allow VM_FAULT_RETRY for multiple times
To: Peter Xu <peterx@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, David Hildenbrand <david@redhat.com>, 
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>, Jerome Glisse <jglisse@redhat.com>, 
	Pavel Emelyanov <xemul@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Martin Cracauer <cracauer@cons.org>, Marty McFadden <mcfadden8@llnl.gov>, Shaohua Li <shli@fb.com>, 
	Andrea Arcangeli <aarcange@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, 
	Denis Plotnikov <dplotnikov@virtuozzo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Mel Gorman <mgorman@suse.de>, "Kirill A . Shutemov" <kirill@shutemov.name>, 
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 11, 2019 at 8:11 AM Peter Xu <peterx@redhat.com> wrote:
>
> This is the gup counterpart of the change that allows the
> VM_FAULT_RETRY to happen for more than once.  One thing to mention is
> that we must check the fatal signal here before retry because the GUP
> can be interrupted by that, otherwise we can loop forever.

I still get nervous about the signal handling here.

I'm not entirely sure we get it right even before your patch series.

Right now, __get_user_pages() can return -ERESTARTSYS when it's killed:

        /*
         * If we have a pending SIGKILL, don't keep faulting pages and
         * potentially allocating memory.
         */
        if (fatal_signal_pending(current)) {
                ret = -ERESTARTSYS;
                goto out;
        }

and I don't think your series changes that.  And note how this is true
_regardless_ of any FOLL_xyz flags (and we don't pass the
FAULT_FLAG_xyz flags at all, they get generated deeper down if we
actually end up faulting things in).

So this part of the patch:

+               if (fatal_signal_pending(current))
+                       goto out;
+
                *locked = 1;
-               lock_dropped = true;
                down_read(&mm->mmap_sem);
                ret = __get_user_pages(tsk, mm, start, 1, flags | FOLL_TRIED,
-                                      pages, NULL, NULL);
+                                      pages, NULL, locked);
+               if (!*locked) {
+                       /* Continue to retry until we succeeded */
+                       BUG_ON(ret != 0);
+                       goto retry;

just makes me go "that can't be right". The fatal_signal_pending() is
pointless and would probably better be something like

        if (down_read_killable(&mm->mmap_sem) < 0)
                goto out;

and then _after_ calling __get_user_pages(), the whole "negative error
handling" should be more obvious.

The BUG_ON(ret != 0) makes me nervous, but it might be fine (I guess
the fatal signal handling has always been done before the lock is
released?).

But exactly *because* __get_user_pages() can already return on fatal
signals, I think it should also set FAULT_FLAG_KILLABLE when faulting
things in. I don't think it does right now, so it doesn't actually
necessarily check fatal signals in a timely manner (not _during_ the
fault, only _before_ it).

See what I'm reacting to?

And maybe I'm wrong. Maybe I misread the code, and your changes. And
at least some of these logic error predate your changes, I just was
hoping that since this whole "react to signals" is very much what your
patch series is working on, you'd look at this.

Ok?

            Linus

