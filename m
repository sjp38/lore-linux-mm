Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4D20C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 19:33:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8FA3A2175B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 19:33:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="MkCahJzn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8FA3A2175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F98B6B0005; Wed, 24 Apr 2019 15:33:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A9596B0006; Wed, 24 Apr 2019 15:33:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 297726B0007; Wed, 24 Apr 2019 15:33:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0809F6B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 15:33:25 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id a64so4132545ith.0
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 12:33:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=wflHOq/5T+ZXCjWUuQ+Otw4+acC/CT36CLZGEdvvwaE=;
        b=CiGQDmOVNruEMODkvCDgqPL8SV8cNWPZ+sjxKnzk9YZx3IIX19RRCX80HEw00Apa7V
         cbgacy6Q7FaWkrnYjnDdVb++U6i3zzvcOFZ4peyUTSZb3KKkcOyMMi+m6PPUsYTNsMdr
         A2KW63vNTEYy0ztMdIxf8XfQg6YUr6Xok7GbG/BBrWN37+QQg/yaQsG5+Wph0pA1FNag
         d0yMaVrZDFPPpBJP4iRSKSE7bCOKEzlXtcacy9+Tixs0QwrJy0IFw/p38rhrL3rLXQsJ
         iPK75ZURqnRBIjtEcj0GUNN5hkw/Lqq69lfbDztRxSCbpZ+/z6AtEy5n1wb7Yie6Z6pt
         yXvg==
X-Gm-Message-State: APjAAAURwoK2iaPOVXOtLJEJdiMB4+DAyKM28xVIuAp3nWNkT+F4x3rE
	DUyq0v9BiJztcXI40EqSXnroEV3BOkK9cDpcjgx2iQSnBEHWLpiiCf/bowRou7LX0W35cQzrZXD
	ZeX6FaK3usPNzlMKyZOhPeAbf4HpaAXOuAqP+HJpyjbB5Z8Ahr6irjeADq3TFPPTArw==
X-Received: by 2002:a5d:9715:: with SMTP id h21mr23554262iol.266.1556134404760;
        Wed, 24 Apr 2019 12:33:24 -0700 (PDT)
X-Received: by 2002:a5d:9715:: with SMTP id h21mr23554230iol.266.1556134404188;
        Wed, 24 Apr 2019 12:33:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556134404; cv=none;
        d=google.com; s=arc-20160816;
        b=NF0LKtgHRcCD5+cK3xSHIiBikO3dhmeYYRKD3V3gkGQSj7tVxic77bHsVwU/J8Jh5o
         +WDVkvefS+IH72wR8FSmFVk8g++rD6FAoHa6e2WueyINs6Opdq6q6ibfgxs+1gj3CRQP
         4yLlS6th1TWbeF5pvl/ePUGwzOf/wLMkbUhdGB6uRNeQ0uqkedrurxaSQk4ocDO7sV1p
         baLpAM3LJPoDInrn7lP8O/2X6ZfyhiGkfT83NoGCrYnF4mtvIPHxJsrftULhdqElyQJ9
         DAKZ6fgX8gGTDKRy/BqP0eVTIbmWgZMlBGNQS0gdFCrt3u2oxyTI+tWn/iGOrCz6XjQB
         PA6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=wflHOq/5T+ZXCjWUuQ+Otw4+acC/CT36CLZGEdvvwaE=;
        b=z4O4oSEph6ggpOUSO1hBnJA20E0RmVYX+yyjT/rXJNpMe+5LH0ekQ59tdFn5hDzAe4
         xdG7tZHakKXe7oJQQDYDEYkKR7f5714Lz1R8yg+JoKmHq3sXhfcAZp5d7tR657wk9kN0
         85rP+mHi4KWhisar1T6qKeNFi8cPC3IxYgy7B5ofpYDscEallc4n00O0sqtaa0oBoY29
         uKhYHn7kwp4FU6ZbXCLTpFO6G/p8mR15c+Ch58vP9oyEYk7CkikZZnHwfCGeft8uEOXf
         LxqCr/0fz7OcY+E8QWsTEg9xlrvlAnuIct6C1mNi+Cu5Y+nBRBbN7dkwgrJabYwsSIgC
         R7dA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=MkCahJzn;
       spf=pass (google.com: domain of matthewgarrett@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matthewgarrett@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v14sor8281719ioh.119.2019.04.24.12.33.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Apr 2019 12:33:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of matthewgarrett@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=MkCahJzn;
       spf=pass (google.com: domain of matthewgarrett@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matthewgarrett@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=wflHOq/5T+ZXCjWUuQ+Otw4+acC/CT36CLZGEdvvwaE=;
        b=MkCahJznroJgkW0oElWPSJZfpPCaob0MRXbne3p3BT20DPsC6WzDWFDMguURI7KEUc
         eANX+vUFF7XOTjHjzkp4FeIoH0JkOadAa4TE/mga9BWwa5PLIMpcbSpg/bJZFOSwVKCV
         4Q7yDEfqH7zZT5ycivz/8LjKPa/uL3SuZxwEwYaUJLUsO5HviFOpxD7/3PxprCQCp6QS
         0Z/oojm96tqPir32wttihXjEo7Ts9fdxtgme0APOa5EClsFWIwjfz8ARQdsqd7l8fN8h
         JlnEj4rUMmtRngVS+A9XBCncRgF9xq4HnyQYmm8OF5ZHrqmmgl7tApaprI1Y8fuIB/Md
         T67A==
X-Google-Smtp-Source: APXvYqyZ6gkVfnPB+2Wm+lmoiD9i9oQZ/3gTK2G6IZU6rxzaYekMVKzu1A48tZlKywRxbPgn3/pfxDfejrLw0asL8wg=
X-Received: by 2002:a5e:8348:: with SMTP id y8mr21067935iom.88.1556134403324;
 Wed, 24 Apr 2019 12:33:23 -0700 (PDT)
MIME-Version: 1.0
References: <20190424191440.170422-1-matthewgarrett@google.com> <20190424192812.GG19031@bombadil.infradead.org>
In-Reply-To: <20190424192812.GG19031@bombadil.infradead.org>
From: Matthew Garrett <mjg59@google.com>
Date: Wed, 24 Apr 2019 12:33:11 -0700
Message-ID: <CACdnJutj4K1kQj7yXcCNVWM_hmrUwMfZ-JBi=FHkBvYFfbJNZA@mail.gmail.com>
Subject: Re: [PATCH] mm: Allow userland to request that the kernel clear
 memory on release
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 24, 2019 at 12:28 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Wed, Apr 24, 2019 at 12:14:40PM -0700, Matthew Garrett wrote:
> > Unfortunately, if an application exits uncleanly, its secrets may still be
> > present in RAM. This can't be easily fixed in userland (eg, if the OOM
> > killer decides to kill a process holding secrets, we're not going to be able
> > to avoid that), so this patch adds a new flag to madvise() to allow userland
> > to request that the kernel clear the covered pages whenever the page
> > reference count hits zero. Since vm_flags is already full on 32-bit, it
> > will only work on 64-bit systems.
>
> Your request seems reasonable to me.
>
> > +++ b/include/linux/page-flags.h
> > @@ -118,6 +118,7 @@ enum pageflags {
> >       PG_reclaim,             /* To be reclaimed asap */
> >       PG_swapbacked,          /* Page is backed by RAM/swap */
> >       PG_unevictable,         /* Page is "unevictable"  */
> > +     PG_wipeonrelease,
>
> But you can't have a new PageFlag.  Can you instead zero the memory in
> unmap_single_vma() where we call uprobe_munmap() and untrack_pfn() today?

Is there any way the page could be referenced by something other than
a VMA at this point? If so we probably don't want to zero it here, but
we do want to zero it when the page is finally released (which is why
I went with a page flag)

