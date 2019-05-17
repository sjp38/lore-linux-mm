Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A602C04E84
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 14:49:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51D602173C
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 14:49:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51D602173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE29E6B0006; Fri, 17 May 2019 10:49:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB9F66B0007; Fri, 17 May 2019 10:49:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D34086B0008; Fri, 17 May 2019 10:49:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 83FBC6B0006
	for <linux-mm@kvack.org>; Fri, 17 May 2019 10:49:42 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b22so11116130edw.0
        for <linux-mm@kvack.org>; Fri, 17 May 2019 07:49:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=iq/Y3CdbC+Zk6QyUzuDPQlEoa7ghGgm8rrwncwIL0Z0=;
        b=LHZdvNgERrAEePpNgF6GMMyMKzEkLp67C1lWgEFqZwwUfM6rhS7YpJbQegXdxLWqAp
         qpkvwlZO9gCDTxx4pXsJHLVt0KMwpCEF5YIVtSUqUh09AqBM4DgAPUsSurMHGgSB30Rw
         ucS8lpWz6v3y1kOd+nobWvTRnZ8lUqQyfMi9+0G8Srv22Em2918xmJ9f2djQVVGZZnbK
         bSyBY09S3zbIFayIq1fxX4s2Wjz+WGeHx3PQzQbsAQkoGldTMPnOfR8WsAvrhn+w2hYF
         /Uo/LiAQcp56W1Ko2NdJ3lf35DlI5FwzA3NKcmwX/iWzqf5fP+0l6liaVgwmCqEmkSvs
         PAzg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAVVR0A60QOoybFreii2Bu3jubVY82OLg7gGrWEhIR6MRUeQdSsY
	fRFSSRRVGiE1Gg2Rf1akDCIP0rrqbw8CXhYD/ubXmdx8PTDNFKg4zEWcaAYF7lCekLJgfYssfdk
	gjG7P8OnMkhsaoxJ5uY5GevutlZRmkS6vcADGEexSetRLlwuLKJby9gdiLD1WpeN8bw==
X-Received: by 2002:a50:947c:: with SMTP id q57mr58815461eda.81.1558104582083;
        Fri, 17 May 2019 07:49:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzT4c+Lm7IRZGQrS3lsCNkiBMU8qG5mXPR5EPW/exAYkvb+8T4yIgK7a4TUa6cn49krTLaj
X-Received: by 2002:a50:947c:: with SMTP id q57mr58815357eda.81.1558104581062;
        Fri, 17 May 2019 07:49:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558104581; cv=none;
        d=google.com; s=arc-20160816;
        b=MR+jLsvMYIVl4/QqPmVaslVA+lR+xz7AUmVsQWWjisXK/EbKOanOiGHyqH1mOUveQS
         NZPTu0w3gn3baDcaz79hdpi49u0BPa+5elWQE6pN/Kq/XHiUjM9TP8xbntpofwOecnaY
         YhAaSE8YIqrV0z4BZ4RSOBaCradNcRTVX3Xn4/VKOtN/l92hD78pyePJMDPQu6DZZXdc
         rq1gaj4yP1bMEbbOfpZpE4gNKmNBt18okcBnZkkPTbHvbWYhxFqD6OguPc2JOgiAyNJQ
         kv6LkSQOiieOj8VHrK5OcftFlaFegaHpVP7+voEYIyLFqaAuLjZgIl69SnT9ghTTNOJU
         c+Kg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=iq/Y3CdbC+Zk6QyUzuDPQlEoa7ghGgm8rrwncwIL0Z0=;
        b=bjSVfBALC0hvaN7h6oKvoQ3rxekFxz+Wa1/0ciDUvLpVrqpnlKxoAE03m6nmxV+5PR
         ZTMpybFpY+uurfQPBSL8FJHyMTAuYeqTBv1y5KRvPUA7YxFrd6cn1OHdWapdNrIYd45W
         SoN1QpVFkHkwZhY58WBMg4Denuy0dr8jf3SdMYZ78QhGv4ixrPxFLRgs6HN14tETdMzr
         LfcE83oAkTs/hcI5DlnjM6kMlnPaz0yzVrj2tLnl3C2y3eVB+bAZXYWin2EBzYJ1xAxl
         0cFOWzwMZlsWbHQGMHMSmXw0bRkgx8K9g2IYKHhvN1Xw5zpe3A/DzXroswVWwWcygGNs
         xsSA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x8si5111798edb.237.2019.05.17.07.49.40
        for <linux-mm@kvack.org>;
        Fri, 17 May 2019 07:49:41 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C624E1715;
	Fri, 17 May 2019 07:49:39 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 3BA583F71E;
	Fri, 17 May 2019 07:49:34 -0700 (PDT)
Date: Fri, 17 May 2019 15:49:31 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v15 00/17] arm64: untag user pointers passed to the kernel
Message-ID: <20190517144931.GA56186@arrakis.emea.arm.com>
References: <cover.1557160186.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1557160186.git.andreyknvl@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrey,

On Mon, May 06, 2019 at 06:30:46PM +0200, Andrey Konovalov wrote:
> One of the alternative approaches to untagging that was considered is to
> completely strip the pointer tag as the pointer enters the kernel with
> some kind of a syscall wrapper, but that won't work with the countless
> number of different ioctl calls. With this approach we would need a custom
> wrapper for each ioctl variation, which doesn't seem practical.

The more I look at this problem, the less convinced I am that we can
solve it in a way that results in a stable ABI covering ioctls(). While
for the Android kernel codebase it could be simpler as you don't upgrade
the kernel version every 2.5 months, for the mainline kernel this
doesn't scale. Any run-time checks are relatively limited in terms of
drivers covered. Better static checking would be nice as a long term
solution but we didn't get anywhere with the discussion last year.

IMO (RFC for now), I see two ways forward:

1. Make this a user space problem and do not allow tagged pointers into
   the syscall ABI. A libc wrapper would have to convert structures,
   parameters before passing them into the kernel. Note that we can
   still support the hardware MTE in the kernel by enabling tagged
   memory ranges, saving/restoring tags etc. but not allowing tagged
   addresses at the syscall boundary.

2. Similar shim to the above libc wrapper but inside the kernel
   (arch/arm64 only; most pointer arguments could be covered with an
   __SC_CAST similar to the s390 one). There are two differences from
   what we've discussed in the past:

   a) this is an opt-in by the user which would have to explicitly call
      prctl(). If it returns -ENOTSUPP etc., the user won't be allowed
      to pass tagged pointers to the kernel. This would probably be the
      responsibility of the C lib to make sure it doesn't tag heap
      allocations. If the user did not opt-in, the syscalls are routed
      through the normal path (no untagging address shim).

   b) ioctl() and other blacklisted syscalls (prctl) will not accept
      tagged pointers (to be documented in Vicenzo's ABI patches).

It doesn't solve the problems we are trying to address but 2.a saves us
from blindly relaxing the ABI without knowing how to easily assess new
code being merged (over 500K lines between kernel versions). Existing
applications (who don't opt-in) won't inadvertently start using the new
ABI which could risk becoming de-facto ABI that we need to support on
the long run.

Option 1 wouldn't solve the ioctl() problem either and while it makes
things simpler for the kernel, I am aware that it's slightly more
complicated in user space (but I really don't mind if you prefer option
1 ;)).

The tagged pointers (whether hwasan or MTE) should ideally be a
transparent feature for the application writer but I don't think we can
solve it entirely and make it seamless for the multitude of ioctls().
I'd say you only opt in to such feature if you know what you are doing
and the user code takes care of specific cases like ioctl(), hence the
prctl() proposal even for the hwasan.

Comments welcomed.

-- 
Catalin

