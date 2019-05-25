Return-Path: <SRS0=GxOJ=TZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	T_DKIMWL_WL_HIGH autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8299C46470
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 21:51:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 42D1420862
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 21:51:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="yeCoL/9Y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42D1420862
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA34E6B0003; Sat, 25 May 2019 17:51:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B526C6B0005; Sat, 25 May 2019 17:51:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A40DA6B0007; Sat, 25 May 2019 17:51:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 722B66B0003
	for <linux-mm@kvack.org>; Sat, 25 May 2019 17:51:22 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d125so6832584pfd.3
        for <linux-mm@kvack.org>; Sat, 25 May 2019 14:51:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Ggdf+nwMYpqOtPfchVX3fGXJn/l3ESKOGJa08VuJQj8=;
        b=HfQ5e7S573KjYsp09cgkbedvMPsvu8BMKAiobmorjog0CeD9JmKW+rQMooJ8rzp7gU
         akkLaWZ0PNr6dYxy+zWE1sZIY4q7PPZ0xcftmdFYSHjO6gUUTbMqbaLcok8A8hAIYAQt
         h+M/1hOXNc11xLmiT1ZhTGi0CHu2EbBKaMM75Bha3wpq/1wJ9Q7tZU+bsHch0a1wpq8E
         A6TjGbXahEqRu03jGnYJHgBAw1z6ksTXU+K8rReposujS6eXOngra3FByWxO38LTyblf
         vvXe9LQXpNaZ2gFvMpd2EBJw5JhKr4z+ef++g2C/dVHoI6Gdv9y/Jht7vjTEA9CiixcW
         yM7Q==
X-Gm-Message-State: APjAAAUA7QoU/dQEA2XjAcnBXqJO3TzjcHMTL2JAo0MC/YeX3qxAdlx7
	T7o+XNq5x6U8uwo/zN6erKwHXhq3ywow/o6Txo5/k3j/n3hvkjwRr1KXIp3DIXtGvYoHJwtMb4D
	E6HydhIghQywq92wkGqQOqHb0gdxujKi9YBYwN8b0jBK3w63O+/PVxHdfa5lNXZljog==
X-Received: by 2002:a17:902:bd94:: with SMTP id q20mr93836190pls.146.1558821081987;
        Sat, 25 May 2019 14:51:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxY9yZbf5fdUBGS8MbmBr/V+7pEM3V3xm9wBnP+/0RnXkbZkGKk5EszP2cU7gxSp44lV9cH
X-Received: by 2002:a17:902:bd94:: with SMTP id q20mr93836126pls.146.1558821081135;
        Sat, 25 May 2019 14:51:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558821081; cv=none;
        d=google.com; s=arc-20160816;
        b=xWaMdbKrEU2oag7CQ2qZT5WYdJWFakYIR63XWOTrFW7atcf9bBl0PG9NPUj5Sw+ogr
         P8lIq8cXbYRW7wvXhAeGLu4OwX6d0Gbd8eThbKHliuccpHYL8BfZ3S45/4i+pLcLlrIX
         u/zz5mhYkyrGE53MWWn0NGcelElBzc7ZgGurGyNaTAEb/DHcSlJcItOp12T/gSqkopHQ
         sM+l6yi9INAIKAQp7mfBgyjVTABW9TtlJAnbjOy3pGLBk1ddfdKQ2nIo6M9hEnicAx4W
         UDLv/ZrrSmnjho/vXTZbSMuQeETClOglGvz2VNQAROatP7OjHZ3YHDTPbJMPeGJOx0Zn
         9+0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Ggdf+nwMYpqOtPfchVX3fGXJn/l3ESKOGJa08VuJQj8=;
        b=KoCbzMB1fdVBBwbbA6YbMkQnp0vdRBgG+Sqte0rCevEvJ60sWj2g1R38V0EEz13ven
         r5KoWzpgNM9p0VAHU3BoGY6kcDR/fZKHPX/QKdTNvj9oamlakuDzajoz+oagutQcYSxV
         Ns2+F5XDEe29XkjdUSyXnnUdCWzIFOAQavhU3T44a7uaWPp9EJ+zMiK8FsdJnlMcEBw0
         PCok/DvgcJSMs7uDn7lrBR3Q5cstugyDCAokXUYrAcglXnJ1vjwedw5TxkWMpATAjy/0
         Y/E7wPYuRp79woyuJlr9o7CdUzkqGz6IwbpWZzKoDYRp/ca1BugO7Lm68dv/LobW4b0E
         J0sQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="yeCoL/9Y";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f5si9687250pgb.503.2019.05.25.14.51.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 May 2019 14:51:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="yeCoL/9Y";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7150B20717;
	Sat, 25 May 2019 21:51:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558821080;
	bh=9GojVzJw4LUT0FwL1uJ2uxQz/GR22xKEGuM8E5lF4U4=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=yeCoL/9YBkEk1sCDuZGtqcOLLhjEc3XPpvmQxhmXpl1ivii7ueziKdgVyPiry9ByA
	 ADOT2OgdVR0DYv4LRRgW5QSfW6vt2A05lzKc6kYMl7/+P1G4g6y87rsbUW7KSF+/pj
	 wELWVZx/6l9yaDm7Gysp2a6pdP0M1R6mJkI2X3yI=
Date: Sat, 25 May 2019 14:51:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Alexey Kardashevskiy <aik@ozlabs.ru>, Alan Tull <atull@kernel.org>, Alex
 Williamson <alex.williamson@redhat.com>, Benjamin Herrenschmidt
 <benh@kernel.crashing.org>, Christoph Lameter <cl@linux.com>, Christophe
 Leroy <christophe.leroy@c-s.fr>, Davidlohr Bueso <dave@stgolabs.net>, Jason
 Gunthorpe <jgg@mellanox.com>, Mark Rutland <mark.rutland@arm.com>, Michael
 Ellerman <mpe@ellerman.id.au>, Moritz Fischer <mdf@kernel.org>, Paul
 Mackerras <paulus@ozlabs.org>, Steve Sistare <steven.sistare@oracle.com>,
 Wu Hao <hao.wu@intel.com>, linux-mm@kvack.org, kvm@vger.kernel.org,
 kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-fpga@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] mm: add account_locked_vm utility function
Message-Id: <20190525145118.bfda2d75a14db05a001e49ad@linux-foundation.org>
In-Reply-To: <20190524175045.26897-1-daniel.m.jordan@oracle.com>
References: <de375582-2c35-8e8a-4737-c816052a8e58@ozlabs.ru>
	<20190524175045.26897-1-daniel.m.jordan@oracle.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 24 May 2019 13:50:45 -0400 Daniel Jordan <daniel.m.jordan@oracle.com> wrote:

> locked_vm accounting is done roughly the same way in five places, so
> unify them in a helper.  Standardize the debug prints, which vary
> slightly, but include the helper's caller to disambiguate between
> callsites.
> 
> Error codes stay the same, so user-visible behavior does too.  The one
> exception is that the -EPERM case in tce_account_locked_vm is removed
> because Alexey has never seen it triggered.
> 
> ...
>
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1564,6 +1564,25 @@ long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
>  int get_user_pages_fast(unsigned long start, int nr_pages,
>  			unsigned int gup_flags, struct page **pages);
>  
> +int __account_locked_vm(struct mm_struct *mm, unsigned long pages, bool inc,
> +			struct task_struct *task, bool bypass_rlim);
> +
> +static inline int account_locked_vm(struct mm_struct *mm, unsigned long pages,
> +				    bool inc)
> +{
> +	int ret;
> +
> +	if (pages == 0 || !mm)
> +		return 0;
> +
> +	down_write(&mm->mmap_sem);
> +	ret = __account_locked_vm(mm, pages, inc, current,
> +				  capable(CAP_IPC_LOCK));
> +	up_write(&mm->mmap_sem);
> +
> +	return ret;
> +}

That's quite a mouthful for an inlined function.  How about uninlining
the whole thing and fiddling drivers/vfio/vfio_iommu_type1.c to suit. 
I wonder why it does down_write_killable and whether it really needs
to...

