Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id A106F6B0036
	for <linux-mm@kvack.org>; Fri, 19 Sep 2014 14:28:19 -0400 (EDT)
Received: by mail-we0-f177.google.com with SMTP id t60so191823wes.8
        for <linux-mm@kvack.org>; Fri, 19 Sep 2014 11:28:19 -0700 (PDT)
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
        by mx.google.com with ESMTPS id n3si137571wiy.15.2014.09.19.11.28.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 19 Sep 2014 11:28:18 -0700 (PDT)
Received: by mail-wg0-f43.google.com with SMTP id y10so135216wgg.14
        for <linux-mm@kvack.org>; Fri, 19 Sep 2014 11:28:17 -0700 (PDT)
Date: Fri, 19 Sep 2014 19:28:09 +0100
From: Steve Capper <steve.capper@linaro.org>
Subject: Re: [PATCH V3 0/6] RCU get_user_pages_fast and __get_user_pages_fast
Message-ID: <20140919182808.GA22622@linaro.org>
References: <1409237107-24228-1-git-send-email-steve.capper@linaro.org>
 <20140828152320.GN22580@arm.com>
 <CAPvkgC0YVhPEBqbWSDnGyZBUn3+8Kv7-yx1-_n0Jx+giKzOqmw@mail.gmail.com>
 <20140908090626.GA14634@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140908090626.GA14634@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, Will Deacon <will.deacon@arm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "gary.robertson@linaro.org" <gary.robertson@linaro.org>, "christoffer.dall@linaro.org" <christoffer.dall@linaro.org>, "peterz@infradead.org" <peterz@infradead.org>, "anders.roxell@linaro.org" <anders.roxell@linaro.org>, "dann.frazier@canonical.com" <dann.frazier@canonical.com>, Mark Rutland <Mark.Rutland@arm.com>, "mgorman@suse.de" <mgorman@suse.de>, hughd@google.com

On Mon, Sep 08, 2014 at 10:06:27AM +0100, Steve Capper wrote:
> On Mon, Sep 01, 2014 at 12:43:06PM +0100, Steve Capper wrote:
> > On 28 August 2014 16:23, Will Deacon <will.deacon@arm.com> wrote:
> > > On Thu, Aug 28, 2014 at 03:45:01PM +0100, Steve Capper wrote:
> > >> I would like to get this series into 3.18 as it fixes quite a big problem
> > >> with THP on arm and arm64. This series is split into a core mm part, an
> > >> arm part and an arm64 part.
> > >>
> > >> Could somebody please take patch #1 (if it looks okay)?
> > >> Russell, would you be happy with patches #2, #3, #4? (if we get #1 merged)
> > >> Catalin, would you be happy taking patches #5, #6? (if we get #1 merged)
> > >
> > > Pretty sure we're happy to take the arm64 bits once you've got the core
> > > changes sorted out. Failing that, Catalin's acked them so they could go via
> > > an mm tree if it's easier.
> > >
> > 
> > Hello,
> > 
> > Are any mm maintainers willing to take the first patch from this
> > series into their tree for merging into 3.18?
> >   mm: Introduce a general RCU get_user_pages_fast.
> > 
> > (or please let me know if there are any issues with the patch that
> > need addressing).
> > 
> > As Will has stated, Catalin's already acked the arm64 patches, and
> > these can also go in via an mm tree if that makes things easier:
> >   arm64: mm: Enable HAVE_RCU_TABLE_FREE logic
> >   arm64: mm: Enable RCU fast_gup
> > 
> > Thanks,
> > --
> > Steve
> 
> Hi,
> Just a ping on this.
> 
> I was wondering if the first patch in this series:
> 
> [PATCH V3 1/6] mm: Introduce a general RCU get_user_pages_fast.
> http://marc.info/?l=linux-mm&m=140923713202355&w=2
> 
> could be merged into 3.18 via an mm tree, or if there are any issues
> with the patch that I should fix?
> 
> Acks or flames from the mm maintainers would be greatly appreciated!
> 
> Cheers,
> -- 
> Steve


Hello,
Apologies for being a pest, but we're really keen to get this into 3.18,
as it fixes a THP problem with arm/arm64.

I need mm folk to either ack or flame the first patch in the series in
order to proceed. (All the patches in the series have been
acked/reviewed, but not by any mm folk.):
 [PATCH V3 1/6] mm: Introduce a general RCU get_user_pages_fast.

If it puts people's minds at rest regarding the testing...
On top of the ltp tests, and futex tests, we also ran these patches on
the arm64 Debian buildd's. With THP set to always, just under 8000
Debian packages have been built (and unit tested) without any kernel
issues for arm64.

Cheers,
-- 
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
