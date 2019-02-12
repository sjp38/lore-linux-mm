Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4152FC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 07:20:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E32682184A
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 07:20:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iPelpcvb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E32682184A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7AA3C8E0013; Tue, 12 Feb 2019 02:20:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 75AAA8E0012; Tue, 12 Feb 2019 02:20:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 655828E0013; Tue, 12 Feb 2019 02:20:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0E8EF8E0012
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 02:20:40 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id w4so631576wrt.21
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 23:20:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=U64zTCXWDQ7iL31iPsF8RezMrqba1QJ9+7xpUmpn3AA=;
        b=i8pLjlBdalqPxE0ljgi79TsD+1dvirhRnTaK7m+hEUqxH0BCJ238yM0BsBWGvUbvJt
         iZgwUyz71liS0B1ndSCoUEdCu2awaSiDsBBw/FDalw49PTPiKO2zKnikUuT8MNKhnK5I
         LX+yVxhXOBl6Ai+x5oe5GDaCNUpVd2q23dK0PUrgoQwy04O6fCFvUNYJEdOTsj+qWLBC
         bX9GOEZJrooznuFelYOHJsE+tG4ult20AOc4txt8u29lHGYKZT9NV2HbMO52rqQeOCn7
         0YPseZlFwFt6t/jAuo8F4gunMwyeBdt1PlLFmugG9bZX4//cPJlmg4o7ZY4q6MPDqCmC
         5yCA==
X-Gm-Message-State: AHQUAuZtaIxE0dGroHNtT/WoQM6lXzFR29YsCmCxjtGcuTRxhMNY9J4j
	c1FeXNxjZCp4RqD+1jf7DXr9prKYeOMbd+GhgRxqRbQDt/2EpsjYOAw4wfd4Dqbetjrkn9yodcR
	TXnwmX+O8DfbYJalmUP5hYf3OWNraCx6Quc5qn9DHElSZNJXT5GcbN/1L6gg9NppQMX4XNMIPRt
	L4aiqvpQ9xrJNRuClLC4SWArbrutVcTeLddi8+bDM4COhs/Pyguo5dd4gpwh4sR7+3gZ/McY7Rb
	5LQIE7Yr5zB7ODpGrFrG/EUSWrrKiOlFhLQM5GG5skqI5PFxa+oJwPK7DegQ6B2UajQOsyJa0Uz
	RXrUD04E4q27YDzm3bs8fuzWKuJkoTrhVkSzpiXjQLNeoNJUbCglzXCGItRyXHJ/X0y67sPa9Js
	o
X-Received: by 2002:adf:f9cb:: with SMTP id w11mr1609328wrr.201.1549956039587;
        Mon, 11 Feb 2019 23:20:39 -0800 (PST)
X-Received: by 2002:adf:f9cb:: with SMTP id w11mr1609277wrr.201.1549956038842;
        Mon, 11 Feb 2019 23:20:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549956038; cv=none;
        d=google.com; s=arc-20160816;
        b=v0fE+7c3K4baMrQz6onrvGe63ix/vhF5EREdIBl5EUEPnwPUQfk7l3sZJSd/gxsZy5
         aoamYTT3f4L498KyWD30jEp9ToVDR66XXNMfdgLXmLUVqfF3rUG6k4dUWdpw1b22FmjA
         ev3wWNUnXVTqMtib6GSDoU1oEDj5Jsgeds469hxSnJwmY5txgcgNTKK3+I/deiWWB3KB
         OUoSaOE6R0YsSeTNakEbN/TR/dTH3eHmZeazqGAxxzH/Rwl/cgAEuULjddnKzr5nV3eS
         7EzOH/2aNltCFEvdC2syR+bst7lvciBD61p6yrbSebXt65PUHu4ad7/YrE6kzAuDADbJ
         8ZlA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=U64zTCXWDQ7iL31iPsF8RezMrqba1QJ9+7xpUmpn3AA=;
        b=wPufxqMYskTQrUHo+fwioPKsozv/D35+MlMorKdXfEYhvwLPDWhRIGNdtkeaXfT8Cu
         +Zas1dmurmfR3Zp45RsCykmN/PvUKTLNWOBE4J1q42tbEf9i+LKRnv/RsUU3ARU+KYlJ
         ebqIC+AVz0uLM+iWOx0MJzeraUv8LrUBrpOidVXR9gpmp1tYNRL2y0PEorFLqZeotubo
         h8D5Bf3fh9AMdjH5B93xFavdaWxpXH2cHMQ98RaVqidyzICmrq6pvj4B5SJ6TjHL/asx
         Ugug6M7wbiaR8uEgdQgql0JX3rmYm2mT8p0QQIHglkbrijRYqo26gZ4Mfj/Tv2dOd3u5
         k9ng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iPelpcvb;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l1sor4608635wrx.37.2019.02.11.23.20.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 23:20:38 -0800 (PST)
Received-SPF: pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iPelpcvb;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=U64zTCXWDQ7iL31iPsF8RezMrqba1QJ9+7xpUmpn3AA=;
        b=iPelpcvbRs7OVTfvAQIxw5jGMdR/imNfdBLMJWS+6cR3yNon0sbyKrc0uhM6WpfD9c
         c5cHKI8P5wDgVY4vrKyJqaK6fDS1QB8gKlxWyYTjnVQTBQoeC6DxrtTAi273NNAfgBY+
         BEAweeQJHwFJ9v0vvhIP1Xu6ypibp8nl4w2Kge0SvZtk6Ws3iu7a2at46rT85IXU7K1c
         OKDH1oMBrwTlJq2eh+IXg+JBI02lNZ9BJFW5c7s1f59bZghUBuTP8j49HNS+BnpkKIrD
         i+1pfV2ojGu3KMRUvbxIJD4/0kCwEjB5bi1/DqDEQGjkUJMeemLA5ZZC/eDXbMMsfKTN
         c1/A==
X-Google-Smtp-Source: AHgI3Ib1rteFIO7F0GUg3/O7a4JhOup1XgqAIL1t8DVD3QH5Hne7mwKWsjaC+uzVtJQT2Q3UmkphpA==
X-Received: by 2002:adf:f60d:: with SMTP id t13mr1601500wrp.225.1549956038339;
        Mon, 11 Feb 2019 23:20:38 -0800 (PST)
Received: from [172.20.11.181] (bba134067.alshamil.net.ae. [217.165.112.209])
        by smtp.gmail.com with ESMTPSA id a4sm1218794wmm.22.2019.02.11.23.20.35
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 23:20:37 -0800 (PST)
Subject: Re: [RFC PATCH v4 01/12] __wr_after_init: Core and default arch
To: Matthew Wilcox <willy@infradead.org>
Cc: Igor Stoppa <igor.stoppa@huawei.com>,
 Andy Lutomirski <luto@amacapital.net>, Nadav Amit <nadav.amit@gmail.com>,
 Peter Zijlstra <peterz@infradead.org>, Kees Cook <keescook@chromium.org>,
 Dave Hansen <dave.hansen@linux.intel.com>,
 Mimi Zohar <zohar@linux.vnet.ibm.com>,
 Thiago Jung Bauermann <bauerman@linux.ibm.com>,
 Ahmed Soliman <ahmedsoliman@mena.vt.edu>, linux-integrity@vger.kernel.org,
 kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <cover.1549927666.git.igor.stoppa@huawei.com>
 <9d03ef9d09446da2dd92c357aa39af6cd071d7c4.1549927666.git.igor.stoppa@huawei.com>
 <20190212023952.GK12668@bombadil.infradead.org>
From: Igor Stoppa <igor.stoppa@gmail.com>
Message-ID: <9ebd237c-c059-9219-8d11-7a708a1f80da@gmail.com>
Date: Tue, 12 Feb 2019 09:20:34 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190212023952.GK12668@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 12/02/2019 04:39, Matthew Wilcox wrote:
> On Tue, Feb 12, 2019 at 01:27:38AM +0200, Igor Stoppa wrote:
>> +#ifndef CONFIG_PRMEM
> [...]
>> +#else
>> +
>> +#include <linux/mm.h>
> 
> It's a mistake to do conditional includes like this.  That way you see
> include loops with some configs and not others.  Our headers are already
> so messy, better to just include mm.h unconditionally.
> 

ok

Can I still do the following, in prmem.c ?

#ifdef CONFIG_ARCH_HAS_PRMEM_HEADER
+#include <asm/prmem.h>
+#else
+
+struct wr_state {
+       struct mm_struct *prev;
+};
+
+#endif


It's still a conditional include, but it's in a C file, it shouldn't 
cause any chance of loops.

The alternative is that each arch supporting prmem must have a 
(probably) empty asm/prmem.h header.

I did some reasearch about telling the compiler to include a header only 
if it exists, but it doesn't seem to be a gcc feature.

--
igor

