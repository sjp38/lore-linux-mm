Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73F9CC31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 15:54:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B513208C4
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 15:54:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="qhOUahTG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B513208C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD8E96B0005; Mon, 17 Jun 2019 11:54:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C88DA8E0002; Mon, 17 Jun 2019 11:54:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B77FA8E0001; Mon, 17 Jun 2019 11:54:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 818F76B0005
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 11:54:51 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id h27so765252pfq.17
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:54:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=JsLGNlBjqPDNYMzy2gUsiYSehMTIrAaU1M2H28JdTds=;
        b=F0FhkqGd0SepUcZBXjDeVLcs+DINoo3GmaUZ14CA2/vrGd0eWXGaOlcAQ0FmFdB2UH
         Pe2VQlDvKC+pnT9j21AlkLUyR4qxkpeEXZYKv/Zdl7Btt54HO+EN2CvjLBZfn8/7CzAv
         rf0hmhLrsVx28LqmsEX1ejXY3t4Y/5ohpWS6si1OWDEyOerU8Ipkl2UvLjjFtY+hU/nq
         3h1o6PFxT5S7/mUgDZOZIWR3LUvyszQ4RuIx0ROXeSRsRh6u3zhPuqA9TWGR45OypKH1
         4HQc0+83ltmEPKngMB/ZgtAzNHFvIkmvSob60IhzNp/ZnuijEKvPA9HssOs+ERqxPqeT
         2GQA==
X-Gm-Message-State: APjAAAUmQLF1wecculZmlr3MgsYA/33LgL/PKkkzyOIR7xZMKmqRotfv
	okLEqGbhqWaevkLDBGJL5WSpsPzjxYkyeI8seFrVXKIvgQNw4vffCxWpEIYYBbdblQlmtWyMlLf
	yk51C/yan0CLB/WvhrjhQEfGzlbpjHjNQ2RiR9KFBRB2F9ztnXQJDXU6yfgnOBMK8dg==
X-Received: by 2002:a17:902:b18f:: with SMTP id s15mr111675016plr.44.1560786891125;
        Mon, 17 Jun 2019 08:54:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxAXsBo06enu6hdQ55i4FrVV4A7Il3DJpnqsdXdAu0WbrPWVgGJmb2eG/2VAcZy5cGsmSo0
X-Received: by 2002:a17:902:b18f:: with SMTP id s15mr111674974plr.44.1560786890579;
        Mon, 17 Jun 2019 08:54:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560786890; cv=none;
        d=google.com; s=arc-20160816;
        b=kKnkC+lm2+JZ3TasL4dNX1TWK314kYwEX7PP678tBlNLTzjmhiwgpeGnBrMIbB0CAK
         7y02SrJoDVmwy5lwS6jmxJwDmtRjfl8/dzdzfAN+o339vl3rrLVFIsBMfiZt+PLl5JSy
         5CsSrH05UwRGUoj52b7OmOsJS8RFaXtyPWmSmbDstap8UKflKqkbZvoWzoKS6qVD8+lf
         QPJs6B3ODaaskVRIss3rtC4v6Wyf8c1BQwhZgmmdRG4Wy5vO6VqBHdrnurwiHmaKNT9l
         gUUSUI095duYpLdZ6XshqWNwbm7mj3FNJY5w7lwW2BcfqlKhnmuNDSOJIw012UaIjfIB
         Qwtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=JsLGNlBjqPDNYMzy2gUsiYSehMTIrAaU1M2H28JdTds=;
        b=OaltVTZ9SWzS6jvB7WFSH8LMIWJSEKV+vXZo6DP5y4ClTo6FlpylFFwRZvoc7Xtz7p
         LiVZ796/1Y0m7iOub5toCh/YpodU7FmJ7LnMxYefNtq5KlDck3bWugMhkW/SvbwvKAQI
         pACoNDGRYZZKrmCKcmThGB/tByGdzaJCRO44tu/Qi3en/FXj6YW9tygPBr9fAFUr7aPY
         efhtpIyRUOSlSL9zdyGBi3e4nqIVO/3dSwcsYErKqEdHNdFqz27hUZeb8N0foJIfYYcg
         NBlaOv8ROO9emQoIaKuOxKG81HSHvq16Sg6w+op/sJGT5d89MFZg+bH7oOtmopHKwmZN
         aMRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=qhOUahTG;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j63si621083pgc.185.2019.06.17.08.54.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 08:54:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=qhOUahTG;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f47.google.com (mail-wr1-f47.google.com [209.85.221.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 0437821873
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 15:54:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560786890;
	bh=aQEphLJjoGNsTWF7PUdVBXP9/NtJHbD77gDyFsJX9OY=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=qhOUahTGEyUHegfv4CFWy7tkV4dfGHY5ttlEqkwBP2tiXzGEfMzJPElZH2oeSSJA0
	 rsnYLYI8jLtjfOKiK5Ee2GKss2TnarwRGAOSUPGb+qZpd65W4APU5Itf6Ar+aac5xH
	 gguaXWWoFgjuokF/kcsWPV63ALSIUKuQ4QvaRPnU=
Received: by mail-wr1-f47.google.com with SMTP id n4so2465443wrs.3
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:54:49 -0700 (PDT)
X-Received: by 2002:a5d:6207:: with SMTP id y7mr55951191wru.265.1560786888514;
 Mon, 17 Jun 2019 08:54:48 -0700 (PDT)
MIME-Version: 1.0
References: <20190612170834.14855-1-mhillenb@amazon.de> <eecc856f-7f3f-ed11-3457-ea832351e963@intel.com>
 <A542C98B-486C-4849-9DAC-2355F0F89A20@amacapital.net> <alpine.DEB.2.21.1906141618000.1722@nanos.tec.linutronix.de>
 <58788f05-04c3-e71c-12c3-0123be55012c@amazon.com> <63b1b249-6bc7-ffd9-99db-d36dd3f1a962@intel.com>
In-Reply-To: <63b1b249-6bc7-ffd9-99db-d36dd3f1a962@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 17 Jun 2019 08:54:36 -0700
X-Gmail-Original-Message-ID: <CALCETrXph3Zg907kWTn6gAsZVsPbCB3A2XuNf0hy5Ez2jm2aNQ@mail.gmail.com>
Message-ID: <CALCETrXph3Zg907kWTn6gAsZVsPbCB3A2XuNf0hy5Ez2jm2aNQ@mail.gmail.com>
Subject: Re: [RFC 00/10] Process-local memory allocations for hiding KVM secrets
To: Dave Hansen <dave.hansen@intel.com>
Cc: Alexander Graf <graf@amazon.com>, Thomas Gleixner <tglx@linutronix.de>, 
	Marius Hillenbrand <mhillenb@amazon.de>, kvm list <kvm@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, 
	Alexander Graf <graf@amazon.de>, David Woodhouse <dwmw@amazon.co.uk>, 
	"the arch/x86 maintainers" <x86@kernel.org>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000015, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 8:50 AM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 6/17/19 12:38 AM, Alexander Graf wrote:
> >> Yes I know, but as a benefit we could get rid of all the GSBASE
> >> horrors in
> >> the entry code as we could just put the percpu space into the local PGD.
> >
> > Would that mean that with Meltdown affected CPUs we open speculation
> > attacks against the mmlocal memory from KVM user space?
>
> Not necessarily.  There would likely be a _set_ of local PGDs.  We could
> still have pair of PTI PGDs just like we do know, they'd just be a local
> PGD pair.
>

Unfortunately, this would mean that we need to sync twice as many
top-level entries when we context switch.

