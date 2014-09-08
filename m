Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id CE7176B0036
	for <linux-mm@kvack.org>; Mon,  8 Sep 2014 05:06:38 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id cc10so2269589wib.3
        for <linux-mm@kvack.org>; Mon, 08 Sep 2014 02:06:38 -0700 (PDT)
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
        by mx.google.com with ESMTPS id n8si12919410wib.82.2014.09.08.02.06.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Sep 2014 02:06:36 -0700 (PDT)
Received: by mail-wg0-f45.google.com with SMTP id z12so787950wgg.16
        for <linux-mm@kvack.org>; Mon, 08 Sep 2014 02:06:36 -0700 (PDT)
Date: Mon, 8 Sep 2014 10:06:27 +0100
From: Steve Capper <steve.capper@linaro.org>
Subject: Re: [PATCH V3 0/6] RCU get_user_pages_fast and __get_user_pages_fast
Message-ID: <20140908090626.GA14634@linaro.org>
References: <1409237107-24228-1-git-send-email-steve.capper@linaro.org>
 <20140828152320.GN22580@arm.com>
 <CAPvkgC0YVhPEBqbWSDnGyZBUn3+8Kv7-yx1-_n0Jx+giKzOqmw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPvkgC0YVhPEBqbWSDnGyZBUn3+8Kv7-yx1-_n0Jx+giKzOqmw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, Will Deacon <will.deacon@arm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "gary.robertson@linaro.org" <gary.robertson@linaro.org>, "christoffer.dall@linaro.org" <christoffer.dall@linaro.org>, "peterz@infradead.org" <peterz@infradead.org>, "anders.roxell@linaro.org" <anders.roxell@linaro.org>, "dann.frazier@canonical.com" <dann.frazier@canonical.com>, Mark Rutland <Mark.Rutland@arm.com>, "mgorman@suse.de" <mgorman@suse.de>

On Mon, Sep 01, 2014 at 12:43:06PM +0100, Steve Capper wrote:
> On 28 August 2014 16:23, Will Deacon <will.deacon@arm.com> wrote:
> > On Thu, Aug 28, 2014 at 03:45:01PM +0100, Steve Capper wrote:
> >> I would like to get this series into 3.18 as it fixes quite a big problem
> >> with THP on arm and arm64. This series is split into a core mm part, an
> >> arm part and an arm64 part.
> >>
> >> Could somebody please take patch #1 (if it looks okay)?
> >> Russell, would you be happy with patches #2, #3, #4? (if we get #1 merged)
> >> Catalin, would you be happy taking patches #5, #6? (if we get #1 merged)
> >
> > Pretty sure we're happy to take the arm64 bits once you've got the core
> > changes sorted out. Failing that, Catalin's acked them so they could go via
> > an mm tree if it's easier.
> >
> 
> Hello,
> 
> Are any mm maintainers willing to take the first patch from this
> series into their tree for merging into 3.18?
>   mm: Introduce a general RCU get_user_pages_fast.
> 
> (or please let me know if there are any issues with the patch that
> need addressing).
> 
> As Will has stated, Catalin's already acked the arm64 patches, and
> these can also go in via an mm tree if that makes things easier:
>   arm64: mm: Enable HAVE_RCU_TABLE_FREE logic
>   arm64: mm: Enable RCU fast_gup
> 
> Thanks,
> --
> Steve

Hi,
Just a ping on this.

I was wondering if the first patch in this series:

[PATCH V3 1/6] mm: Introduce a general RCU get_user_pages_fast.
http://marc.info/?l=linux-mm&m=140923713202355&w=2

could be merged into 3.18 via an mm tree, or if there are any issues
with the patch that I should fix?

Acks or flames from the mm maintainers would be greatly appreciated!

Cheers,
-- 
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
