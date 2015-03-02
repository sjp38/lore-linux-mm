Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id D1DA36B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 09:16:35 -0500 (EST)
Received: by padfa1 with SMTP id fa1so14519216pad.9
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 06:16:35 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id di4si5850352pad.57.2015.03.02.06.16.34
        for <linux-mm@kvack.org>;
        Mon, 02 Mar 2015 06:16:34 -0800 (PST)
Date: Mon, 2 Mar 2015 14:16:04 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH V4 0/6] RCU get_user_pages_fast and __get_user_pages_fast
Message-ID: <20150302141604.GB16779@leverpostej>
References: <1411740233-28038-1-git-send-email-steve.capper@linaro.org>
 <54F06636.6080905@redhat.com>
 <20150227132000.GD9011@leverpostej>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150227132000.GD9011@leverpostej>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "jcm@redhat.com" <jcm@redhat.com>
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "dann.frazier@canonical.com" <dann.frazier@canonical.com>, Steve Capper <steve.capper@linaro.org>, "peterz@infradead.org" <peterz@infradead.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "anders.roxell@linaro.org" <anders.roxell@linaro.org>, Will Deacon <Will.Deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hughd@google.com" <hughd@google.com>, "christoffer.dall@linaro.org" <christoffer.dall@linaro.org>, "gary.robertson@linaro.org" <gary.robertson@linaro.org>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "mgorman@suse.de" <mgorman@suse.de>

> > Head's up: these patches are currently implicated in a rare-to-trigger
> > hang that we are seeing on an internal kernel. An extensive effort is
> > underway to confirm whether these are the cause. Will followup.
> 
> I'm currently investigating an intermittent memory corruption issue in
> v4.0-rc1 I'm able to trigger on Seattle with 4K pages and 48-bit VA,
> which may or may not be related. Sometimes it results in a hang (when
> the vectors get corrupted and the CPUs get caught in a recursive
> exception loop).

FWIW my issue appears to be a bug in the old firmware I'm running.
Sorry for the noise!

Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
