Return-Path: <SRS0=1HZa=QY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49540C43381
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 08:34:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13C73218A1
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 08:34:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13C73218A1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A55D68E0003; Sun, 17 Feb 2019 03:34:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A044E8E0001; Sun, 17 Feb 2019 03:34:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8CDE58E0003; Sun, 17 Feb 2019 03:34:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5CDF68E0001
	for <linux-mm@kvack.org>; Sun, 17 Feb 2019 03:34:40 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id g81so2850014pfe.7
        for <linux-mm@kvack.org>; Sun, 17 Feb 2019 00:34:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=X6V94a/BrXX5nh4fCozOBtzpMFCIqnvf0UfEvRAcQdQ=;
        b=OrQtekGqFpTnKnnE2kLYn0RSGb4WPfXydzgmUyL5zY00At5JAnDUjroIUgh9WyK1IZ
         ZYktXk1MA1liGMxhwaCUlvKp+aRaVxx50iAbZs3f5OnI+nqeZj9aPnSUuqcMAhBw7E0U
         BwlKG+1tmXlB5c2Q46yuRbyu9XHn0kxbfBP+nLLo72Cz8oej/13Wh4jL21dnRg5tjraa
         3HpCfrrFaRT4OxYXnXnL8oZDFJYmGTEGDCqhz5fsN5E41qfj0LpkPjiRlUu8jKvyW85N
         W99BCcL9FUq1wAecfUAeQDv1oocr2ZrBvrniH4JB7FHknY2cCKp9c4nQUvhlNuNIif82
         QC8A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: AHQUAuY1UEjtM/iArTYDo6CJJBF8ACAFvPs+tYPpwu6P8gR48fA4clas
	/QC4BgnghySJCrUvP4L0C8a8N9d7nx+AAWPwM6no9o2aevedMKs3BuccMNRrm1uiXywnLf7e5Kp
	Sz2if8q2JZuDglWwqgIiRACCHp+60VO21rvGY8GPYC21dNi4Op5zYlmfyEPS/cYQ=
X-Received: by 2002:a17:902:6a4:: with SMTP id 33mr18756036plh.99.1550392480089;
        Sun, 17 Feb 2019 00:34:40 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ8TwRPTUausyu8gfFPP2bpHEhUWG/3xuOFzzdy5OVkTPK97i8qjOHxbYXG8M5kYkPSAnAL
X-Received: by 2002:a17:902:6a4:: with SMTP id 33mr18756004plh.99.1550392479545;
        Sun, 17 Feb 2019 00:34:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550392479; cv=none;
        d=google.com; s=arc-20160816;
        b=S89qRRcqxfT80nDJV9Os2HoB5QMLc8jsd7EJnfsz75dc9YRdz24FHv0AEXvY0CV0M0
         hf85QS5e/SMqhmuRvNQSUZnHjbnKIwUAvwn5zgMzSk9YUtEAB//gh6vUCXCkrLPURIIz
         381D/NT1PN9AKUVs9ks94GR1/oud88n2WZNBragUVrrtTmU/EYTXeSUEh4vAjdg460vf
         kF88dA/DmfeS+JV+oRNgObe+aQYvEX9/RdLBnbXJ9CBqStaF/9sCtrrkT1RPY0JoGvu+
         Nw64+ZAFmP+HHe9YeDRjvYsi3V5ZLPpav1gV74x7aChROffc9hZsgzJ0FOnnNvLid5u3
         iL2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=X6V94a/BrXX5nh4fCozOBtzpMFCIqnvf0UfEvRAcQdQ=;
        b=GOqYjQLRsYSe6+gSL8/xQbsPMgeyrFXLY321isOKnVJIjFnvrD3RlXjq7WCRTZlNNa
         i06k0owe6GiJWYQp+VcCfAumbkf4EhWlajhJ66yV4/H9oN8atgFaO27FnYhB7Z4e2v3W
         xqdsEYwWrjNKBoR7IfuPB7PjHSeGGWHYKZiQqQMSzC4W4tc7dDR16CzWIKqsQ/HALHbF
         yr7LGdPu+C9sfm+Q7kIO+ER6zo4datjTn+abPfkJxGcu5dAXzvoQBijzEu34HibCKRJy
         7+ztuEHw3fiAoPcT3EzKRkh99y9zZK3EMM3WQODmlQPJ7oeyYTg1fx8L2HTX9lM9T8dU
         3spA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id g63si2299965pgc.382.2019.02.17.00.34.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 17 Feb 2019 00:34:39 -0800 (PST)
Received-SPF: neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 442Kzx30D5z9sLw;
	Sun, 17 Feb 2019 19:34:37 +1100 (AEDT)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Segher Boessenkool <segher@kernel.crashing.org>, Balbir Singh <bsingharora@gmail.com>
Cc: erhard_f@mailbox.org, jack@suse.cz, linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aneesh.kumar@linux.vnet.ibm.com
Subject: Re: [PATCH] powerpc/64s: Fix possible corruption on big endian due to pgd/pud_present()
In-Reply-To: <20190216142206.GE14180@gate.crashing.org>
References: <20190214062339.7139-1-mpe@ellerman.id.au> <20190216105511.GA31125@350D> <20190216142206.GE14180@gate.crashing.org>
Date: Sun, 17 Feb 2019 19:34:36 +1100
Message-ID: <87bm3add9f.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Segher Boessenkool <segher@kernel.crashing.org> writes:

> Hi all,
>
> On Sat, Feb 16, 2019 at 09:55:11PM +1100, Balbir Singh wrote:
>> On Thu, Feb 14, 2019 at 05:23:39PM +1100, Michael Ellerman wrote:
>> > In v4.20 we changed our pgd/pud_present() to check for _PAGE_PRESENT
>> > rather than just checking that the value is non-zero, e.g.:
>> > 
>> >   static inline int pgd_present(pgd_t pgd)
>> >   {
>> >  -       return !pgd_none(pgd);
>> >  +       return (pgd_raw(pgd) & cpu_to_be64(_PAGE_PRESENT));
>> >   }
>> > 
>> > Unfortunately this is broken on big endian, as the result of the
>> > bitwise && is truncated to int, which is always zero because
>
> (Bitwise "&" of course).

Thanks, I fixed that up.

cheers

