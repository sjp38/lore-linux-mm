Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52750C41514
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 06:10:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EABB520828
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 06:10:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EABB520828
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85DE28E003A; Thu, 25 Jul 2019 02:10:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 80D648E0031; Thu, 25 Jul 2019 02:10:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D6718E003A; Thu, 25 Jul 2019 02:10:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 35BB58E0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 02:10:11 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so31503045eds.14
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 23:10:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=SpfYKVuGdLl4C0td4aBNl9rimK912E6CtJfOiMxTN48=;
        b=fvDQMkzC0ofY/gIo1X5TweJ9yHZtZofxNXhStkHa4psj3LKZKMMs6AgOZ90EVFIKAx
         QeeXHXwJo3xkh0wcOm5QIpKlNe37IM4fKvtL+J/WL4J7oWX53bvINir/xvjZn3Bw3R6x
         CRFVVzXgPetBUOAwM2LChJWvV3+QBWtU0DP/x4Ps1zDyigatpilwnXKpJVmCrMfAWVk+
         hUcHoAAqu2YmPPMURExb7m9PoZsBRn2aFeHbGl1i47uqk5jL0ltGavuqV+T8UBk0a01/
         WCdEZq2CylzLAhDHvRypmMuYqsKWxPIF6ZnWNFBE26H6YNPnsDemv/YJp8hX/IdCUCra
         RVBg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAWgQ4Fu7Fe85ZwmPHI6KZP9nnx3AyfITjDd+TjoXLbqrfR/4MNf
	LyLNdpwNitS4RWbl69ukd4816Krkd23fGInTzyMPVAYDyqDpzAnQVQ6UwFmkVaxndo3ZGqK7gN6
	bFvUeW7AxNt1qHuia2+hRurl5BlhxyehtEoMTFWFf/oy3rkRvrGxD9MF7zjF8vNI=
X-Received: by 2002:aa7:dd09:: with SMTP id i9mr76548042edv.193.1564035010782;
        Wed, 24 Jul 2019 23:10:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwOtWw4CQk10QG3kqbvmnVVHm99hfcJpCAliLTHcJzlpS22IwulTlZurQZcdwPt7NE6/AiU
X-Received: by 2002:aa7:dd09:: with SMTP id i9mr76547996edv.193.1564035010131;
        Wed, 24 Jul 2019 23:10:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564035010; cv=none;
        d=google.com; s=arc-20160816;
        b=XZCcIaGEMekZfpxbZFXgG6btywHXlqEPYgiE031QYjWIHjD7scVOdYj9tl+okRmPjL
         z04fsARU+v4W3I3vJP/9aNc3jlDS5uOG9vQxOk2UW1HpYXv+sP+mgOAIgv6yVccTZ3HO
         ainF5kNT98zprv0N7V2gvpWo++KJNU/dZUiI6nbPJXJvpIdHcKc9PeXf3vFb7yNKVB+V
         9FhpGRfvIepzTQr41NrD5lr/TyEALt15PwsHdbNpL7Abj1wrGmYBL+SY2hWKNi4rt1s9
         KcJh66hCOO8Kc3SuyACWIU/fNcuZZPZ/SVGA4hIuPl94EacpyqPve9E66JcTEZn5v0ZI
         rchw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=SpfYKVuGdLl4C0td4aBNl9rimK912E6CtJfOiMxTN48=;
        b=arrIXKzKIPdoadNS0vHX4yw0k9xukLBVlmMC7cy7JMZ3d9qVJ3+wr5GVBlzX/WMJFz
         TeYv4zyos4sjUxXkTnnBIK0V0blMcsaXyrxcqxjMURsyyt6lIBwqq6Nm3he7AQJUg6He
         BOHDYHN+mn0BHHEfIk2RHoDO1yZR+YGAhvc/v1SQwCQnSruZauvKsCx/K37Wi9xp0umZ
         IIEJgyZEQDobXkRu/p1UfS77bzNhv1TaddiwnAq1yxWRiIYnMtqLaiIV3HX1rHVwKoCT
         zuwTpb7uYj066xWiWFkmu2C1RKhHxO5sngZTgbB8mUA4ApPojx6orLdOXn+oM9QKjDSY
         sllg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [217.70.183.195])
        by mx.google.com with ESMTPS id si2si9360743ejb.335.2019.07.24.23.10.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Jul 2019 23:10:10 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.195;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 81.250.144.103
Received: from [10.30.1.20] (lneuilly-657-1-5-103.w81-250.abo.wanadoo.fr [81.250.144.103])
	(Authenticated sender: alex@ghiti.fr)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id D99C260004;
	Thu, 25 Jul 2019 06:10:06 +0000 (UTC)
Subject: Re: [PATCH REBASE v4 00/14] Provide generic top-down mmap layout
 functions
To: Luis Chamberlain <mcgrof@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig
 <hch@lst.de>, Russell King <linux@armlinux.org.uk>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>,
 Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
 Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>,
 Alexander Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-mips@vger.kernel.org, linux-riscv@lists.infradead.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
References: <20190724055850.6232-1-alex@ghiti.fr>
 <20190724171745.GX19023@42.do-not-panic.com>
From: Alexandre Ghiti <alex@ghiti.fr>
Message-ID: <c7a35023-8571-6000-d870-12803314adbf@ghiti.fr>
Date: Thu, 25 Jul 2019 08:10:06 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190724171745.GX19023@42.do-not-panic.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: fr
X-Bogosity: Ham, tests=bogofilter, spamicity=0.253215, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/24/19 7:17 PM, Luis Chamberlain wrote:
> Other than the two comments:
>
> Reviewed-by: Luis Chamberlain <mcgrof@kernel.org>


Thanks for your time Luis,

Alex


>
>    Luis
>

