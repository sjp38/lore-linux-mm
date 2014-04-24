Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8379D6B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 07:04:15 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id d1so848783wiv.3
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 04:04:15 -0700 (PDT)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id ek7si9086574wib.117.2014.04.24.04.04.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 24 Apr 2014 04:04:14 -0700 (PDT)
Date: Thu, 24 Apr 2014 12:03:21 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH V2 0/5] Huge pages for short descriptors on ARM
Message-ID: <20140424110321.GN26756@n2100.arm.linux.org.uk>
References: <1397648803-15961-1-git-send-email-steve.capper@linaro.org> <20140424102229.GA28014@linaro.org> <20140424103639.GC19564@arm.com> <20140424104232.GK26756@n2100.arm.linux.org.uk> <CAPvkgC3P8iZp5nECiGHdeGzRwmdh=ouiAREqKwk1tYzZxHTWvg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPvkgC3P8iZp5nECiGHdeGzRwmdh=ouiAREqKwk1tYzZxHTWvg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: Will Deacon <will.deacon@arm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "robherring2@gmail.com" <robherring2@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "gerald.schaefer@de.ibm.com" <gerald.schaefer@de.ibm.com>

On Thu, Apr 24, 2014 at 11:55:56AM +0100, Steve Capper wrote:
> On 24 April 2014 11:42, Russell King - ARM Linux <linux@arm.linux.org.uk> wrote:
> > On Thu, Apr 24, 2014 at 11:36:39AM +0100, Will Deacon wrote:
> >> I guess I'm after some commitment that this is (a) useful to somebody and
> >> (b) going to be tested regularly, otherwise it will go the way of things
> >> like big-endian, where we end up carrying around code which is broken more
> >> often than not (although big-endian is more self-contained).
> >
> > It may be something worth considering adding to my nightly builder/boot
> > testing, but I suspect that's impractical as it probably requires a BE
> > userspace, which would then mean that the platform can't boot LE.
> >
> > I suspect that we will just have to rely on BE users staying around and
> > reporting problems when they occur.
> 
> The huge page support is for standard LE, I think Will was saying that
> this will be like BE if no-one uses it.

We're not saying that.

What we're asking is this: *Who* is using hugepages today?

What we're then doing is comparing it to the situation we have today with
BE, where BE support is *always* getting broken because no one in the main
community tests it - not even a build test, nor a boot test which would
be required to find the problems that (for example) cropped up in the
last merge window.

> It's somewhat unfair to compare huge pages on short descriptors with
> BE. For a start, the userspace that works with LPAE will work on the
> short-descriptor kernel too.

That sounds good, but the question is how does this get tested by
facilities such as my build/boot system, or Olof/Kevin's system?
Without that, it will find itself in exactly the same situation that
BE is in, where problems aren't found until after updates are merged
into Linus' tree.

-- 
FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
improving, and getting towards what was expected from it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
