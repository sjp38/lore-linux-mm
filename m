Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89EDBC7618F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 22:50:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A7B621852
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 22:50:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="y0N0mM41"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A7B621852
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF7518E0006; Fri, 26 Jul 2019 18:50:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C80D98E0002; Fri, 26 Jul 2019 18:50:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF9688E0006; Fri, 26 Jul 2019 18:50:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8331A8E0002
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 18:50:35 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id h5so33915391pgq.23
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 15:50:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=troxWXRMJSEd9PrbsmZKtALf0ajWUq08I+8EnR2AizY=;
        b=J7efPyzM/5z6aX4HRsUXJOXaEwOL1Gm3nCew6KlqfcHiTL9sivsVcMlnW+tdeK+nlG
         SyXaGasvN8nDsvWXDpaQ9L32ICG42PUOMIJY1k/VolYkXlgXCq0hZgZzN2CxX5xGbv7O
         Mp6X4sFAIldY0TxGnbxOp1Gw0BGxExT0OM+hlMezN6rVR0wxj8fvW2gZayWrqS8lDltQ
         nZWMxGDM2fXCqAAkKMK+B+JfHwU+MgS9tsvMOr5Kx0MNmUGafjbx4i8JgeXrylnf7fkS
         nyoamBTud53FvC9PbdIC8n+QRKSJlIq97Q8jiFSbhq06eT4icjO35cBvoqClHynNHeJG
         tSWA==
X-Gm-Message-State: APjAAAUis8B5tSUTCpB+Edq4qqHBGEusggr1EO5aIB/Z6P9g5RmUpRQT
	W+ld9wTdr/jUOY67gKAQwjm+3IeG4EFT83yDdL6bBycLv1Pg0/fCgxCnZmfzz/wReRwDbzhBmFV
	9MNvx8GSA5cD/TqAfD6RXrR/Dj6ULOUJV5AV9KZHog11IvOXJ3ZwlHQGAO2SFc9RecA==
X-Received: by 2002:a62:f250:: with SMTP id y16mr24534392pfl.50.1564181435203;
        Fri, 26 Jul 2019 15:50:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqywm2maXgeSyHG1iJ0SWYYvzYLqBwqGvN8hPZDydUuxFjTA72fQRr8Uzh+Ckayfrqdc9Uys
X-Received: by 2002:a62:f250:: with SMTP id y16mr24534350pfl.50.1564181434547;
        Fri, 26 Jul 2019 15:50:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564181434; cv=none;
        d=google.com; s=arc-20160816;
        b=tFej5ufr950FFxy/r3JAjZEM/ehhzat+Mv5mVT2yhimVCFYtsWQXBJY6pcq8EZjm+8
         Omao8o8fIDWAzQ3GwsyUHlK9WvmI2foK5nyEe9s3b7zvlDuqYPn4Ad6ar4lrdr9LdlOV
         7qM7+esRB7q6o8dTukAC/zcnAyFXdwPh/GY53+HwRyC7t9LwcTJN62Sf7CsgmxCaNrAM
         glAWeoB9PtZmaftwGZHIU0rRwdl3W5nXW/fZL6mnaTCksT4PhP1wmI7+xnUVDD8eyg0M
         eQpHrxW2H65HE61EGAMeFLjYCiPJ0GbAf5UgU3EkeygMaAq7/MSanCvhpNmMs651R+f5
         AdVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=troxWXRMJSEd9PrbsmZKtALf0ajWUq08I+8EnR2AizY=;
        b=uqQvh1g0TShUuQpBcpO6kg9/LMCmeeTWw1satUIQFuHm+X6VyfyQLVgjysYMXU8ht9
         0CsR1TJuOg31blnSR5+hbfnVABCdo9w5STIZkxUAq4lKPjjR62RqNkx3a514cgcUmoeU
         vkqNL3KqaPch5x8mecbD9sBf43vqvQShsUKL60f+FEZ2XVV9u1BpwPGVK3opZefLba+S
         DEj/rhVWct3T5gxpe4XrIl6E/yU/nrGV6qBhNv022TXS2YFl0A13sZBBQu8g0tXp6rV7
         jx+5llmhSJwUl5G/Aj/oS2nxSwmEg7m1iDTT7n8ZdCSS9M2g9GWUE/B0bqqoWVzgMDuF
         1Baw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=y0N0mM41;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j100si18502592pje.52.2019.07.26.15.50.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 15:50:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=y0N0mM41;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D6A3E20657;
	Fri, 26 Jul 2019 22:50:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564181434;
	bh=jcUbNJUk/+4T10G8HH13wiXX/jvL3CBM+iFCXy8Aj+E=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=y0N0mM41BVeh6RLIAXTqKufpksZcV3vzwvnS3tK7U8IrL/2fbN66+NuYmc8VN01Vk
	 KYNR81POgm4zm+5onbmm1elqC7omxeJs+Odxel1tIoMI/kxapMk+QReTgQ7OY5lVQr
	 IVecxvbbs0tkzm9pXT5p7G3nDAQzYC1PSoFjcJaM=
Date: Fri, 26 Jul 2019 15:50:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
 linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>,
 linux-mm@kvack.org
Subject: Re: [PATCH 2/7] vmpressure: Use spinlock_t instead of struct
 spinlock
Message-Id: <20190726155033.d10771437e26dd5007f91a08@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.21.1907261409260.1791@nanos.tec.linutronix.de>
References: <20190704153803.12739-1-bigeasy@linutronix.de>
	<20190704153803.12739-3-bigeasy@linutronix.de>
	<alpine.DEB.2.21.1907261409260.1791@nanos.tec.linutronix.de>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Jul 2019 14:09:50 +0200 (CEST) Thomas Gleixner <tglx@linutronix.de> wrote:

> On Thu, 4 Jul 2019, Sebastian Andrzej Siewior wrote:
> 
> Polite reminder ...

Already upstream!


commit 51b176290496518d6701bc40e63f70e4b6870198
Author: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date:   Thu Jul 11 20:54:52 2019 -0700

    include/linux/vmpressure.h: use spinlock_t instead of struct spinlock

