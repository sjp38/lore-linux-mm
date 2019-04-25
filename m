Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 647C9C4321A
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 15:32:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 80DBD2081C
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 15:32:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="Ksz6Xw2L"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80DBD2081C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 94E476B0010; Thu, 25 Apr 2019 11:32:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8FE2B6B0266; Thu, 25 Apr 2019 11:32:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7ED546B0269; Thu, 25 Apr 2019 11:32:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5CD626B0010
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 11:32:43 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id t5so178299qkt.23
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 08:32:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=pO2pP6FljQafTmg62m+I2qdYl7zhRSiQcJpHjYrZsOI=;
        b=HnlWbBAA0niSbJ5eg6osYo9XOS3OJw0isLCT5MxhsLwBw0dxvyv28SUY46mc/HoubG
         jMI5qE5Ua+skIoeRmdTCMXeNKUcUaeGAWwxa3f/CnC8tjMIHTYgbom4z9qycmMpQr2+H
         3qSTaNipfO/qo4j4c7QMFvbHwgyw4Dpv1EYTkfVHEgswm0ogFnwg79ZTy2SqOB05Dk9W
         XA4+oF58dr3zDWRBu4E4YltYyEtPGOfVt+RAvnJhnuIfsxB+kZ21udnPdFENGUCJ701m
         bw8oMjBOwaaltMk+/Mjl/iFRMQ0SnvJItqgUILgUv/33e3W1u1eX4LMBE+gG4Qd/40Gn
         5wFg==
X-Gm-Message-State: APjAAAWEezsah5IYuXGpyLAl5szTROGPc6fhrN4Brr/KYdlI0r9dsdvR
	V2lhxZbBlRQS6yoUJHKAmwRdivwy7Ba/bsmp2lB9+mZVwpit8b66PO5LDb8vP60rHFLvn6MGlca
	usgWW3tb9xpMDjgRGoNfDRa6jziNtURPC7R+aVnR2ezSWNrGVjbN+R0MbNZ4eVnM=
X-Received: by 2002:aed:35b6:: with SMTP id c51mr23346994qte.154.1556206363129;
        Thu, 25 Apr 2019 08:32:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwFPeraT7BwJ0upHM+AATNCKLtXy+0CRdgfFasSj+EZZ9bSwX5++uQuVkxQykLdQCm7A+UE
X-Received: by 2002:aed:35b6:: with SMTP id c51mr23346935qte.154.1556206362533;
        Thu, 25 Apr 2019 08:32:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556206362; cv=none;
        d=google.com; s=arc-20160816;
        b=uyGCseMIyIK52G56OaLRVhd2sTpbAWmHvHb1IPQCesWZWPGUT+GdFJe2dC20iV2VQ+
         T46e0l92cTzZmEBfUIArBSV6OcWeHS+cIYb+F0GzZiZYf7Ai4fJfIACVnlyMaqrnmqVI
         YMRa6rfRRtf5xurrtGOVMSxo9AgmQrPwEyLFiqpD8bbBzLvfqW5ZVtTrrORrBs9EP/01
         tKucNRmPKD3b0WIrc25Swv70cjs5xaTWUdR10avrHc4fZUOsPLIC/UP8guLmgB8YqzZB
         h97gfYmVfojT13+tSlfq8nNFF6aW5RP8UaBRWDKFGtV70os0P9wsReLtp/Fi58k13JbU
         jPUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=pO2pP6FljQafTmg62m+I2qdYl7zhRSiQcJpHjYrZsOI=;
        b=CNsFDWPJ6tTq6SkxRnXa77L6gPuLFIAE3XThX0LDuPmHwsje9kToHOoxD9RZW2XtSH
         Tjvej6OHP/dLXPc5m3hrQiLG19+JQjv8EtNf4waaNutELCemGlmC6OLXjNvSFyMakN9k
         f44zWK3AOCz3I7FEBPKccGatfSkXVj3jziC6FV5eom5QD9yIqiNPtFKb77lrpOHh1C7I
         ZEixBsTfO0y1yfzQAoE3wdY7Cj9uWbZlbAt8+XpuJiy/uvKTftIXhcs6d92DGfjiMxB7
         aRGBBEfj3oyFcpzkKYmyDR4jmUYUwZWsT/B/3F2BFizsD5VX7ulbmk4GVv2VjCV5I8IC
         Yx5w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=Ksz6Xw2L;
       spf=pass (google.com: domain of 0100016a55209db0-efc46978-fa1e-48be-b17a-fcb6b58ae882-000000@amazonses.com designates 54.240.9.46 as permitted sender) smtp.mailfrom=0100016a55209db0-efc46978-fa1e-48be-b17a-fcb6b58ae882-000000@amazonses.com
Received: from a9-46.smtp-out.amazonses.com (a9-46.smtp-out.amazonses.com. [54.240.9.46])
        by mx.google.com with ESMTPS id t2si65186qkd.225.2019.04.25.08.32.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 25 Apr 2019 08:32:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of 0100016a55209db0-efc46978-fa1e-48be-b17a-fcb6b58ae882-000000@amazonses.com designates 54.240.9.46 as permitted sender) client-ip=54.240.9.46;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=Ksz6Xw2L;
       spf=pass (google.com: domain of 0100016a55209db0-efc46978-fa1e-48be-b17a-fcb6b58ae882-000000@amazonses.com designates 54.240.9.46 as permitted sender) smtp.mailfrom=0100016a55209db0-efc46978-fa1e-48be-b17a-fcb6b58ae882-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1556206362;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=pO2pP6FljQafTmg62m+I2qdYl7zhRSiQcJpHjYrZsOI=;
	b=Ksz6Xw2LBldNY0PeACCSCxyacWYJi2nwVBs9e+UrzD4PQHyFDVKetoqaWKWpQnf0
	WM46Uqwjfx9t2aT4o6gE4SwbHRswpzYhPz0+X6YzhW2kWmvYu3dGcDZzhQLlo06NBK3
	KiN0MpVrYl1Ekn3YvEVgztvzplukXEXDA+f/sMhI=
Date: Thu, 25 Apr 2019 15:32:42 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Matthew Garrett <matthewgarrett@google.com>
cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
    Matthew Garrett <mjg59@google.com>
Subject: Re: [PATCH] mm: Allow userland to request that the kernel clear
 memory on release
In-Reply-To: <20190424191440.170422-1-matthewgarrett@google.com>
Message-ID: <0100016a55209db0-efc46978-fa1e-48be-b17a-fcb6b58ae882-000000@email.amazonses.com>
References: <20190424191440.170422-1-matthewgarrett@google.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.04.25-54.240.9.46
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 Apr 2019, Matthew Garrett wrote:

> Applications that hold secrets and wish to avoid them leaking can use
> mlock() to prevent the page from being pushed out to swap and
> MADV_DONTDUMP to prevent it from being included in core dumps. Applications
> can also use atexit() handlers to overwrite secrets on application exit.
> However, if an attacker can reboot the system into another OS, they can
> dump the contents of RAM and extract secrets. We can avoid this by setting

Well nothing in this patchset deals with that issue.... That hole still
exists afterwards. So is it worth to have this functionality?

> Unfortunately, if an application exits uncleanly, its secrets may still be
> present in RAM. This can't be easily fixed in userland (eg, if the OOM
> killer decides to kill a process holding secrets, we're not going to be able
> to avoid that), so this patch adds a new flag to madvise() to allow userland
> to request that the kernel clear the covered pages whenever the page
> reference count hits zero. Since vm_flags is already full on 32-bit, it
> will only work on 64-bit systems.

But then the pages are cleared anyways when reallocated to another
process. This just clears it sooner before reuse. So it will reduce the
time that a page contains the secret sauce in case the program is
aborted and cannot run its exit handling.

Is that realy worth extending system calls and adding kernel handling for
this? Maybe the answer is yes given our current concern about anything
related to "security".

