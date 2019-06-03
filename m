Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED7FBC04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 17:32:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B975227286
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 17:32:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B975227286
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B3C06B026D; Mon,  3 Jun 2019 13:32:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 564B86B026E; Mon,  3 Jun 2019 13:32:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47B066B0271; Mon,  3 Jun 2019 13:32:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 117916B026D
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 13:32:19 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r5so28366227edd.21
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 10:32:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=QuQpVmwtCzeDGjWGacwxCh79oFLM7b7NvwIkUGDPPww=;
        b=SprNkXFfUVzBzK1gcpleB1eES/aqhNUFkpdfRg8ZGu9Wp8lYmjipvVspyLnCLaBHUE
         phrofDIXFQ2vUtO52X1/UluACkgeaReh0+w+VLGw6SgbpqsCdk26iOAV8g9K+o/VEf4b
         Dbe7sli8W5RsXkUcH91f1nE7FCBLZlBOhgteoX1APIdKE7f0xjeaQerNofeZYhiXgNDG
         yruhn9D0sGDWRxPDemrLVNTlC1nb+zTjNLDcTlHfmwy8S1nCI+B6jIg1MpYTSU42R2cD
         iPOVqu3zwbj1+0u7FJGM3BYktCqeP0eXLy1n7VCQEbYHmVQOyRLUX2mQeBoWuqhZ4m+O
         oDCQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAV6+mtDRv4l0KBqhl58VI8EUZs16uudBu409SfenS7/WI3Yrdpl
	0Xj5hTOQSuRoxGVcBaJB30ygSACYm4iQSpbGEgB2ph54GSUrfSm6HEW5y7KNrscJjxOqBY4vpZY
	fc9IkasT9tVcfr+YHfvPp2LhCRt+4vOuwQCHhYAoK6R+JTNbcNHJu0geGW3GqHGuhXQ==
X-Received: by 2002:aa7:cf0f:: with SMTP id a15mr30284630edy.281.1559583138678;
        Mon, 03 Jun 2019 10:32:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwsZpWsP4kGco+g0ckwvryG5t7glNLgAzS3TeMoQPyCiV0NdFpz/MPpeKB8XVIt4OdZNViT
X-Received: by 2002:aa7:cf0f:: with SMTP id a15mr30284551edy.281.1559583137848;
        Mon, 03 Jun 2019 10:32:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559583137; cv=none;
        d=google.com; s=arc-20160816;
        b=bhRBEUn1s5DZlGiEak43iO0wEDlTYnIGxtkZQVf2+SfQCGAXZYX1MccnbsYIIGsG06
         QWeMm1yR5Tva+E4nZoqKlsA1WRqdbu1+BCyHGg8HoO24o2UjyKAx/V6XZc1uNeW4PU8v
         J/IR8/7YxMJEV6mfZ1CZ6eVJSmYPcoWhv6NEAe9wOnTLDvuGFKnXx1vbRl2MORs1qrlw
         MfiOH9AzjLh57vfa7RN68WSLLUyqN4Re/nw63INhragDVG614WhJWl56gOP9jhp0F+M/
         xC/P8nD08UyQCOPJA6thBKD/igG4gfoj8qQEuqoi8prdAjLjM/qfyY3TEvOSFGZdtUwQ
         TJsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=QuQpVmwtCzeDGjWGacwxCh79oFLM7b7NvwIkUGDPPww=;
        b=V2LXS1+In16M1L+FZ9b1Zp7etwQtDcM+XVSZnw2bysDUcZf26fOADt9TsvKPxRUcXm
         qn7Fxz5XQSNIgfTwM+5wf2ZMwOvrdGlqIWhFw+dhyvl3cju1KSsSjy1KPqlFIA4+NCll
         +5tR1xuLCQzPhgMXOni6C3L9Oc+UGhkW9g6Q8VmeJQCpJzNWjrNuuPokIWoEsn/gySoN
         U15mleLWkojYqbkWRYdQR49SzjuH0zC4kYE0VHSmtR2IrTAUBgy4xBH7/tMG31V8rFRg
         8IoKfHyKEDZlLm+aSrVpVEiA6zVYU9WCWp0V1NqYODSTUCj05Phk0U5z4VhlK8a9bcLE
         Sjqw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t51si3214470eda.310.2019.06.03.10.32.17
        for <linux-mm@kvack.org>;
        Mon, 03 Jun 2019 10:32:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id BE60980D;
	Mon,  3 Jun 2019 10:32:16 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A6BF63F5AF;
	Mon,  3 Jun 2019 10:32:13 -0700 (PDT)
Date: Mon, 3 Jun 2019 18:32:11 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Alexandre Ghiti <alex@ghiti.fr>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH v4 02/14] arm64: Make use of is_compat_task instead of
 hardcoding this test
Message-ID: <20190603173210.GI63283@arrakis.emea.arm.com>
References: <20190526134746.9315-1-alex@ghiti.fr>
 <20190526134746.9315-3-alex@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190526134746.9315-3-alex@ghiti.fr>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, May 26, 2019 at 09:47:34AM -0400, Alexandre Ghiti wrote:
> Each architecture has its own way to determine if a task is a compat task,
> by using is_compat_task in arch_mmap_rnd, it allows more genericity and
> then it prepares its moving to mm/.
> 
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> Acked-by: Kees Cook <keescook@chromium.org>
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

