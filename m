Return-Path: <SRS0=SJ39=PZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D839DC43387
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 21:57:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 727CC20859
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 21:57:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 727CC20859
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB32C8E000F; Thu, 17 Jan 2019 16:57:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C635B8E0002; Thu, 17 Jan 2019 16:57:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B525E8E000F; Thu, 17 Jan 2019 16:57:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8EAD48E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 16:57:22 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id z6so10408132qtj.21
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 13:57:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=yID1VjSwUJ3rwmXIhP+rRft52nSsW6OpmvtouVrsmbc=;
        b=cdDXqHiIsTCiweQWED/50kStf2xrnM4Ov3BoThLyjMdmOVpR0XPrPYpmiWEgow2Xlt
         bpsEI/dGGq/DuY90X8lvvy0PVXzQs2UaYlz5NOvUhDp78wfg9RnTCR1zLmQr2eLtrgmf
         CEeYJSypgKy5ye35/sSK4BBIVk+ZYASVfZE9JvmfljVT1j7D5vtD09xtCCjSmMpTlCLE
         idmBP0+rro95dzFa7ii6CakUlBgT3CVHprkarqywDS2nhPIS4n0rUALGPxPlasTAbSrb
         iNmeOzJHj8l3cCp3WJW7CNK/lJVl9jTli30h4kRMUlcbih+tEKxz2E+X37ipQgj4F8NG
         KKfw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jmoyer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukeeBEzDH8K7RV/Yqhk1bJoaxbELjwHEln17K6iyQvRV5tei0U/X
	DixEDM38XckCdyDId/XW1YZSUJBnOZSbe6MHy6bCkOF8j/fMvwjIYWWkUktzK7ZOFxpNfS9vMnl
	VCNuTsTfl86BrQSp8CAxbP8OM9SWMq3bmLBLzL2exd3KpEEp5SgTWfXzPWtmBu9mPmg==
X-Received: by 2002:ad4:5307:: with SMTP id y7mr13328269qvr.9.1547762242322;
        Thu, 17 Jan 2019 13:57:22 -0800 (PST)
X-Google-Smtp-Source: ALg8bN60jnZobReSLENe5EhLQUZm0FAPZTquI66EQB0eawGLfvXNvpZYYsiQS/84fGHyJfUvFGkU
X-Received: by 2002:ad4:5307:: with SMTP id y7mr13328239qvr.9.1547762241767;
        Thu, 17 Jan 2019 13:57:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547762241; cv=none;
        d=google.com; s=arc-20160816;
        b=OUSZVz1EnhDc6R0yVJ9CBHEw9pBjXDXAaf/Byq5q8HUtvU/mk4tw/ItLzk0ztkA4pz
         BPh/ms5Gz/AnulHjkXXxP1ffeklOZr5dW3j4jSi9JHqj1kyuF01JssepbaOvKX2/q1s9
         gpR0/bJx8VJNOdyO94pTW2YqFnfMyDR7qEHmb9+oQLbm05oElADZVdrCoul7/5fYYGNE
         gNCoenKA48/3HkjeLRkWTPodO/zbBQZ09o9zz0nYjKcpNKgTfJxtXuNafw2sOc9wyjg3
         noMCf+VLV90MS5IKwQwGYrLisiYs3T1SLfynqcUOE1WaG68CF3IUV/U3lITvQ4FdhUNC
         htKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=yID1VjSwUJ3rwmXIhP+rRft52nSsW6OpmvtouVrsmbc=;
        b=kX+fB+i9JhV9CnuspqhdvAKpihMrsW0MYFZVpben3b7I+tX0aTyriawK4EMJ7SYTFp
         DnnfII9s5ZbCcMJCPIfoOuHGT4pg4r24ggUGpe4FwS8fK1cIkHCEM58ZfdzLuxs8sbI3
         PBnlUGBWhoiBan3l05aJrxXO+MlsT/n26XOgOfAL+yJw44Jkk9NnWLs3grjsMHwRdTe1
         xZ8bW8+w//c2vcwS2UvYR19/9h0fHGLDinO1SvpKEkVwfynsgo/oBsk75saX1ZkgpctS
         pRe0yz9cXE91GEhFLvtmVV2/JtYT7nwov6DgU/cFQB4m0KXsSUClc8w516o895YfbMMz
         qSaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jmoyer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a123si6317145qkd.182.2019.01.17.13.57.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 13:57:21 -0800 (PST)
Received-SPF: pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jmoyer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A727AA7875;
	Thu, 17 Jan 2019 21:57:20 +0000 (UTC)
Received: from segfault.boston.devel.redhat.com (segfault.boston.devel.redhat.com [10.19.60.26])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id BDA6061B6C;
	Thu, 17 Jan 2019 21:57:18 +0000 (UTC)
From: Jeff Moyer <jmoyer@redhat.com>
To: Keith Busch <keith.busch@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>,  thomas.lendacky@amd.com,  fengguang.wu@intel.com,  dave@sr71.net,  linux-nvdimm@lists.01.org,  tiwai@suse.de,  zwisler@kernel.org,  linux-kernel@vger.kernel.org,  linux-mm@kvack.org,  mhocko@suse.com,  baiyaowei@cmss.chinamobile.com,  ying.huang@intel.com,  bhelgaas@google.com,  akpm@linux-foundation.org,  bp@suse.de
Subject: Re: [PATCH 0/4] Allow persistent memory to be used like normal RAM
References: <20190116181859.D1504459@viggo.jf.intel.com>
	<x49sgxr9rjd.fsf@segfault.boston.devel.redhat.com>
	<20190117164736.GC31543@localhost.localdomain>
	<x49pnsv8am1.fsf@segfault.boston.devel.redhat.com>
	<20190117193403.GD31543@localhost.localdomain>
X-PGP-KeyID: 1F78E1B4
X-PGP-CertKey: F6FE 280D 8293 F72C 65FD  5A58 1FF8 A7CA 1F78 E1B4
Date: Thu, 17 Jan 2019 16:57:17 -0500
In-Reply-To: <20190117193403.GD31543@localhost.localdomain> (Keith Busch's
	message of "Thu, 17 Jan 2019 12:34:03 -0700")
Message-ID: <x49ef9b6j7m.fsf@segfault.boston.devel.redhat.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Thu, 17 Jan 2019 21:57:21 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190117215717.FuuGcw_btVIeNzf95gs4WLztDQOV1JMcwjqINQBisvg@z>

Keith Busch <keith.busch@intel.com> writes:

>> Keith, you seem to be implying that there are platforms that won't
>> support memory mode.  Do you also have some insight into how customers
>> want to use this, beyond my speculation?  It's really frustrating to see
>> patch sets like this go by without any real use cases provided.
>
> Right, most NFIT reporting platforms today don't have memory mode, and
> the kernel currently only supports the persistent DAX mode with these.
> This series adds another option for those platforms.

All NFIT reporting platforms today are shipping NVDIMM-Ns, where it
makes absolutely no sense to use them as regular DRAM.  I don't think
that's a good argument to make.

> I think numactl as you mentioned is the first consideration for how
> customers may make use. Dave or Dan might have other use cases in mind.

Well, it sure looks like this took a lot of work, so I thought there
were known use cases or users asking for this functionality.

Cheers,
Jeff

