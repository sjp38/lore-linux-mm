Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C994C4321B
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 15:01:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2766F208E3
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 15:01:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2766F208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C61A76B027F; Tue, 11 Jun 2019 11:01:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C10776B0280; Tue, 11 Jun 2019 11:01:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD8E36B0281; Tue, 11 Jun 2019 11:01:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 600926B027F
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 11:01:32 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c1so21070196edi.20
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 08:01:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Gz9OIjO178HAsb3TAEf8zvFN4iwVW+2W7AODwuqoTKc=;
        b=d+qZv49UH0B4BcY7sPYFCg29ohJaUzWH5JXIOtVzbIyw5tmhSebMHl7hXOwBquWJz/
         3FmtT0X07ncPYEDKzBepbGzMse6hYQmHhqL92CXFCv9EUkiiFKzq70E+RCpARYolfJWJ
         0grBG6gnz3NBD2GlMn1NM/4geLzFsHW18ATsDayd5DsIG2U4OYr6llYb0Jxf1hN6aPnB
         4DVY9veJ5Pi5hAA3h6jhAUIS4VGZIIQGnRWgOZNRQ+cBiapq/cyqnpuPZ6aEkCIIGm/3
         BmLLu7dDl68jX0gjk9jbWZUi7eLr6RH8DmaZNdXlnsMb17gZR36xuf8O/+P9Q/ILa/Uf
         w7Hw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAV1ckktJImvqEBbR5+0l/SGZ0JHx7VSmM+kXasrQxa2XM9iyg+F
	bxmJcjH15i9HG+rddgG1+K+Wg9q1/CI4t3rO1lLFx6nl2HRKkgyl3j9u/NXm/DGHmoaD209Cufz
	4FxXOEjdbM9P/S7IhuGd1+SisbiJbrPDvpFFyIeFirQp27ea23FWew1k0uPzd1WOmzw==
X-Received: by 2002:a50:c908:: with SMTP id o8mr51700136edh.131.1560265291838;
        Tue, 11 Jun 2019 08:01:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyXVGXJ/kllE6wAp0vsKZb+lbWLp/ZidUeIgVFHdtifc6dQj0VPCVrNyLdsgy7hscSloD9w
X-Received: by 2002:a50:c908:: with SMTP id o8mr51700010edh.131.1560265290706;
        Tue, 11 Jun 2019 08:01:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560265290; cv=none;
        d=google.com; s=arc-20160816;
        b=RNIQN6YBXlNhClSXTqUQD56eji4x+u3B3RqHcHHjl+k04seqnAfbzoc4VMQVTTqCux
         HBKsSSyQ1K55rO+sNFhr8a+bvwa/At2BaNjOBPN6Cul6GHZZr1jfj2iBMC6Vk2OSChUx
         xREQBtffAFZcWACJVv642QtooDBQd4U182wYor1RatxQ9y1FFuOfPQPbRx/pf0nrRTB8
         jFjYgLTUZmKoPpu3go5Zgl1ixSHYyqCu+BkPrRg6jLZq7NX+UY4cp3mEFZeMR9T4nqZk
         zyhpJM2iS98z6hvJ0DsWrH3c4Rq6sK4W4EK5AQ2xWOMVbBNcSMdCrRrFWprGDEXAxzbC
         IQpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Gz9OIjO178HAsb3TAEf8zvFN4iwVW+2W7AODwuqoTKc=;
        b=jDMfhXLTE1gCSjqU4PxAx3VUeMNoMp4DyMsg0UVzz/AyDfHQIak+0+lFEJptrcbKgd
         re/XxIauC1QMfnC9wrVNy5k8OCWEZk5gWRoPHuE/0uHwKuBPY1W8c4UiBsTKRvYl6mbf
         SdjpyWLB6k26M0abQUc41S4xGbRWcyJTc5WepdB8tuG9mvZVpxyYrmrNN/5fhp4gBRwz
         0DOgt5PW1scqaCtXWie2AsGcrMJLm2berjbnelD0uGXttwIH4DC+kDk5OVyzIw1uxOUp
         M0Zpe4g9v3Q6Oxz9FGEkGdULPUTyjXXvy+gredsHi4vTxs4Y0iiy0N7cy2bFpLdBTZhb
         CG5w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id g24si1150134eda.131.2019.06.11.08.01.30
        for <linux-mm@kvack.org>;
        Tue, 11 Jun 2019 08:01:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id AFDBE346;
	Tue, 11 Jun 2019 08:01:29 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 103473F246;
	Tue, 11 Jun 2019 08:01:24 -0700 (PDT)
Date: Tue, 11 Jun 2019 16:01:22 +0100
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
Subject: Re: [PATCH v16 16/16] selftests, arm64: add a selftest for passing
 tagged pointers to kernel
Message-ID: <20190611150122.GB63588@arrakis.emea.arm.com>
References: <cover.1559580831.git.andreyknvl@google.com>
 <9e1b5998a28f82b16076fc85ab4f88af5381cf74.1559580831.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9e1b5998a28f82b16076fc85ab4f88af5381cf74.1559580831.git.andreyknvl@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 06:55:18PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> This patch adds a simple test, that calls the uname syscall with a
> tagged user pointer as an argument. Without the kernel accepting tagged
> user pointers the test fails with EFAULT.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

BTW, you could add

Co-developed-by: Catalin Marinas <catalin.marinas@arm.com>

since I wrote the malloc() etc. hooks.


> +static void *tag_ptr(void *ptr)
> +{
> +	unsigned long tag = rand() & 0xff;
> +	if (!ptr)
> +		return ptr;
> +	return (void *)((unsigned long)ptr | (tag << TAG_SHIFT));
> +}

With the prctl() option, this function becomes (if you have a better
idea, fine by me):

----------8<---------------
#include <stdlib.h>
#include <sys/prctl.h>

#define TAG_SHIFT	(56)
#define TAG_MASK	(0xffUL << TAG_SHIFT)

#define PR_SET_TAGGED_ADDR_CTRL		55
#define PR_GET_TAGGED_ADDR_CTRL		56
# define PR_TAGGED_ADDR_ENABLE		(1UL << 0)

void *__libc_malloc(size_t size);
void __libc_free(void *ptr);
void *__libc_realloc(void *ptr, size_t size);
void *__libc_calloc(size_t nmemb, size_t size);

static void *tag_ptr(void *ptr)
{
	static int tagged_addr_err = 1;
	unsigned long tag = 0;

	if (tagged_addr_err == 1)
		tagged_addr_err = prctl(PR_SET_TAGGED_ADDR_CTRL,
					PR_TAGGED_ADDR_ENABLE, 0, 0, 0);

	if (!ptr)
		return ptr;
	if (!tagged_addr_err)
		tag = rand() & 0xff;

	return (void *)((unsigned long)ptr | (tag << TAG_SHIFT));
}

-- 
Catalin

