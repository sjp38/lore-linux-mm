Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 828DBC43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 17:38:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3554820665
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 17:38:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3554820665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 809886B0005; Mon, 24 Jun 2019 13:38:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B9FA8E0003; Mon, 24 Jun 2019 13:38:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A9008E0002; Mon, 24 Jun 2019 13:38:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1C1FA6B0005
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 13:38:15 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d13so21502826edo.5
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 10:38:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=GBa8C8CyICVasMDk/uOPf5eHKk/d6IvucdFjk8DX5Oc=;
        b=BB6i4YZyBzBC6FEDCiBuPGq5mv9YXjP1iKLksfLaLB3TG+esWLRzaXK2DYnpxklSOM
         y0pDa2DLcHwiIk4XCScVr5Ja2Yyu2Fpyf5qnpBP3BAIbQwQvHSJPyoTrRGF7Fmk8YWGQ
         dvS6HkoYWIcBPxCqEICqRx59S05dtY3bW06X7cnprU6nuic1r6ahzSrirTpxByrxMbuP
         0yP6FG1KmHewyyHS9u66BpWVYYIcrMMmu956Rn6dqKq5p8dNtY862jlvYOO2xj9HkdH2
         +lkAIni/THWoOH2Jj4ZgZs0gBF1UVQT6uAhZtix92F2ahlBB7H6DspnNTkDEnwa+sgkf
         HyHA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAX03wjzs6syJW2IL2Xo9K3Jw1Ham8XzIhHMogrCCbnh7AsEeos3
	1ZM3untOhNdFW2PeTZL+TAhWrziaeuxnKOPJK7xkbvJ/OvRR9CkN/XBiY/jVO5vCNdqImfSl9xX
	VAba5s1hZCM9+pDSx2mTu6IlOFFK06Idc4hZw3/022lrVBTdhvHqKZmeKUVLmRilsJA==
X-Received: by 2002:a50:878c:: with SMTP id a12mr45849735eda.142.1561397894713;
        Mon, 24 Jun 2019 10:38:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyunMGxykEYMHWJRJnjoOcCpaRxD3gdC6B+AcCyPIBsUd6lu93DiYa7NTqmXMJtN2Xkr9F0
X-Received: by 2002:a50:878c:: with SMTP id a12mr45849675eda.142.1561397893986;
        Mon, 24 Jun 2019 10:38:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561397893; cv=none;
        d=google.com; s=arc-20160816;
        b=Iw0HF485w3LL4dXd6uOq5Ncf41AOb56jVyXvYNPijMNJfw6yy+ktwv7WaVoYSxbdch
         gI/CAbAC9QZ62R8E8gESD8gqi9CQm5AcucHXJ0qVjmtaddDZkU+DYdk7NXy4n/r00pFG
         DEG2JPOV+KJPHQbHbFxTDMzJamX5gHYJwmxaBYTjKb66wNBvP1Qu5YoQfl7nDwx373fn
         a5iPdg1bSYM18+JAo6RprJ9JJaJJcpKG/M83h6NWJ8ohzy7L4dG91INre5ykhgg812P9
         LgxZOjZ4MqpLnSvApoIVt3yfYv0kd3RmghErRlxZoIW28D03Sw2mckXJDhU2lCa0KLfc
         eA4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=GBa8C8CyICVasMDk/uOPf5eHKk/d6IvucdFjk8DX5Oc=;
        b=kqDEvW0Hk9nadmkix+h7l6RUTGo79CSa9EeURPn6Lhba+aQpDlwDc91fwkqxNVJi3y
         uaNpAyqxI2J4hg6OaGjcfBnBb/RvfSnOrqcIBgtQSR3DJCxi64gqA/639VbOvxVFAgTF
         59qbskSo5UUHpWc/DvHTCxJ1DbQSrQwm23xrgydfPXWJEiEIxA4XVkYdIz7RIvxfyLE/
         tfxZKHqriHeRVwhwNke3bBE9QMnUClkq6O1sRN9Hzo31e1d432l2u919ZHrXBli9DZjk
         2epFYHvsBSkqjWqCRuooGIy96k5ZTdrmOZrT/CDpsnAxCclGGA2w2oG7acFoB4gUqAh+
         IqTw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id w5si10500883edb.196.2019.06.24.10.38.13
        for <linux-mm@kvack.org>;
        Mon, 24 Jun 2019 10:38:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 25282C0A;
	Mon, 24 Jun 2019 10:38:13 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 7895D3F718;
	Mon, 24 Jun 2019 10:38:08 -0700 (PDT)
Date: Mon, 24 Jun 2019 18:38:06 +0100
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
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Christoph Hellwig <hch@infradead.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v18 15/15] selftests, arm64: add a selftest for passing
 tagged pointers to kernel
Message-ID: <20190624173805.GK29120@arrakis.emea.arm.com>
References: <cover.1561386715.git.andreyknvl@google.com>
 <0999c80cd639b78ae27c0674069d552833227564.1561386715.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0999c80cd639b78ae27c0674069d552833227564.1561386715.git.andreyknvl@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 04:33:00PM +0200, Andrey Konovalov wrote:
> --- /dev/null
> +++ b/tools/testing/selftests/arm64/tags_test.c
> @@ -0,0 +1,29 @@
> +// SPDX-License-Identifier: GPL-2.0
> +
> +#include <stdio.h>
> +#include <stdlib.h>
> +#include <unistd.h>
> +#include <stdint.h>
> +#include <sys/prctl.h>
> +#include <sys/utsname.h>
> +
> +#define SHIFT_TAG(tag)		((uint64_t)(tag) << 56)
> +#define SET_TAG(ptr, tag)	(((uint64_t)(ptr) & ~SHIFT_TAG(0xff)) | \
> +					SHIFT_TAG(tag))
> +
> +int main(void)
> +{
> +	static int tbi_enabled = 0;
> +	struct utsname *ptr, *tagged_ptr;
> +	int err;
> +
> +	if (prctl(PR_SET_TAGGED_ADDR_CTRL, PR_TAGGED_ADDR_ENABLE, 0, 0, 0) == 0)
> +		tbi_enabled = 1;

Nitpick: with the latest prctl() patch, you can skip the last three
arguments as they are ignored.

Either way:

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>

