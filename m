Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A53B4C04E87
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 14:17:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 71FA2214AE
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 14:17:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 71FA2214AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=rowland.harvard.edu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E86406B026F; Mon, 20 May 2019 10:16:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E36E36B0270; Mon, 20 May 2019 10:16:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D4C606B0271; Mon, 20 May 2019 10:16:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id BC3346B026F
	for <linux-mm@kvack.org>; Mon, 20 May 2019 10:16:59 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id n198so6644170vke.9
        for <linux-mm@kvack.org>; Mon, 20 May 2019 07:16:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:mime-version;
        bh=LyCOF91sKOXoKMxXRxwCUpS0O5n3MU0wFcINOXOMfXA=;
        b=J918KtOuY4nvxfcmnxzNygtSlq0j34o0rIvI/5Pf+P2hMHkFplF4/WRAHQp06F1Vuj
         iclGL7Pc3k9LBuhVh80rr/q5/PP1ZD8PKQgauKuMifkCWFbipD0aFFFLLdGudhtn10RY
         nqNPjmg35CrbZCirLgYUttx91ROsI4yB2gatKLyNBLsY5d3QAMItk52M/KZh1ADACbwU
         a4xpaDTTnRpZUrpXvhpa37JsjapyDAigZE9nurMf+sbphRg8eggy8VhFo08zLWVMpD+1
         qR1Xd41VXFIYOb3XgrGHRWr9auy39lw8RwbFryKTcP6NbjlkLEsK9An7CgNiSed9qKy5
         4Yog==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of stern+5cece118@rowland.harvard.edu designates 192.131.102.54 as permitted sender) smtp.mailfrom=stern+5cece118@rowland.harvard.edu
X-Gm-Message-State: APjAAAUYrCDEPLGTWmDtT7U8TESR8lmHRlXZxA3l5Ugz3EqWso7g3RQ/
	GKbthDUTPOnB1F5KwU2m/idyGy//cwNCwYu2kQK1ZFgWfgoqRReYKzRtKL/sz9J2xZjsRwS7eDu
	6iawNuB2HyeIUr2FAGmj8LDJaVlu+306/MtHt3F8esLtaWPiMpm2csCplxspi4LO4og==
X-Received: by 2002:ab0:284b:: with SMTP id c11mr20755584uaq.115.1558361819428;
        Mon, 20 May 2019 07:16:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwwde6rKxjjAbibD321rLjClKyKsuadGq+z+Eju94GJq1TiFrfJKWLKwPUOF+BycGfnrz1V
X-Received: by 2002:ab0:284b:: with SMTP id c11mr20755529uaq.115.1558361818683;
        Mon, 20 May 2019 07:16:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558361818; cv=none;
        d=google.com; s=arc-20160816;
        b=bOgUUzFR5b6T4uwOMSIn+V47q2CL4rLSkZh2SzKDVOsGVAYlXzwBl0mIRLFVs770rW
         pvEKrqtftwK8tD4x7cfLUZKSgpmbgbEoT72f4caIGhdtTfsClba84jy/raLQt3yj6vAF
         Q4DiDCrLwhYtpiGbOGvbx2qHsRZzLTLpHT1MG63WgBbx5xkMpTUTcfEYl2YjSrxh2FQ6
         y3Biy5uqNy+Lohv2YgcVRZWu8z8qOZXdQyULmPe8kuYwF049rSLchdKBNDQFSIyf/35I
         6trRBE86jcmNbAXnDfGQp6Cipux5yr9HiHoX6eWQz7QLpHUoA0NaZ4drq0xcNuC9Jmr8
         axoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:in-reply-to:subject:cc:to:from:date;
        bh=LyCOF91sKOXoKMxXRxwCUpS0O5n3MU0wFcINOXOMfXA=;
        b=b5bY+45KObWCFEolA9nnPiZXn2Q661IjUZ3OOx98LytR8Y8PbZyuSkOWcJT7pO0h/o
         plGbkxdTW/QWBOsDdfSELledPJ17u5mR+LTajmJMxxbdhSS4zfwDspDN6waU4Z4RxW4H
         DvKUV+4Fb+GbuiY+JdJ5viuzCqGScBhvKZd5hvFyr+6jyU4LwrW/f8nEIF5vQgQTIsI/
         +jB05DvYGi8OfLs2TWCfgCUVtHqi6GElJehlyvo+YrgZ9+Qx8ixmaCG0Io1wsXx5T6P8
         oopgaXoimqdaLiAdCJ+ONVVPKHXSUvR+Fa3hexAnmeXLTg5K68t8zAhyEHpLg2x7p9hX
         j4/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of stern+5cece118@rowland.harvard.edu designates 192.131.102.54 as permitted sender) smtp.mailfrom=stern+5cece118@rowland.harvard.edu
Received: from iolanthe.rowland.org (iolanthe.rowland.org. [192.131.102.54])
        by mx.google.com with SMTP id b202si608376vsd.296.2019.05.20.07.16.58
        for <linux-mm@kvack.org>;
        Mon, 20 May 2019 07:16:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of stern+5cece118@rowland.harvard.edu designates 192.131.102.54 as permitted sender) client-ip=192.131.102.54;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of stern+5cece118@rowland.harvard.edu designates 192.131.102.54 as permitted sender) smtp.mailfrom=stern+5cece118@rowland.harvard.edu
Received: (qmail 1756 invoked by uid 2102); 20 May 2019 10:16:57 -0400
Received: from localhost (sendmail-bs@127.0.0.1)
  by localhost with SMTP; 20 May 2019 10:16:57 -0400
Date: Mon, 20 May 2019 10:16:57 -0400 (EDT)
From: Alan Stern <stern@rowland.harvard.edu>
X-X-Sender: stern@iolanthe.rowland.org
To: Christoph Hellwig <hch@infradead.org>
cc: Oliver Neukum <oneukum@suse.com>, Jaewon Kim <jaewon31.kim@gmail.com>, 
     <linux-mm@kvack.org>,  <gregkh@linuxfoundation.org>, 
    Jaewon Kim <jaewon31.kim@samsung.com>,  <m.szyprowski@samsung.com>, 
     <ytk.lee@samsung.com>,  <linux-kernel@vger.kernel.org>, 
     <linux-usb@vger.kernel.org>
Subject: Re: [RFC PATCH] usb: host: xhci: allow __GFP_FS in dma allocation
In-Reply-To: <20190520101206.GA9291@infradead.org>
Message-ID: <Pine.LNX.4.44L0.1905201011490.1498-100000@iolanthe.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 20 May 2019, Christoph Hellwig wrote:

> On Mon, May 20, 2019 at 11:09:25AM +0200, Oliver Neukum wrote:
> > we actually do. It is just higher up in the calling path:
> 
> Perfect!
> 
> > So, do we need to audit the mem_flags again?
> > What are we supposed to use? GFP_KERNEL?
> 
> GFP_KERNEL if you can block, GFP_ATOMIC if you can't for a good reason,
> that is the allocation is from irq context or under a spinlock.  If you
> think you have a case where you think you don't want to block, but it
> is not because of the above reasons we need to have a chat about the
> details.

What if the allocation requires the kernel to swap some old pages out 
to the backing store, but the backing store is on the device that the 
driver is managing?  The swap can't take place until the current I/O 
operation is complete (assuming the driver can handle only one I/O 
operation at a time), and the current operation can't complete until 
the old pages are swapped out.  Result: deadlock.

Isn't that the whole reason for using GFP_NOIO in the first place?

Alan Stern

