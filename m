Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9299C10F14
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:15:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A66452077C
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:15:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="Tc8Fq89c"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A66452077C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BC136B0003; Tue, 16 Apr 2019 09:15:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 345D36B0006; Tue, 16 Apr 2019 09:15:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E9D96B0007; Tue, 16 Apr 2019 09:15:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id C0C806B0003
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:15:57 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id h14so18901870wrr.22
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 06:15:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=zVxj07jVogt5Hk1WdJjXggizYLQPKdX0WopBNEyREwk=;
        b=Uot13T5C6c2Cg1QcIAEjdppREAcPJZCFOYWZEERiU12EKL5o8p5UsUIslzztYquwbm
         6LditVfgWqPUuUpy4lxZ5VCJ0OIV0rJ1Zxl5rCcW+xA7y6sxKKBP7yXGriQE4UE11e3a
         l3ltNoU2hb95X3xLm/YcpClvbTAlQMFqau2K1f9ciHglKjWeuQD/gigmrrMdSWLpNQpl
         t1mQObsA5l6ueP2BVcGNwwb0F4bR61Hizb5Xpdg6HHLIkCVt4/3GgTjUwHgJ5xqlTqWI
         OlFeLl54s/gKINkn++bkeSZBPVgQ03LZPtz3b5kNPymcDdw8mpEvg6e6O42tY/qtCPHW
         5HxA==
X-Gm-Message-State: APjAAAXQFDkRGvO5wKWIDUF7gKg2JFxMmchmXeMpyGN0A7wFYfhWAQBH
	oR2ztU4yA9vPttcKkMqa00bcYn9Ef867ln6uFCSC4CO9LNCVYWaSyzsiFc0o6/reTRc/z3IfdKE
	OydbMXtrwsFay3XdsnqeSo9ihRN3720j+HKSm+EqaEkjHkU/+WueCs5kbnx4ATmgfqw==
X-Received: by 2002:a5d:4843:: with SMTP id n3mr48171826wrs.256.1555420557239;
        Tue, 16 Apr 2019 06:15:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzc9cBh0237jzTygc4a5mLQeIIk+ppXt56JetvdM4bj1Fr6TMCk7X2qM6mcYlx2Hi6gOdo2
X-Received: by 2002:a5d:4843:: with SMTP id n3mr48171658wrs.256.1555420554776;
        Tue, 16 Apr 2019 06:15:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555420554; cv=none;
        d=google.com; s=arc-20160816;
        b=XBJ8rBH/R6hEtRGSuoneM4xnmOWEgALMKJPM+ELMgoegVGcsdXKxXFe5VQai98vnUE
         PciCtdyi9f2Do7VoRqms12BK1JwCq24LcvrOhWgxgaZ09UD404oqjw/QWWxS666w2jYI
         z/P0a2U0HrvmN+3f2VBRAtjDjPyeeidHFRb7Bno0Vw5tLdDq15vde1tP6ZXUf8TxlLus
         v1yHBoBnKW36Q0TAxvSsVeg/AwAcDIQCDEaKJWViUyL3DxT25eUXSauoMfd1pzZ8p77l
         0pOa4RXeu7m4tWsKRwwTX5QnuXs8/4deGh3jGGA/46LsNwFLOTPd0zFnfz6wF6D7UUJd
         Xbjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=zVxj07jVogt5Hk1WdJjXggizYLQPKdX0WopBNEyREwk=;
        b=TUImGuBXmaoC303Mbl530TOXvvlUCx33C9/yIYAIL5BgM4AZuCKsNH25ZHtW1yyRpH
         I2xZFbf3fr0dEnjiHvt/oPgKbaz7aKl8/411vbwNaR3SEa6cPNWboSWtiFSSuKsfNhoH
         NkKL//6UIaWn4suau3NPhneaLjvLvqzJxBhocnkCHBznxBPEMEN5zbzt774084jXdlkQ
         62wlFBPrL6iXoaX/xGMKZ8jVNsUjcm4EknpWEKb15WMZUaGP2Q0wTn6Rqm8FeL98GJ4i
         FL5TVvc7FYgPln/Y5y5CqOVRfJcCt78rqsiGYRMVI5buzg9av2CeOrM+mveYvXQ4Bwpe
         FJww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=Tc8Fq89c;
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id y4si36530268wrt.288.2019.04.16.06.15.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:15:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) client-ip=5.9.137.197;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=Tc8Fq89c;
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (p200300EC2F0D690030B3A6530520175E.dip0.t-ipconnect.de [IPv6:2003:ec:2f0d:6900:30b3:a653:520:175e])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id 7E99E1EC02AE;
	Tue, 16 Apr 2019 15:15:53 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1555420553;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=zVxj07jVogt5Hk1WdJjXggizYLQPKdX0WopBNEyREwk=;
	b=Tc8Fq89c2kKkDqJVu4BY0Ifsa95BRIITsZfaZkdqCzcnsH3dSJ4SkYx++cGCZ+pnNLyRpu
	0O6TWxaxsWShIm9opg3Cike6nCrbQGw/Tqe2oowyUgVxh5L9HFwhcIfXFcmdXzYj4mKs20
	UadxgI1pAvsAI21kKttt1qdso1QhDCg=
Date: Tue, 16 Apr 2019 15:15:49 +0200
From: Borislav Petkov <bp@alien8.de>
To: Chen Zhou <chenzhou10@huawei.com>
Cc: tglx@linutronix.de, mingo@redhat.com, ebiederm@xmission.com,
	rppt@linux.ibm.com, catalin.marinas@arm.com, will.deacon@arm.com,
	akpm@linux-foundation.org, ard.biesheuvel@linaro.org,
	horms@verge.net.au, takahiro.akashi@linaro.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	kexec@lists.infradead.org, linux-mm@kvack.org,
	wangkefeng.wang@huawei.com
Subject: Re: [RESEND PATCH v5 0/4] support reserving crashkernel above 4G on
 arm64 kdump
Message-ID: <20190416131549.GD31772@zn.tnic>
References: <20190416113519.90507-1-chenzhou10@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190416113519.90507-1-chenzhou10@huawei.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 07:35:15PM +0800, Chen Zhou wrote:
> When crashkernel is reserved above 4G in memory, kernel should reserve
> some amount of low memory for swiotlb and some DMA buffers. So there may
> be two crash kernel regions, one is below 4G, the other is above 4G.
> 
> Crash dump kernel reads more than one crash kernel regions via a dtb
> property under node /chosen,
> linux,usable-memory-range = <BASE1 SIZE1 [BASE2 SIZE2]>.

Can you please not flood everyone with this patchset every day, and
today twice?

This is not the frequency with how you send patchsets upstream. See

https://www.kernel.org/doc/html/latest/process/submitting-patches.html#don-t-get-discouraged-or-impatient

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

