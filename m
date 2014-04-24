Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 15AFE6B0037
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 06:43:25 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id l18so2095850wgh.16
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 03:43:25 -0700 (PDT)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id yr10si1914933wjc.60.2014.04.24.03.43.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 24 Apr 2014 03:43:24 -0700 (PDT)
Date: Thu, 24 Apr 2014 11:42:32 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH V2 0/5] Huge pages for short descriptors on ARM
Message-ID: <20140424104232.GK26756@n2100.arm.linux.org.uk>
References: <1397648803-15961-1-git-send-email-steve.capper@linaro.org> <20140424102229.GA28014@linaro.org> <20140424103639.GC19564@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140424103639.GC19564@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Steve Capper <steve.capper@linaro.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "robherring2@gmail.com" <robherring2@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "gerald.schaefer@de.ibm.com" <gerald.schaefer@de.ibm.com>

On Thu, Apr 24, 2014 at 11:36:39AM +0100, Will Deacon wrote:
> I guess I'm after some commitment that this is (a) useful to somebody and
> (b) going to be tested regularly, otherwise it will go the way of things
> like big-endian, where we end up carrying around code which is broken more
> often than not (although big-endian is more self-contained).

It may be something worth considering adding to my nightly builder/boot
testing, but I suspect that's impractical as it probably requires a BE
userspace, which would then mean that the platform can't boot LE.

I suspect that we will just have to rely on BE users staying around and
reporting problems when they occur.

-- 
FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
improving, and getting towards what was expected from it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
