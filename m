Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA412C3A59E
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 16:37:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6FDC22133F
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 16:37:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="JfOVHWNQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6FDC22133F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 089506B0010; Fri, 16 Aug 2019 12:37:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 039206B0266; Fri, 16 Aug 2019 12:37:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E914D6B0269; Fri, 16 Aug 2019 12:37:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0059.hostedemail.com [216.40.44.59])
	by kanga.kvack.org (Postfix) with ESMTP id C83516B0010
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 12:37:05 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 783378248ACF
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 16:37:05 +0000 (UTC)
X-FDA: 75828845610.25.bread70_3dd35c28fc306
X-HE-Tag: bread70_3dd35c28fc306
X-Filterd-Recvd-Size: 5276
Received: from mail-ot1-f67.google.com (mail-ot1-f67.google.com [209.85.210.67])
	by imf03.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 16:37:04 +0000 (UTC)
Received: by mail-ot1-f67.google.com with SMTP id o101so10122955ota.8
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 09:37:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=3TjiC7tL5tVLJpZgBmmeBYDZnQ+YoBFviaBZJfxvqRo=;
        b=JfOVHWNQNFhlm05DIsQUQILP6M8uBwVqZSzqy1eYSpIOTEaQbCtHbvykAwr22Tl6G1
         RNXH1jUaj+1SuMHTPPN2vG+sS56vR/rcdrJk34I37Kr5H+ovEq9dCHTkoSWPVy5ywMLh
         lz1n0dh2WMbvNoSKqCFONNRk5N6dN3lYNnwsE=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=3TjiC7tL5tVLJpZgBmmeBYDZnQ+YoBFviaBZJfxvqRo=;
        b=l9aIKkWpqSzQhoHk0ypwWKILfW1BCq6E3EfdZ5H4muUyYoyCxXlPEbERTobUTfIS4Y
         mWOIYKJ8DYSllc3XlfcfYe9sU++iDX/fX8QeSlNqN/OmURXUkfsUVLfToY7yLkkgJu1o
         uUQ+J2iRp5TUT5IteB9agTNx3x0qu1uV86ZG22WQQRAXoCpCRFlw6XOst7FbX3fWevNT
         nC10KRfXRP+4o4voQnNdd7Ht9ayYgByuw0YD0CCW7t5hsrLwIq/4FE1bCuz71A+hvwFz
         dM/4Z69cIpz9+8xBDGhHFQSb6/uhf8vkR6aywxnty0xpWeae0ObdbshsTgzbce6f23e7
         RPMQ==
X-Gm-Message-State: APjAAAUbUBQabzjRtS67WoMrmb7bxixpLDZUP9qCWjWqe7a6ZcEB0s7r
	sCdxtQnawfeQdDk1JCIrtscqd6Yv8g/1AHBICwhVlg==
X-Google-Smtp-Source: APXvYqxJCBauYrVR7fqS+LuWRAKsoJ5dG70QezYi/k/QXJiyisCvN0d9PyJccgTFO91to0aqDKVlvYvo6VHCa8rK6mw=
X-Received: by 2002:a9d:1ca3:: with SMTP id l35mr7813768ota.106.1565973423804;
 Fri, 16 Aug 2019 09:37:03 -0700 (PDT)
MIME-Version: 1.0
References: <20190815190525.GS9477@dhcp22.suse.cz> <20190815191810.GR21596@ziepe.ca>
 <20190815193526.GT9477@dhcp22.suse.cz> <CAKMK7uH42EgdxL18yce-7yay=x=Gb21nBs3nY7RA92Nsd-HCNA@mail.gmail.com>
 <20190815202721.GV21596@ziepe.ca> <CAKMK7uER0u1TqeJBXarKakphnyZTHOmedOfXXqLGVDE2mE-mAQ@mail.gmail.com>
 <20190816010036.GA9915@ziepe.ca> <CAKMK7uH0oa10LoCiEbj1NqAfWitbdOa-jQm9hM=iNL-=8gH9nw@mail.gmail.com>
 <20190816121243.GB5398@ziepe.ca> <CAKMK7uHk03OD+N-anPf-ADPzvQJ_NbQXFh5WsVUo-Ewv9vcOAw@mail.gmail.com>
 <20190816143819.GE5398@ziepe.ca>
In-Reply-To: <20190816143819.GE5398@ziepe.ca>
From: Daniel Vetter <daniel@ffwll.ch>
Date: Fri, 16 Aug 2019 18:36:52 +0200
Message-ID: <CAKMK7uGzOO4nZPbZzmaDjjBGZiV2HjgdbT45q9Rd5wTO14VH2w@mail.gmail.com>
Subject: Re: [Intel-gfx] [PATCH 2/5] kernel.h: Add non_block_start/end()
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Michal Hocko <mhocko@kernel.org>, Feng Tang <feng.tang@intel.com>, 
	Randy Dunlap <rdunlap@infradead.org>, Kees Cook <keescook@chromium.org>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, Peter Zijlstra <peterz@infradead.org>, 
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>, Jann Horn <jannh@google.com>, 
	LKML <linux-kernel@vger.kernel.org>, 
	DRI Development <dri-devel@lists.freedesktop.org>, Linux MM <linux-mm@kvack.org>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, 
	David Rientjes <rientjes@google.com>, Wei Wang <wvw@google.com>, 
	Daniel Vetter <daniel.vetter@intel.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>, 
	=?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 4:38 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> On Fri, Aug 16, 2019 at 04:11:34PM +0200, Daniel Vetter wrote:
> > Also, aside from this patch (which is prep for the next) and some
> > simple reordering conflicts they're all independent. So if there's no
> > way to paint this bikeshed here (technicolor perhaps?) then I'd like
> > to get at least the others considered.
>
> Sure, I think for conflict avoidance reasons I'm probably taking
> mmu_notifier stuff via hmm.git, so:
>
> - Andrew had a minor remark on #1, I am ambivalent and would take it
>   as-is. Your decision if you want to respin.

I like mine better, see also the reply from Ralph Campbell.

> - #2/#3 is this issue, I would stand by the preempt_disable/etc path
>   Our situation matches yours, debug tests run lockdep/etc.

Since Michal requested the current flavour I think we need spin a bit
more on these here. I guess I'll just rebase them to the end so
they're not holding up the others.

> - #4 I like a lot, except the map should enclose range_end too,
>   this can be done after the mm_has_notifiers inside the
>   __mmu_notifier function

To make sure I get this right: The same lockdep context, but also
wrapped around invalidate_range_end? From my understanding of pte
zapping that makes sense, but I'm definitely not well-versed enough
for that.

>   Can you respin?

Will do.

>   I will propose preloading the map in another patch
> - #5 is already applied in -rc

Yup, I'll drop that one.

Thanks, Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

