Return-Path: <SRS0=ZelW=WN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4E8FC3A59E
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 03:57:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A9ED32173B
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 03:57:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="PLgTwvnO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9ED32173B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 456126B0007; Fri, 16 Aug 2019 23:57:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 405E56B000A; Fri, 16 Aug 2019 23:57:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 31C276B000C; Fri, 16 Aug 2019 23:57:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0097.hostedemail.com [216.40.44.97])
	by kanga.kvack.org (Postfix) with ESMTP id 113306B0007
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 23:57:58 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 9AF511E06F
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 03:57:57 +0000 (UTC)
X-FDA: 75830561394.19.tramp25_2832c76ddb72d
X-HE-Tag: tramp25_2832c76ddb72d
X-Filterd-Recvd-Size: 4605
Received: from mail-ot1-f66.google.com (mail-ot1-f66.google.com [209.85.210.66])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 03:57:56 +0000 (UTC)
Received: by mail-ot1-f66.google.com with SMTP id c34so11436349otb.7
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 20:57:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=5JkAhLV4VoRnu2crZGL/J2yHThD4/hsSp7D/mpQ+b1s=;
        b=PLgTwvnO1F/glwSZqKSngpyzUq0vFd7nv9qzk0tkt39wZ4ihb11tnzHU/LqfTd0yVJ
         axw13Ep9GpgY89HHCRMt5qUEKZjV9fpXHekdl9moJRSsSmy+onoBfwnsmjsxfxgdFpuF
         UY5cJrgDOiWiNiT1c8BfhSIr6K4z3xB0kAEVeYHl0c6rrXqpT4vxHNa+wRXkaONde3aK
         cq2b6g1enF0XB8LwfJxyibCWbp16a+UJXk+Gury67BoYPTB3sy04w+RGXID/OjvfkmYd
         JEcGSzTjVP1+Q5GvY+6ZYPwGiUpU8/wluREQDwHDBdiY/jgkdG85+6s3b2IvImiQK0uj
         u4Uw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=5JkAhLV4VoRnu2crZGL/J2yHThD4/hsSp7D/mpQ+b1s=;
        b=rdODLwj11+OFIQb8k/tgOHDQr6jKamnMBXaSfaDpHyT0ravSxE3me4eOcm8yJ1BW89
         Y8ie8vDW/Mf9f8scqrpRvM6sjRXLvRqZzq9giN9cJpVxbkje4cqTGrd6W4eWfaIlN2Iw
         n4ECv9ckqDG1jnJH09fJbrWpGSWZEUtgXEdVS9uqvEmRgodkxtZXOsLQkB4XpUqrISzH
         lvjpqDiop7p0J3EjzoegNkSSWwg6UxbrVO2BAIuoRakHOIB3bgiW9CQNucf//0IM9Ss3
         EFBFh7FYaG6fxUw7sXdD1hu+xCnqdhW9hKcJ7yIgxLLuhwrDooaDXP8wnNYlcVxDh8/5
         +6Ng==
X-Gm-Message-State: APjAAAUOavD7vMUZQpDdjOVgPwjHEd9/q8Fg5RUDH14yjg+zHqGzHdmw
	+aRCU5VanIcyRSp7V4DnYyTMtEl7vejQhzRj+h2dBw==
X-Google-Smtp-Source: APXvYqz/7KefU1PepmrlXbJuNHdv1LcskjRo2dk3pgYqgdNtUmZnRstkYW16mDX9ocpLJMiCLBg7bb1GGPv5FPxEOVQ=
X-Received: by 2002:a05:6830:1e05:: with SMTP id s5mr9263489otr.247.1566014275232;
 Fri, 16 Aug 2019 20:57:55 -0700 (PDT)
MIME-Version: 1.0
References: <1565991345.8572.28.camel@lca.pw> <CAPcyv4i9VFLSrU75U0gQH6K2sz8AZttqvYidPdDcS7sU2SFaCA@mail.gmail.com>
 <0FB85A78-C2EE-4135-9E0F-D5623CE6EA47@lca.pw>
In-Reply-To: <0FB85A78-C2EE-4135-9E0F-D5623CE6EA47@lca.pw>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 16 Aug 2019 20:57:40 -0700
Message-ID: <CAPcyv4h9Y7wSdF+jnNzLDRobnjzLfkGLpJsML2XYLUZZZUPsQA@mail.gmail.com>
Subject: Re: devm_memremap_pages() triggers a kasan_add_zero_shadow() warning
To: Qian Cai <cai@lca.pw>
Cc: Linux MM <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	kasan-dev@googlegroups.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 8:34 PM Qian Cai <cai@lca.pw> wrote:
>
>
>
> > On Aug 16, 2019, at 5:48 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> >
> > On Fri, Aug 16, 2019 at 2:36 PM Qian Cai <cai@lca.pw> wrote:
> >>
> >> Every so often recently, booting Intel CPU server on linux-next triggers this
> >> warning. Trying to figure out if  the commit 7cc7867fb061
> >> ("mm/devm_memremap_pages: enable sub-section remap") is the culprit here.
> >>
> >> # ./scripts/faddr2line vmlinux devm_memremap_pages+0x894/0xc70
> >> devm_memremap_pages+0x894/0xc70:
> >> devm_memremap_pages at mm/memremap.c:307
> >
> > Previously the forced section alignment in devm_memremap_pages() would
> > cause the implementation to never violate the KASAN_SHADOW_SCALE_SIZE
> > (12K on x86) constraint.
> >
> > Can you provide a dump of /proc/iomem? I'm curious what resource is
> > triggering such a small alignment granularity.
>
> This is with memmap=4G!4G ,
>
> # cat /proc/iomem
[..]
> 100000000-155dfffff : Persistent Memory (legacy)
>   100000000-155dfffff : namespace0.0
> 155e00000-15982bfff : System RAM
>   155e00000-156a00fa0 : Kernel code
>   156a00fa1-15765d67f : Kernel data
>   157837000-1597fffff : Kernel bss
> 15982c000-1ffffffff : Persistent Memory (legacy)
> 200000000-87fffffff : System RAM

Ok, looks like 4G is bad choice to land the pmem emulation on this
system because it collides with where the kernel is deployed and gets
broken into tiny pieces that violate kasan's. This is a known problem
with memmap=. You need to pick an memory range that does not collide
with anything else. See:

    https://nvdimm.wiki.kernel.org/how_to_choose_the_correct_memmap_kernel_parameter_for_pmem_on_your_system

...for more info.

