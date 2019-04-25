Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DBA1C43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 20:44:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 820402084F
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 20:44:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="X2Y0UXdY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 820402084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DBCEA6B0003; Thu, 25 Apr 2019 16:44:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D6CA16B0005; Thu, 25 Apr 2019 16:44:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C817F6B0006; Thu, 25 Apr 2019 16:44:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id AB5466B0003
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 16:44:09 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id w9so986457ioc.1
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 13:44:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=9T6Hh/gfaAIMuibwKFS2lWem2Wt7fkhHXq9vbgpXfiI=;
        b=XERhBWWlO0xCvo+sbicnHkRUi/SKdROsIVSW5GR55t12p5Q1ExiHc12ea6q3HzTyQ+
         0QT4I7on9u2Fg9kMSMxmRnHa6D31Di7kM/GULDLB6tqe9gn73hc5Bbl4kKpU00chE749
         RTRAgmdIm3Qet5SvF228L+PWIOLJl+1NCLtgM0SplfqKDYfG8fFiJQSMJL5cuRnEyJMX
         aE0rXD+KmqI76l7vaOq/ZLKIGddJ+JtUIV5if40/YoOFsafIYCYri+xdjFRfbtzPm/KC
         wo9DmGzY4ET2Diabcpo7du8pxQdcHBUVDkcvXcvtBB9Lyx/E+eLxBINRcZLfjFvzjzIo
         bMxg==
X-Gm-Message-State: APjAAAU+uX2vw/uU/OF/0uwXOBUJOD6E6sYXwsneUpqH2LlUemkZmF4O
	B7A7bnVEI7b8r+9fNzKroMwvxBmlZ29H3U/I+iU3MFBq1pcrDmJqR1GxYx5TuvXrWHnwSWKKLz4
	ksv07H05EfYY1oiwspdqJUHE4QoDP3Rf1S5Zl6gKP3QoiHupiYPPLU0HkjeBD26MFFw==
X-Received: by 2002:a6b:6f07:: with SMTP id k7mr2459442ioc.271.1556225049427;
        Thu, 25 Apr 2019 13:44:09 -0700 (PDT)
X-Received: by 2002:a6b:6f07:: with SMTP id k7mr2459419ioc.271.1556225048913;
        Thu, 25 Apr 2019 13:44:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556225048; cv=none;
        d=google.com; s=arc-20160816;
        b=qeRBmKpT6PQadmey0ctbTNKMkgOmb9HrlHyg9RSBrQN0s9dclC9sex2F7TM1dgt04C
         NaX+m4tkcoqdN3Rw2BeliUAvYthmi08TwH5D8eQBwtaCQ5Kx6xGSFW+dmGir8g2rNxzZ
         vHPneDcW7fcLDcHXIH7c+u/ZyU1J7VT6PZvf0O5jTBgdC4FhLga+CkZv73+louxQfpMj
         PcEOqHbfOHoPULFh8i/eNcEvCYh5gOvymc1/o3uaErw+XVnStJoC84PxKN7tH47d4CwT
         GejF72fKQL3t8SnYTbYV0PHUSZcronhYWjLo/dQwUt0lrLjzOchFPcIz/+2pehV7KNAZ
         o41A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=9T6Hh/gfaAIMuibwKFS2lWem2Wt7fkhHXq9vbgpXfiI=;
        b=D7wiskk9tetTC6KgsdGKf7JNWD2SCGEBgkqaxuyQf4/rin7D0PgUbBdUH/3Xxz+KtX
         ksWx0QVhIrRfh1JSZngrTlfOS8NogjosJW2e9vMFeXja5QxI6SStv2Jd6bmfe+VZdmpn
         m0szMVMSaBVBw7P+iCCyD4M/tGlvL50eJoAVKs3uQpMT8nfDFZ+X4I1UhXR0Htl9hEFt
         OyzH/x8cMN0G5Hk0jFU8ofGYaAxwSINWIKp8RidyX+gAErko2CnkartXMZJoXUD9U/uZ
         jVxKHE4Jv2Mmc1Hll8Kpg3rANcGo79RtM6e/DMPh61fDuste+uLmi5d9LzEKI5JpGqcM
         czzw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=X2Y0UXdY;
       spf=pass (google.com: domain of matthewgarrett@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matthewgarrett@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 17sor33209253itl.16.2019.04.25.13.44.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Apr 2019 13:44:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of matthewgarrett@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=X2Y0UXdY;
       spf=pass (google.com: domain of matthewgarrett@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matthewgarrett@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=9T6Hh/gfaAIMuibwKFS2lWem2Wt7fkhHXq9vbgpXfiI=;
        b=X2Y0UXdYtsf1r8qUOurjsJI9eewtbXZBIc9FX3ykI64j+N6JDnvmPQgxohph6tOAzh
         7oT8+8CwhPf9xiD3Jz16lMZwg6HYfEE8hmUoI3+5Q24DAvTT3LMS318fjKrafBTKMLdp
         /QCm5H30eeFrFQyoJqAQU6mLKhoOiFOFRKOys6WzC7PITt6PGmRIb68eV+Q9vbOIF8Lp
         dqqIBIsuqZsLmIJYgH7ifXN/C6bkykkP+VnH630efhebTaBgEkxtI5L/ops1ha0ExfBP
         J1iXAkZ/9AP474L4907G3yTct2zTI6Gj5ZWvtNVMWWSZmkuBm4Tepf10tdXxOFJ9VNkb
         ZKGA==
X-Google-Smtp-Source: APXvYqxUbgSe5G0v+X+ayIdnr1/C14jU5CTpxKyeEQxe4lKH3qBoI0CAJN7yD+zzO60X6w4ddn4L7c2JaoYQn+CBs54=
X-Received: by 2002:a24:eb04:: with SMTP id h4mr3421463itj.16.1556225048269;
 Thu, 25 Apr 2019 13:44:08 -0700 (PDT)
MIME-Version: 1.0
References: <CACdnJuup-y1xAO93wr+nr6ARacxJ9YXgaceQK9TLktE7shab1w@mail.gmail.com>
 <20190424211038.204001-1-matthewgarrett@google.com> <20190425121410.GC1144@dhcp22.suse.cz>
 <CAG48ez0x6QiFpqXbimB9ZV-jS5UJJWhzg9XiAWncQL+phfKkPA@mail.gmail.com>
In-Reply-To: <CAG48ez0x6QiFpqXbimB9ZV-jS5UJJWhzg9XiAWncQL+phfKkPA@mail.gmail.com>
From: Matthew Garrett <mjg59@google.com>
Date: Thu, 25 Apr 2019 13:43:57 -0700
Message-ID: <CACdnJuu__NS3Py+heKPDdTJSe53Wr9AP-oArO7mVRky2wqMp2g@mail.gmail.com>
Subject: Re: [PATCH V2] mm: Allow userland to request that the kernel clear
 memory on release
To: Jann Horn <jannh@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 25, 2019 at 5:43 AM Jann Horn <jannh@google.com> wrote:
> An interesting effect of this is that it will be possible to set this
> on a CoW anon VMA in a fork() child, and then the semantics in the
> parent will be subtly different - e.g. if the parent vmsplice()d a
> CoWed page into a pipe, then forked an unprivileged child, the child
> set MADV_WIPEONRELEASE on its VMA, the parent died somehow, and then
> the child died, the page in the pipe would be zeroed out. A child
> should not be able to affect its parent like this, I think. If this
> was an mmap() flag instead of a madvise() command, that issue could be
> avoided. Alternatively, if adding more mmap() flags doesn't work,
> perhaps you could scan the VMA and ensure that it contains no pages
> yet, or something like that?

I /think/ my argument here would be not to do that? I agree that it's
unexpected, but I guess the other alternative would be to force a copy
on any existing COW pages in the VMA at madvise() time, and maybe also
at fork() time (sort of like the behaviour of MADV_WIPEONFORK, but
copying the page rather than providing a new zero page)

> I think all the callers have a reference to the VMA, so perhaps you
> could add a VMA parameter to page_remove_rmap() and then look at the
> VMA in there?

I'll dig into that, thanks!

