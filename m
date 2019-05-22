Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35D21C282DD
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 11:57:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 012C820815
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 11:57:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 012C820815
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F21C6B0003; Wed, 22 May 2019 07:57:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A2106B0006; Wed, 22 May 2019 07:57:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 76B7F6B0007; Wed, 22 May 2019 07:57:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 28DDE6B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 07:57:04 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id g36so3330980edg.8
        for <linux-mm@kvack.org>; Wed, 22 May 2019 04:57:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Vcya+6juhxLdATs7lbUaLQFaVG1S6va9Uq15u2l/dBc=;
        b=I7dcJ9DUM6qTuHwmEQKhDNAmWDwJTj8G88UKTlZZQtQzW0Bkn5lRgO1esAjkkQ8sgt
         V2T0YBqFMSxlMk6ynNaNzOLCYFB0v43ao3iLSB4sgyzQGntXursSIbgtR9te56wECxFv
         GqpGx0crE/oExIhZ26306UQCZEiq5Et0qbWxURVJbasLmsZ/yYkt/j3+UiKbNXPGCh62
         gz6G2QXuDY0zNHf8aTixQf0Wuv7xcJuH8ngQ/4pY+aN7WClZ7zLHOlHwQfBTDVdRc564
         E0IELbM4Ya0UC2bZJ8JqOYw5BKneeAcyzP9hJSfWwwp2LHy+srGQvN7u7rmJf3wlGVhC
         8+QQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAVSJT9AYNMbEMTp8oz6dJifcHcpLKpj7E/bXUs99gkxodArMHXV
	a9ekZ3LXi7tYAAkkZ8HYRvMsG9iub5DBSpCv+Jbyah9vCe8sLC/4SB3rfM8t8HC9DtiG4kUbnwt
	+4IU72vzRogzbQIaMtKQ4221EifDylVWWfEX4eNNucm+M7Wke+LgDfuwcq+fgcDtYCw==
X-Received: by 2002:a17:906:4581:: with SMTP id t1mr51100505ejq.187.1558526223678;
        Wed, 22 May 2019 04:57:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwKA1//dVBQDk0sDr0wPW1NQl/R6SyC0tu56XowuAdP7//VclUtc2txkYCQEIXNQ3waEdS
X-Received: by 2002:a17:906:4581:: with SMTP id t1mr51100465ejq.187.1558526222952;
        Wed, 22 May 2019 04:57:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558526222; cv=none;
        d=google.com; s=arc-20160816;
        b=WOvP5eVG8WYOY83R0USHUKBcMTM6JwyD5iMdGhZ5npsMMt7P7Uvge4nP6LFzT/5XIB
         z3zUhMm1B7KC9j2ZfOe1sZFXgS22lyfcCOsBf+FmhIPwnzG1mjuCJo0buDnVYtTbJGN8
         p/MBaZKbQ1ZBZ22QfOMpWT61I/58YuPH+b1bLXC/7dR8F3+v2Y+gY7dqIyU0CCreBjM1
         J+fVZpMzTiJPU5ASRtBT370vLi54BsKo4HqcI+2R2WCJDg8IN+MU0OziAY9V+D8WGOVT
         kGNY0sU63W3eGE4+NTWdKa7K0JRkSZ9R3U6vSDaQ70ReqGGCJ7xZuRKWs6ajvjRpTSC2
         2sWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Vcya+6juhxLdATs7lbUaLQFaVG1S6va9Uq15u2l/dBc=;
        b=wQahJTnpEcLhgxhlrUXhj4xkjepn7SnGqlIgwK+NdVv8A8X1rnChje4q9pXkJqN1vm
         jyzqWg3mHGOvAAX/04PJRDiHO1CnJQHLYbEs1JrURGaxjWSRgeSr/7nzF9lKQO13ARVN
         ktnYrunECsavQA9BIhiF78wGbfxGGXRmCXm6g8qZgT9eAijH5mnLssFXbQukLBPwTexc
         ihnsBYfEwFc3izfUTkYkBf8pzOxRevbny8wuT/wbYHnphjNN+d9X8ugitPksxJpJB9ov
         k9wcUzZiz/NVW8CRLT8tAa++Rgq6llezNXx34rqQ5bWwVUMeWCynkpI6yZK9xJMHs61w
         1o6w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q5si711628edd.0.2019.05.22.04.57.02
        for <linux-mm@kvack.org>;
        Wed, 22 May 2019 04:57:02 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D9F0680D;
	Wed, 22 May 2019 04:57:01 -0700 (PDT)
Received: from mbp (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D80033F575;
	Wed, 22 May 2019 04:56:55 -0700 (PDT)
Date: Wed, 22 May 2019 12:56:53 +0100
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
Subject: Re: [PATCH v15 07/17] mm, arm64: untag user pointers in mm/gup.c
Message-ID: <20190522115652.nf2r5j6xydywmccw@mbp>
References: <cover.1557160186.git.andreyknvl@google.com>
 <d234cd71774f35229bdfc0a793c34d6712b73093.1557160186.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d234cd71774f35229bdfc0a793c34d6712b73093.1557160186.git.andreyknvl@google.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 06, 2019 at 06:30:53PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> mm/gup.c provides a kernel interface that accepts user addresses and
> manipulates user pages directly (for example get_user_pages, that is used
> by the futex syscall). Since a user can provided tagged addresses, we need
> to handle this case.
> 
> Add untagging to gup.c functions that use user addresses for vma lookups.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

