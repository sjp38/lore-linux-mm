Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	T_DKIMWL_WL_HIGH autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74E1BC31E45
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 20:48:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2CF36206E0
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 20:48:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="UgyruavC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2CF36206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD0496B0007; Tue, 11 Jun 2019 16:48:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B5A4E6B0008; Tue, 11 Jun 2019 16:48:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A49C56B000A; Tue, 11 Jun 2019 16:48:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6A5626B0007
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 16:48:34 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 14so9842865pgo.14
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 13:48:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CgrxybX+M4OKywFR4S6ZTayZSv6sXYJx1SqRWUW6VI4=;
        b=qvL0vn6g6H7lwDf5hB3obx1yjPOY9fOQQIougjDI2K4ZB/oBUePLA13QLEB1ZpKxyq
         xTst6QDypFG4U9F73ruBVb4MrQTxBkpNV1U8fbb2ljZPkb8X0/7Ig3p8jFJiw8yF6FDb
         +IOV21OYTZfszG70hvQr0bSqIQhKj1anxvr+hAds+M64SBv7AHIWB8Qsr5r0sjBAqmys
         s3pHkiCLM85UeL9m1ZM/B9mWaANkXkjWBEQNQLr97BY3uIBOawlLfSmmvaXOd/en3pWc
         gehouVTQ6N3/3dbcroUJ6+nk5n6YYn25poBxvq3k8MxMzXwsGGbR2YsykKSiTk5aFBt6
         ZtWw==
X-Gm-Message-State: APjAAAXORSCVuHOa3UzVqV2dWryV9bTptXrEAVSFVh5LrBL3/tXKmett
	fE/pbS+LLLmLlmTf2fpNwGCL0BfUdKdPmMqit1JfRa0tinvGn30qeNFmVXieFzweczzl4qKCNuu
	e5Zzt3nFfBGBTmqo89LI2N5ZtYz4YK8eO8hyDqgKQ4lo1rT5PBDyGrpcC2ItuZeLnxg==
X-Received: by 2002:a17:902:b110:: with SMTP id q16mr70397682plr.218.1560286114092;
        Tue, 11 Jun 2019 13:48:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyAfxrhynnieotTklFmHnJOrnU95M3t54k3kYR1T3grOok5sP6jXM3102kJFfjkmNp+RT7N
X-Received: by 2002:a17:902:b110:: with SMTP id q16mr70397654plr.218.1560286113491;
        Tue, 11 Jun 2019 13:48:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560286113; cv=none;
        d=google.com; s=arc-20160816;
        b=H7vLdhyxyL+hdcSgXntsrWbIk23FQ7ra195Y0lb6u+kGOZQF56xlKnHv6+fIcaiO0k
         X52caSypvj5OSQxJUjQK6Dhdxz86Fc45bRxjlYVYTFgPhVLDpAAOg/Rv7bEaNnsGtO8I
         x66tvuxHQmHnK84AOVbLYNw6FfyCI+ixQtigVhyNxhBsK1ot141NtIqI65xvkl9GDhCI
         I+TOGo5anLu3HdTff0bslkWW2r7YclVsIqNTlEBjioMe/PIrmT4jovV/pRLBcYuPPu7j
         efUE05dNhJEXHzC3koCx6SMkgpBVQc/e5fMdYHHYHZ4fkS8dUgIigGbbfrcG/+HN5wB4
         WYHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=CgrxybX+M4OKywFR4S6ZTayZSv6sXYJx1SqRWUW6VI4=;
        b=ZZTCK3gw0qenem5PEhsguz/lsMlaUvJj2c3ptuhCrxkM0ns0YthEmsDOQf/Qom0ToE
         n2zZPpUsD2HWSGFsEh4VIWitXcSRFkQ2uPFnmjMUqPxJNy/uMT+HWZJFnrdEGtSIkW7Q
         0Blfp1IoHvpRFFs6m7c17Hob89CzUiHqUmKozkvklQp3VXC8tndT4UhxretQtLCssr24
         dwA0xB+glsvgexaOi8W0HtzLRbri5vRosojnbyg+C4x+MXIbcv2MD1NkUdCKTpq/EsDI
         OFQctOpENALHFFIR+EycJKb+1GtFxvgJBmQsaBrKsPe42eL38EH3axNiHV/AYiZQR7sC
         EA5w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=UgyruavC;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m20si3421761pjn.40.2019.06.11.13.48.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 13:48:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=UgyruavC;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7CE6320684;
	Tue, 11 Jun 2019 20:48:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560286113;
	bh=y33lrlkQja7eoIovWsePDjdEdIHZ/RJoRj29PafhqOI=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=UgyruavCsSZLLvbVGn/8Url9hdMFqD/vc6cS2xvCxVAaLGSpqRyO7wgSl3uYSlnrC
	 3+fJjYU9x+kvkKn62ONAnZk5QMPYKtIt9RU5V2bIySebdJX4pNazzbre4oO5OlK2mG
	 81xtH5C+HAjNqK8Itw5roVmiKtRcfGnYRZlw+kVk=
Date: Tue, 11 Jun 2019 13:48:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Shyam Saini <shyam.saini@amarulasolutions.com>
Cc: kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org,
 keescook@chromium.org, linux-arm-kernel@lists.infradead.org,
 linux-mips@vger.kernel.org, intel-gvt-dev@lists.freedesktop.org,
 intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
 netdev@vger.kernel.org, linux-ext4@vger.kernel.org,
 devel@lists.orangefs.org, linux-mm@kvack.org, linux-sctp@vger.kernel.org,
 bpf@vger.kernel.org, kvm@vger.kernel.org, mayhs11saini@gmail.com, Alexey
 Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH V2] include: linux: Regularise the use of FIELD_SIZEOF
 macro
Message-Id: <20190611134831.a60c11f4b691d14d04a87e29@linux-foundation.org>
In-Reply-To: <20190611193836.2772-1-shyam.saini@amarulasolutions.com>
References: <20190611193836.2772-1-shyam.saini@amarulasolutions.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 12 Jun 2019 01:08:36 +0530 Shyam Saini <shyam.saini@amarulasolutions.com> wrote:

> Currently, there are 3 different macros, namely sizeof_field, SIZEOF_FIELD
> and FIELD_SIZEOF which are used to calculate the size of a member of
> structure, so to bring uniformity in entire kernel source tree lets use
> FIELD_SIZEOF and replace all occurrences of other two macros with this.
> 
> For this purpose, redefine FIELD_SIZEOF in include/linux/stddef.h and
> tools/testing/selftests/bpf/bpf_util.h and remove its defination from
> include/linux/kernel.h
> 
> In favour of FIELD_SIZEOF, this patch also deprecates other two similar
> macros sizeof_field and SIZEOF_FIELD.
> 
> For code compatibility reason, retain sizeof_field macro as a wrapper macro
> to FIELD_SIZEOF

As Alexey has pointed out, C structs and unions don't have fields -
they have members.  So this is an opportunity to switch everything to
a new member_sizeof().

What do people think of that and how does this impact the patch footprint?

