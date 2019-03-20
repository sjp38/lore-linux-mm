Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61F98C10F05
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 13:15:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2CA99218A3
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 13:15:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2CA99218A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BEDC26B0003; Wed, 20 Mar 2019 09:15:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B9CB76B0006; Wed, 20 Mar 2019 09:15:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB20E6B0007; Wed, 20 Mar 2019 09:15:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 719D16B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 09:15:52 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id n63so2502201pfb.14
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 06:15:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=thy2UiHUnnzNgLoQsneEwMKWmpJu/mKXXBgbSfaWZCY=;
        b=XTr/44bu3zjnGelYKFm5iNcY56nwUFDeoJsv+uvw168ccurabotE3SFOZ1lfuY8gr+
         lkf+Wd8G9se6duGtrnxi+p8lWhXYJf6HjQzzl/jJYJjkGN+UxnUqDatuQ3x0NHhzyiJZ
         pSLzissA/LF1F3Q/d3Wka7G49cf0ryETaIv+2P9YT2tnhlLUIK0fxEq8ACWSRRygOjgU
         dCwOWg8uNmHyCcIub/Pvmzq+iUCWQxHPJvJ9jfsuo02kHMcGQ7vMLv342kC0izvVcUdI
         gfRP7Rlk9NbXlgRLKyRMC1AXdXi5EJBklR6BHTqItDm+lITkgftfnhKz6M4Xir9aT1m4
         K/bA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: APjAAAUx4WGql2t7fE6fKjwXObXTvqPIXAD4QAP3uDRUr8HlH584cMST
	hvG6Q9lbSC6kuxKMDiPZcRisgyTac/OkhDDcCgWeNFrx27szFZR8uljfC0NcYP/PNFkka54uUhV
	kBCNn3sobsLuAp4+D/ZyqgGBCQNFGVNTMv0JBROADMeXC+aznsrFsn5NVVNZtW88=
X-Received: by 2002:a62:4e8e:: with SMTP id c136mr7670820pfb.254.1553087752024;
        Wed, 20 Mar 2019 06:15:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy7OAfquNZsnf2TBNggUm2XxWrM4vIwiwbvZhVDRHpxA7jhtFgfG7aUqIJVJ4mBJ3Vj5F0Y
X-Received: by 2002:a62:4e8e:: with SMTP id c136mr7670756pfb.254.1553087751204;
        Wed, 20 Mar 2019 06:15:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553087751; cv=none;
        d=google.com; s=arc-20160816;
        b=Dy0fj4saxJ9CvB7Wg1xb6LSSWPJqrCh7Rixp6wmQcnPZtQ/Cbqg4pjaROLMF2kB99f
         E83hKP+tVRXazguJLeodDsX6FPQ0Sg1xIpSWf3Ent8I35PaoS1QkcMLri++gIi4EatWA
         JKWicyQdwjgxXyQexbgJFBKpiyr0LsLcgvBrpS6DIWlboQd59cdhn0az41lyDdP+jB41
         N01jgZSu7OTCJldZyW2UgRKXXpVnKBmkfktgvfgemRh/SDYbC90d75lnmnOTaOSFXB40
         c8IZk8N8nrOtlxN2Rt82sjUOdYzOg7X/yaTWDRT2ZaiEvmVSHb9VD/NqWXl6Vgc0Ech8
         p2qg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=thy2UiHUnnzNgLoQsneEwMKWmpJu/mKXXBgbSfaWZCY=;
        b=ISc3HjMPPpKuuMXRPG1bc/fgGYXZhiBbAD6rxmTnbJ7TLruooAPoLWDgTRgxexhdhU
         h+fVyl3dOp3j8ZXc22IrEqqT6OOp8n9DNmIovTvFkLyUuAqbg3nJ+z0PDaI1csVRiO5V
         y5vRMOIFKVc4oFvtIygLhIQ3sfCR8Voy0KmkZENdqtY9uGVkiGMyO9ru/sPq5TF0S+on
         4tjoBG1JhaH2j8V5tjxYIkOk4fmrBZgfSb88/VIDYssXlKT7zPx0z5B9Oxmy1pR1LVer
         P6fs8n2JUuMaD/TyEmZ+jYSIKpNQ7OC7JWiEeF9VXqWU94Ygqm5xJUN/FK48Lj3uxvnB
         B3tQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id j8si1591360pgq.542.2019.03.20.06.15.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Mar 2019 06:15:51 -0700 (PDT)
Received-SPF: neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 44PVm43NQyz9sNG;
	Thu, 21 Mar 2019 00:15:48 +1100 (AEDT)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Catalin Marinas <catalin.marinas@arm.com>, Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, paulus@ozlabs.org, benh@kernel.crashing.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Subject: Re: [PATCH v2] kmemleak: skip scanning holes in the .bss section
In-Reply-To: <20190319115747.GB59586@arrakis.emea.arm.com>
References: <20190313145717.46369-1-cai@lca.pw> <20190319115747.GB59586@arrakis.emea.arm.com>
Date: Thu, 21 Mar 2019 00:15:46 +1100
Message-ID: <87lg19y9dp.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000005, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Catalin Marinas <catalin.marinas@arm.com> writes:
> Hi Qian,
>
> On Wed, Mar 13, 2019 at 10:57:17AM -0400, Qian Cai wrote:
>> @@ -1531,7 +1547,14 @@ static void kmemleak_scan(void)
>>  
>>  	/* data/bss scanning */
>>  	scan_large_block(_sdata, _edata);
>> -	scan_large_block(__bss_start, __bss_stop);
>> +
>> +	if (bss_hole_start) {
>> +		scan_large_block(__bss_start, bss_hole_start);
>> +		scan_large_block(bss_hole_stop, __bss_stop);
>> +	} else {
>> +		scan_large_block(__bss_start, __bss_stop);
>> +	}
>> +
>>  	scan_large_block(__start_ro_after_init, __end_ro_after_init);
>
> I'm not a fan of this approach but I couldn't come up with anything
> better. I was hoping we could check for PageReserved() in scan_block()
> but on arm64 it ends up not scanning the .bss at all.
>
> Until another user appears, I'm ok with this patch.
>
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>

I actually would like to rework this kvm_tmp thing to not be in bss at
all. It's a bit of a hack and is incompatible with strict RWX.

If we size it a bit more conservatively we can hopefully just reserve
some space in the text section for it.

I'm not going to have time to work on that immediately though, so if
people want this fixed now then this patch could go in as a temporary
solution.

cheers

