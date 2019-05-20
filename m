Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15508C072A4
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 09:22:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9192206BA
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 09:22:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9192206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 617036B0007; Mon, 20 May 2019 05:22:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A0446B0008; Mon, 20 May 2019 05:22:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 469056B000A; Mon, 20 May 2019 05:22:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E9B226B0007
	for <linux-mm@kvack.org>; Mon, 20 May 2019 05:22:25 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n52so24341377edd.2
        for <linux-mm@kvack.org>; Mon, 20 May 2019 02:22:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=y5RnlwgXgtcEOd+FL8AfoAJbEGyoQwEcqWceARm5kaw=;
        b=hiNRnVQbdhYzDvd58nFWpKr2MyZ0363eZOHRGigkp5ZmS7qnuKWM8XgMJEdbEJUGoq
         8Mka23Yk6sty/rRkHaR5YIU4M48YH7+t4tQu/AcAHSO6sPTLPVMe4tHX8FKsk+0coucw
         C/BalUngnagDpuWZtPYRDag8GC0W/5UUETu0jjG6QzS+/ilq2OHG6eU7cHi7/72/XYiV
         ksf1kJ0cwc05g5lDYPGhHL65nF6mDYezRyGPZoAiebcj5OQ0JasbnpI8FSlkTlVjaJxt
         yYe4n0X1M3og0LRL4wm8AAN1+dwPzX75gydIwryO/4Lj8aVoOQ4gYIHk+v0rIf9iINBJ
         M8pg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oneukum@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=oneukum@suse.com
X-Gm-Message-State: APjAAAXxEyE42FdLp3iz3q2D8GWRyOq5CWck+XBVG4s/P5jnZ92VVMi2
	Qr1QGwNdsGgUXsHWiwh6/4QOPN51bl/WVm73gnBQWB2ChMlJo2PCk+69OXftGo2kSH5bMe++brA
	TfHOuPiZFY6gKlIWN0GAWzVsY+JnsgnUhxt2tH8LJ9ih0TfMcEYrQnXjt338F+EtLJg==
X-Received: by 2002:a50:9441:: with SMTP id q1mr73957790eda.101.1558344145487;
        Mon, 20 May 2019 02:22:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5BZZQteSqsnK8tGi71vgtMyAsi5h4kTaAcpEt3LQBajHFD2TSpK1QxFqHwqw5ixLVJEjo
X-Received: by 2002:a50:9441:: with SMTP id q1mr73957731eda.101.1558344144613;
        Mon, 20 May 2019 02:22:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558344144; cv=none;
        d=google.com; s=arc-20160816;
        b=QeSi7yxPUBzi6zlcVweAfJF0tBzHeGlAfEh9S5LLbAc62U/vbPNqID8emsIhH/9/T6
         YvIAWR9VqX/GpC/m4Ql7zYnDg338bSEotzsCwxLYBvkAvUSasmVphg44VyPMTuf7OYdp
         XomvkNYo9Z4cNKEe/Isu2Q2VnNn5RBWCkunp6TdrNryAFymFLld6fPSKuEbaCNU2YVIC
         4blP8UGooOm6y6o6iOjJSqq1VFBFJ2CbPAYDo5dE+NdqBTweqGq4vwzgV6D23M29nIcF
         FPtLuNfGuTf96a/HP8ti4ybiI5o503g4ZBeCUYTbCVA3al55a02u4fTRmwhSi45VNveA
         65zA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=y5RnlwgXgtcEOd+FL8AfoAJbEGyoQwEcqWceARm5kaw=;
        b=hBnKcKRCP4CQKxJB8FkLBhLBGOdq7Nzj1b1tcGZ+EiizvTFujtwsrbsW+Qetb/k0aU
         q+ej50pfE1alZklxwZodfEHC2scS7e6q1o4VcAIZANYb7wxa+LTcjyyentNDgVNUJ4Xh
         3C7Cr7tf2wPExDuhogW6VpBGlWIh5KDgDsizNVJIw++NHUjrjY4zsDpweuW3mHchRZCp
         /NvUx96HpUQVeLS2e9mfpuSW4hAt9RLMy4xC1U/wIej1FOpERixbHj/GZzMaolXwaAzW
         TuhDhntJ4wvlWlEaMs8wYMyV+M8ZTOcUyJurl37EbQK+T6VxsOzlv9o3GnY8sBB87MIc
         RJRA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oneukum@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=oneukum@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w9si12595860edb.296.2019.05.20.02.22.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 02:22:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of oneukum@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oneukum@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=oneukum@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 07D5DAF5F;
	Mon, 20 May 2019 09:22:24 +0000 (UTC)
Message-ID: <1558343365.12672.2.camel@suse.com>
Subject: Re: [RFC PATCH] usb: host: xhci: allow __GFP_FS in dma allocation
From: Oliver Neukum <oneukum@suse.com>
To: Christoph Hellwig <hch@infradead.org>, Jaewon Kim
 <jaewon31.kim@gmail.com>
Cc: linux-mm@kvack.org, gregkh@linuxfoundation.org, Jaewon Kim
 <jaewon31.kim@samsung.com>, m.szyprowski@samsung.com, ytk.lee@samsung.com, 
 linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
Date: Mon, 20 May 2019 11:09:25 +0200
In-Reply-To: <20190520055657.GA31866@infradead.org>
References: 
	<CAJrd-UuMRdWHky4gkmiR0QYozfXW0O35Ohv6mJPFx2TLa8hRKg@mail.gmail.com>
	 <20190520055657.GA31866@infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On So, 2019-05-19 at 22:56 -0700, Christoph Hellwig wrote:
> Folks, you can't just pass arbitary GFP_ flags to dma allocation
> routines, beause very often they are not just wrappers around
> the page allocator.
> 
> So no, you can't just fine grained control the flags, but the
> existing code is just as buggy.
> 
> Please switch to use memalloc_noio_save() instead.
> 

Hi,

we actually do. It is just higher up in the calling path:

int usb_reset_device(struct usb_device *udev)
{
        int ret;
        int i;
        unsigned int noio_flag;
        struct usb_port *port_dev;
        struct usb_host_config *config = udev->actconfig;
        struct usb_hub *hub = usb_hub_to_struct_hub(udev->parent);

        if (udev->state == USB_STATE_NOTATTACHED ||
                        udev->state == USB_STATE_SUSPENDED) {
                dev_dbg(&udev->dev, "device reset not allowed in state %d\n",
                                udev->state);
                return -EINVAL;
        }

        if (!udev->parent) {
                /* this requires hcd-specific logic; see ohci_restart() */
                dev_dbg(&udev->dev, "%s for root hub!\n", __func__);
                return -EISDIR;
        }

        port_dev = hub->ports[udev->portnum - 1];

        /*
         * Don't allocate memory with GFP_KERNEL in current
         * context to avoid possible deadlock if usb mass
         * storage interface or usbnet interface(iSCSI case)
         * is included in current configuration. The easist
         * approach is to do it for every device reset,
         * because the device 'memalloc_noio' flag may have
         * not been set before reseting the usb device.
         */
        noio_flag = memalloc_noio_save();

So, do we need to audit the mem_flags again?
What are we supposed to use? GFP_KERNEL?

	Regards
		Oliver

