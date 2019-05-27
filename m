Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23D1CC07542
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 08:43:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E42802173B
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 08:43:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E42802173B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C11686B0266; Mon, 27 May 2019 04:43:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE8C36B026C; Mon, 27 May 2019 04:43:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AFE6F6B026D; Mon, 27 May 2019 04:43:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 876E16B0266
	for <linux-mm@kvack.org>; Mon, 27 May 2019 04:43:51 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id 68so8508829otu.18
        for <linux-mm@kvack.org>; Mon, 27 May 2019 01:43:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=SPyeTzPFoh+1jcHD1T6EeO+I9ugNzJgCyHNSVSPB+Tc=;
        b=DDncqzvJ+eKayTzzVYBH9TkiIRvsmZK6h+MJuemEFtWnb69vKZ0S3DZK3Ycp8IVBGL
         GVMGB2l0xRNhM7NYKZ7mvjbg4xI//deozv9mX3xd0LlvGAHRGGzq1cM1b7jzk94pUaqA
         dzlkjXNNNsRaMb+JweV1mMpR68hWJ/24V9oX1QL39sUUja3o96KQDAcsEDEejNhgLmwr
         n77lLHjkAXAiZ2YyrUvr1tL9KNpAd08tss93yZ68K2NxBlQQ1aOJUhavsq+sVWhzx/j6
         fpLiM2ysNGl6hbdDn/WCYSwkOtLnWs0Yxf7oRDpr0T4siaSsWcl1IaNbEw3sj2x22Pxs
         WPmg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVu3EVg5g7wHmqk2mW48YTfMfhG/vWvpE/t0bdMBfm5eN8qVw6H
	Kv43ZMRXV1vhCyZP+0SIq8AOATdI7nz0NNlDKW6fs5rIIvwt0ScLPtq8KE+1ILYuLsOj3857tG2
	Tj/Ip2C+t4GEHIknRnBWuYgs1x/YJlfQwDk8E8MdIRU8d9VmtRoK2JscqbGDXER4=
X-Received: by 2002:a9d:715c:: with SMTP id y28mr63982147otj.95.1558946631195;
        Mon, 27 May 2019 01:43:51 -0700 (PDT)
X-Received: by 2002:a9d:715c:: with SMTP id y28mr63982123otj.95.1558946630586;
        Mon, 27 May 2019 01:43:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558946630; cv=none;
        d=google.com; s=arc-20160816;
        b=Y+qL/2hoy043hH6egmPeH6Ft2C6alKZwh9JoFdd5PBA37cA4JFm7vTxXQDHPkANQdA
         IAcxoh+ZN7XlwOo3nGZZ0Hbu64FlUunRRjKN+4HzRvgkNiJXsMd3LLA3GZfEhxMIWFbU
         wfYp54RVsM6B7Woj45ONP03pwcRJbymN7hmLYhBjoQaGXf0Mvq8M974HhZogBXlaX5ja
         McIZH+707wM87Jrx4Wy4E3rl67sdN3ksyevhu4E4wY0/NN+sUVuxu4anBOvuxk7JdXXn
         OSSb6XFJrkIiiT69VN9LmjQ7rqvxDFrlHRIoMItc0cPOZclXpw5lZKhVYx+BtqPl0H33
         9yjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=SPyeTzPFoh+1jcHD1T6EeO+I9ugNzJgCyHNSVSPB+Tc=;
        b=ahbD3NmYZBLbl0ZbSlPYnG22GFojYw+OCbo4uN31frj3DvvNQ1oUT7jD3GiPJSlDDU
         T6f1B1g0gfa9JgTI19dKBGS5Gg77bYT5dES7V4FicGym7umSR/tINzk+QlOwiafNNvX3
         uCAeTCrlbgp5xrIDTeZcGRAHm/lIiA8UfUx1pxBl5oU8qDJQneI3rvvR8V2DDnOD3CF5
         GO8NHgRVcwXL9+cbepg1ZtZy4DEnyEVeIgMRYDNV3FQIxSqDus/b1YMQaC1E4JUu5HPp
         aP28bEbZ6pmUxLD3IlIvaQ/owXKel8SbdgJAOZ7eaI28+GiDeWMODNwU3yGwY/eag4Zc
         7ChA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j61sor4417654otc.36.2019.05.27.01.43.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 May 2019 01:43:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqxIlLFH84yhUFerMj/YlUDBNDBRTGJTxhPDFRXnfvuo7mYZbz39ugxbhoZlfat/iRijWwRpROWfadWrjYSeMCE=
X-Received: by 2002:a9d:7dd5:: with SMTP id k21mr43860970otn.167.1558946630255;
 Mon, 27 May 2019 01:43:50 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1558362030.git.mchehab+samsung@kernel.org> <4fd1182b4a41feb2447c7ccde4d7f0a6b3c92686.1558362030.git.mchehab+samsung@kernel.org>
In-Reply-To: <4fd1182b4a41feb2447c7ccde4d7f0a6b3c92686.1558362030.git.mchehab+samsung@kernel.org>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Mon, 27 May 2019 10:43:39 +0200
Message-ID: <CAJZ5v0iiSo=yoyZTt6ddf5fBRGy1wSvzmA-ZaHH33nivkSp22Q@mail.gmail.com>
Subject: Re: [PATCH 10/10] docs: fix broken documentation links
To: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Cc: Linux Doc Mailing List <linux-doc@vger.kernel.org>, 
	Mauro Carvalho Chehab <mchehab@infradead.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>, 
	"the arch/x86 maintainers" <x86@kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, 
	"open list:EDAC-CORE" <linux-edac@vger.kernel.org>, netdev <netdev@vger.kernel.org>, 
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, Linux PCI <linux-pci@vger.kernel.org>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-amlogic@lists.infradead.org, 
	linux-arm-msm <linux-arm-msm@vger.kernel.org>, linux-gpio@vger.kernel.org, 
	linux-i2c <linux-i2c@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, 
	xen-devel@lists.xenproject.org, 
	Platform Driver <platform-driver-x86@vger.kernel.org>, devel@driverdev.osuosl.org, 
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org, 
	"open list:ACPI COMPONENT ARCHITECTURE (ACPICA)" <devel@acpica.org>, Linux Memory Management List <linux-mm@kvack.org>, 
	linux-security-module@vger.kernel.org, linux-kselftest@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 4:48 PM Mauro Carvalho Chehab
<mchehab+samsung@kernel.org> wrote:
>
> Mostly due to x86 and acpi conversion, several documentation
> links are still pointing to the old file. Fix them.
>
> Signed-off-by: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>

For the ACPI part:

Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

