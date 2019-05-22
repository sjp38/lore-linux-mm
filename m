Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20E12C18E7D
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 10:41:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA425217D4
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 10:41:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA425217D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 078676B0003; Wed, 22 May 2019 06:41:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 001A16B0006; Wed, 22 May 2019 06:41:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE6656B0007; Wed, 22 May 2019 06:41:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8E2DE6B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 06:41:14 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id t58so3004833edb.22
        for <linux-mm@kvack.org>; Wed, 22 May 2019 03:41:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=1w87fvDo8kp6TN662/kTbsxcfV62a0LO0IH1hNiu5Mk=;
        b=XQarTV9awFU1ooLt8kQgUiNvuAl66lJ074Ya+m/i+BJhNbRM5EvWz2rI78Id5sJcPe
         cY9Fy3hueLcZhXofK7D5G87A3ZQlgKD7IhJYdwd4nsqKBPFn2ij7CvZqWkZjxFkaDIni
         uNhQpcM23LD7CzJm+3howrcuh7crkcJTGx4vt79ksLqQTo4/BlRoeqwkZP5g5kRbMjTN
         TaLMrK2ZSh6Su0+aG1zZ657t2JkLmCOrFL1o3ODy8K+Lqo6+OyAc4WYn10u1aMSKJJ7S
         X8w2dEy6M8oJILNbJC0zyEePsQDaItMejgQiPbvgjD9DH6enu54AzFUoZEoMjwN2e9pN
         n2FQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAXwAI+P2sSXYAaK3JqsFSHN6OS27VEPka2QtbToKgLEM+2nd37J
	yWg4Wfon3f7Qhd6sjPQIBH524BjbfNLQi9AaNTiaLymgM7qdZptn8FjwAKuN/2uOMnUbLLCmIm2
	vCk7XEb0ykzX4GDnAFxidpb2OE2VxzqOe6zoW/1v7rfw6qEYmd+VrTEktahV6eJn1Kw==
X-Received: by 2002:a17:906:7206:: with SMTP id m6mr70550821ejk.39.1558521674147;
        Wed, 22 May 2019 03:41:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxEQL4y4+KEIYkIemH7/I+e2o4lQX+8VM8buWAyc7dQv0FxpiU0TUTuk5hByDqoDA/6zJTN
X-Received: by 2002:a17:906:7206:: with SMTP id m6mr70550764ejk.39.1558521673261;
        Wed, 22 May 2019 03:41:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558521673; cv=none;
        d=google.com; s=arc-20160816;
        b=Auk18UUm8pOzG7P96GeYg690u3kOxF9ak1tH4uj24VX218As4Ot9G3no7lDjafQrWd
         Vn0wHIvjRVGxrx6XsR4FoZ28jLk1/UvJ4EVl9LvhyIkPLTeJn4w2yJzyHDL20lfqNPNp
         2426kLoUENs9lOJQ0mApzrZesLjMfrKW3g61Oa6xZJeMM1usylEMQ/CtTUkttlILYnnJ
         WsjtRzMjmM+hPBMemUFcFs0hI+5hon020LyWEQRJoxARnCbBzaF2BUbHlZw+zD+/vmUe
         pjKENXL96+TGZeahXhA/Bg3S01YBgYBJDGFbk3+tPfdhWlpL6+FavWxtyHikIyIh63yp
         kQfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=1w87fvDo8kp6TN662/kTbsxcfV62a0LO0IH1hNiu5Mk=;
        b=IV6ioNo3UdwrrPEcidTaXZWJabadI1zd/iRKxe6C97zFawq+vSgqitA/dwTfcsrNoD
         /oG2mvRBUjeCyfZsFvz8y0bLNzibVFpFtVu94eWIdlxn+6h3KVfNSkBP2UWo9yWG6ktg
         dYHeHihgbJfcBOWlaDMuESdJ8wCcBbatZIqdae799CElaU3refV5Kb8juigtH1hvaMLD
         jIPXxYgdkeuYpl8jYpdhaWWRd47L/2XkeZO4ZuKkQzZtmzuAetvk+1EHW+cgor24OYq3
         w98/SetwS8PD5pdoZIhO9WmOoQ3RXmUxrUE/Eq1aLLmv5XqNoKBdqbRRi5+LOGw/pbey
         zVTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i21si6011863edg.233.2019.05.22.03.41.12
        for <linux-mm@kvack.org>;
        Wed, 22 May 2019 03:41:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 10655341;
	Wed, 22 May 2019 03:41:12 -0700 (PDT)
Received: from mbp (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 3F3C13F575;
	Wed, 22 May 2019 03:41:06 -0700 (PDT)
Date: Wed, 22 May 2019 11:41:03 +0100
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
Subject: Re: [PATCH v15 03/17] lib, arm64: untag user pointers in strn*_user
Message-ID: <20190522104103.r5any4us4zz7gwvg@mbp>
References: <cover.1557160186.git.andreyknvl@google.com>
 <861418ff7ed7253356cb8267de5ee2d4bd84196d.1557160186.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <861418ff7ed7253356cb8267de5ee2d4bd84196d.1557160186.git.andreyknvl@google.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 06, 2019 at 06:30:49PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> strncpy_from_user and strnlen_user accept user addresses as arguments, and
> do not go through the same path as copy_from_user and others, so here we
> need to handle the case of tagged user addresses separately.
> 
> Untag user pointers passed to these functions.
> 
> Note, that this patch only temporarily untags the pointers to perform
> validity checks, but then uses them as is to perform user memory accesses.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Just to keep track of where I am with the reviews while the ABI
discussion continues:

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

