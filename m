Return-Path: <SRS0=7HIe=WT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05211C3A5A4
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 15:15:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB27E206E0
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 15:15:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="CipekAbZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB27E206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BBA26B04A2; Fri, 23 Aug 2019 11:15:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36C596B04A3; Fri, 23 Aug 2019 11:15:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 234106B04A4; Fri, 23 Aug 2019 11:15:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0208.hostedemail.com [216.40.44.208])
	by kanga.kvack.org (Postfix) with ESMTP id 025006B04A2
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 11:15:50 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id C00B862C4
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 15:15:50 +0000 (UTC)
X-FDA: 75854042460.19.dirt49_32f7c4c4a4b2d
X-HE-Tag: dirt49_32f7c4c4a4b2d
X-Filterd-Recvd-Size: 4363
Received: from mail-ot1-f66.google.com (mail-ot1-f66.google.com [209.85.210.66])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 15:15:50 +0000 (UTC)
Received: by mail-ot1-f66.google.com with SMTP id k18so9094418otr.3
        for <linux-mm@kvack.org>; Fri, 23 Aug 2019 08:15:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=yF6s2o6Obyqe3Vdpv/vEsuzAp6r9764Exr+eDaZHvIs=;
        b=CipekAbZFv7AtHaeNXijgoaKhu1e4Ki+U+C5UwmSTDk1R0S6hDs4Rz2vU5i7aJx+Xm
         CNIekhclzjzyj/jl3B4i8OIxJ6LkL0vwtijn9gG6PL9FFIjKLREyHpLX0dOnwbR0Y3Yz
         IJxMIxvhHrwSWKUrN2lkWRoeMoZa+8njEAvaQ=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=yF6s2o6Obyqe3Vdpv/vEsuzAp6r9764Exr+eDaZHvIs=;
        b=bG2/LCV+A8VyLKGsYsUV8HYnZ3BswMieIystHgXFHNJxl/JBCbIbL058gFH4UDWk2O
         7S0YNljs/fzyEF1VlMr7dGyu/guTapsuVefQiV+pepMB1TIKv/5se0bLgzsj9mO78Oc/
         taVgBBENZh+EY7HjE5td9ysm8v3SRTSP1oxUa/MSZsozZ7JlBvGPo9DsH/7WyvCCpMyP
         7zd2rkOx9Dc6dqc0zNbRqwsVkgJmjeCmmfu75tYXAOV3T5bA7gNO8a/0S80CSssY5rw3
         XRO7Y7VMPTRAW8vTc5fdXbjQ4jmDCAE+ZYzTXXW7wY7pAGZzeUSzd56gvnkM5I+4X+Co
         TnGQ==
X-Gm-Message-State: APjAAAWKs7dQ1BhBXoTro8WyiI/2CmmBuQzMxaiU9uB07o8F0wz6XsFR
	Ng+dNXQAEEY36nxvsHx3j8sgk5dvvxlpYkke69Q7zw==
X-Google-Smtp-Source: APXvYqxYJ5Sv6xRYyBhZ/VIa63V8CWwoKAMb/ZibSDLDyqK3dCvDo5SGQy04IWZyYut8+xZ5L8t6GMt0vJE1pUvmUsA=
X-Received: by 2002:a9d:7087:: with SMTP id l7mr4788315otj.281.1566573349104;
 Fri, 23 Aug 2019 08:15:49 -0700 (PDT)
MIME-Version: 1.0
References: <20190820081902.24815-1-daniel.vetter@ffwll.ch>
 <20190820081902.24815-4-daniel.vetter@ffwll.ch> <20190820202440.GH11147@phenom.ffwll.local>
 <20190822161428.c9e4479207386d34745ea111@linux-foundation.org>
 <CAKMK7uGw_7uD=wH3bcR9xXSxAcAuYTLOZt3ue4TEvst1D0KzLQ@mail.gmail.com>
 <20190823121234.GB12968@ziepe.ca> <CAKMK7uHzSkd2j4MvSMoHhCaSE0BT0zMo9osF4FUBYwNZrVfYDA@mail.gmail.com>
 <20190823140615.GJ2369@hirez.programming.kicks-ass.net>
In-Reply-To: <20190823140615.GJ2369@hirez.programming.kicks-ass.net>
From: Daniel Vetter <daniel@ffwll.ch>
Date: Fri, 23 Aug 2019 17:15:37 +0200
Message-ID: <CAKMK7uFM0JLqJ7y9F8ybvYx+o4+2S+guaV-MaBQyyik3F0vNiQ@mail.gmail.com>
Subject: Re: [PATCH 3/4] kernel.h: Add non_block_start/end()
To: Peter Zijlstra <peterz@infradead.org>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Andrew Morton <akpm@linux-foundation.org>, 
	LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	DRI Development <dri-devel@lists.freedesktop.org>, 
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>, Ingo Molnar <mingo@redhat.com>, 
	Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, 
	=?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, Wei Wang <wvw@google.com>, 
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, 
	Jann Horn <jannh@google.com>, Feng Tang <feng.tang@intel.com>, 
	Kees Cook <keescook@chromium.org>, Randy Dunlap <rdunlap@infradead.org>, 
	Daniel Vetter <daniel.vetter@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 23, 2019 at 4:06 PM Peter Zijlstra <peterz@infradead.org> wrote:
> On Fri, Aug 23, 2019 at 03:42:47PM +0200, Daniel Vetter wrote:
> > I'm assuming the lockdep one will land, so not going to resend that.
>
> I was assuming you'd wake the might_lock_nested() along with the i915
> user through the i915/drm tree. If want me to take some or all of that,
> lemme know.

might_lock_nested() is a different patch series, that one will indeed
go in through the drm/i915 tree, thx for the ack there. What I meant
here is some mmu notifier lockdep map in this series that Jason said
he's going to pick up into hmm.git. I'm doing about 3 or 4 different
lockdep annotations series in parallel right now :-)
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

