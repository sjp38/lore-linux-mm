Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9A02C07542
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 09:43:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A13221721
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 09:43:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A13221721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 10F2A6B0271; Mon, 27 May 2019 05:43:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E7E16B0272; Mon, 27 May 2019 05:43:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3FBA6B0273; Mon, 27 May 2019 05:43:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A8FA06B0271
	for <linux-mm@kvack.org>; Mon, 27 May 2019 05:43:07 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i3so27199935edr.12
        for <linux-mm@kvack.org>; Mon, 27 May 2019 02:43:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=TIQmgKkJ58tcbWhFiwKmHk6v9Dk08ln3ge/lw/xh/t0=;
        b=tDAy6DWlKq1IzUUZcx/fvnO56mtgmNLE/kmkh3YfiiAymlJleQxBg65b421IQCgkNd
         y7OhLDmsOLOUMKnBBVP9ePDZu8R/AiFhV8oLOuQWhSoH+dKHreV66Ivrp4FARX/kwVXt
         xktg8yUTIQ5tGfuDGnF8Q1+KieM9t8erBpjaRiLB3GP4OBMvnrlVmkZ018A87QcUqeSK
         E0XC7XQ+ANmbfkdkqXjgxkQspr4mPsktJW9lwsI5Mt0L827f0tdoz83/u5kP1NASWQX3
         pPRMIsEpUvQZCVQB4aCrjWId//1R0a2x+JedzFcdrjK0z+NnHwCn9UUsvqlK88vR7YV6
         8irw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAU2zQ4Qpwv34vP+BkTsdHNDxcGpk96IS+2FCISFvssRDH0EqW4n
	Ou0/oK+WoXGdKhEOnUDQGmsrqRYycXpCU7RzLhpi2bWGyhUzooLmFnaKo194a082N1xDOfLK7Eb
	dErjD9R9sN8EJoVv6yFl++6ePoU1lKym5WPCBzT3RG/2xtRzkcoUwgKVr9gtgor3lPg==
X-Received: by 2002:a17:906:7cb:: with SMTP id m11mr13211383ejc.311.1558950187272;
        Mon, 27 May 2019 02:43:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyJ1XRRAG2kCulZiFdfgNMMDA6jKuDa6xJI+dxnvfuy6WgllJ+lJ4PU/9t1YWRGT9HkwvT/
X-Received: by 2002:a17:906:7cb:: with SMTP id m11mr13211344ejc.311.1558950186392;
        Mon, 27 May 2019 02:43:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558950186; cv=none;
        d=google.com; s=arc-20160816;
        b=nNnGwMwdszk5czcky1qmuqQnIVBNsvSTubAbLR045abVkCFOu0f88DkCDZ8VpjSSs2
         tRkVZ8raVZX0Fl7H+aDcnPGWpQa/2eddaGXj58/OVLbUR2clAXMKBdu+jxSgH21ghyTK
         A9NjniUqsSr2TB01zrcuc/SgZ6mNa1b8hQGxWxVug8+JncrIkxxbjniR4ICvNwYtL4jF
         Sil8JNBjqj+jix6ayJgBwioasJDpYQODI67h/JeK2dWpO4yOu0DDTzpy1MVGRwunuqz4
         0LoCGN5XHWJqmlgqvNqXZcGFArovBa+kzp4tnc6Fc7UC04NzojofiAxveLfd5V0nNw/W
         +AGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=TIQmgKkJ58tcbWhFiwKmHk6v9Dk08ln3ge/lw/xh/t0=;
        b=IGG5k6kMWQPHK+hwK8iqX/yDH1eKWwzFF4LYXVo13/MfcO7F9bAAl2CQI8WW2/UHeD
         gAb3FrWI2kZW1kEfSYfiCD18KbyCt3r7ddSHkV8Bk0BHK92sgPmR8Sn4f9V4GIzKQqeu
         8FQHgVRYV527TO1wPAg4S++q+s13X5msK1Uw5rrsTisHxWipmONUe0tNvja/MRwyNZzS
         qZpkHAtup8o6EFt2fnB1Wj8gdyTyqIwc5wA0KEAiHxC+BtVO9jb4hIWl0g9WNf0xK17y
         2Fekf/w/gc3jRlWiCAuOrmDoOlrURoRX1ii5sXbT+uBpxUOg+nbLDX1hDcXKwJR7nquN
         45cQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k14si660258edb.27.2019.05.27.02.43.06
        for <linux-mm@kvack.org>;
        Mon, 27 May 2019 02:43:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 2E16CA78;
	Mon, 27 May 2019 02:43:05 -0700 (PDT)
Received: from MBP.local (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 4D0DA3F5AF;
	Mon, 27 May 2019 02:42:59 -0700 (PDT)
Date: Mon, 27 May 2019 10:42:48 +0100
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
Subject: Re: [PATCH v15 05/17] arms64: untag user pointers passed to memory
 syscalls
Message-ID: <20190527094247.GA45660@MBP.local>
References: <cover.1557160186.git.andreyknvl@google.com>
 <00eb4c63fefc054e2c8d626e8fedfca11d7c2600.1557160186.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00eb4c63fefc054e2c8d626e8fedfca11d7c2600.1557160186.git.andreyknvl@google.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 06, 2019 at 06:30:51PM +0200, Andrey Konovalov wrote:
> +SYSCALL_DEFINE2(arm64_mlock2, unsigned long, start, size_t, len)
> +{
> +	start = untagged_addr(start);
> +	return ksys_mlock(start, len, VM_LOCKED);
> +}

Copy/paste error: sys_mlock2() has 3 arguments and should call
ksys_mlock2().

Still tracking down an LTP failure on test mlock01.

-- 
Catalin

