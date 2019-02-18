Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2F81C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 14:20:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86F1A21901
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 14:20:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86F1A21901
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2CBD08E0005; Mon, 18 Feb 2019 09:20:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 278408E0002; Mon, 18 Feb 2019 09:20:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 140E88E0005; Mon, 18 Feb 2019 09:20:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id AB5908E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 09:20:33 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id d9so7207752edl.16
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 06:20:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=fYJnVxYaI8tzKr4MQExI2Hhm8BPHPiRQ3gkR7VBAd5I=;
        b=lsiaNjWPqTaCuuemWx4dMERDlkhO/yz1z0BIqTVb8aXaIky7yin0AO+5TLc2T7rUnP
         fNMz/1zJHouE8HtVz+hTs8TGIcGsCHBwBG1OttxaPHarOeDdYcmcvvL/FCAt8TtqxEHU
         qnQRAO7nkckcSJJ+VdeWZIu5ZHQ8UDorObYhWrfI7FemHWdWqhRAxYMz66I4Mp1nGjeg
         igm5Tv5Ad/4vnptnMXUrwxbtMTVsu1t8RWMx3URQrT0XvYX9IZzNvXUTSSQ3ObwJ1Nh4
         sP8VWsADcGLRvrSOFfkJlpq7qsFwkgP2f1o2b+Qp1nEN6Z0mK6TBFozV+k9Bd26DX1bQ
         OIlw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuYESc76nurb2+4s9oKcVOQnPEjB3WTgbTSmIt8niI11oxgiMQFt
	zBB4w6/cKa2Y4rUE4xnFevSYow7+haZVuhHIHvKg4tBm7E2SighzivntWeFrWNT4VhzEdlEE/fl
	lvBI5BRjs2q50YxSjZXXnz/c49pKdrNlCb1Z3Dls0D6uZaQ4xBpZ7mbYLTSsVhCvvvg==
X-Received: by 2002:a05:6402:12d4:: with SMTP id k20mr1967873edx.71.1550499633274;
        Mon, 18 Feb 2019 06:20:33 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZqyGU/C11I0RQYqxR+dcOqmaxjUF5IHjpz96ah/eb0JZdvW8C96J15cw1ToivniXJY6h4a
X-Received: by 2002:a05:6402:12d4:: with SMTP id k20mr1967832edx.71.1550499632648;
        Mon, 18 Feb 2019 06:20:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550499632; cv=none;
        d=google.com; s=arc-20160816;
        b=tSNtXU2Fk84lUISnCOG8xEiJPfziwqqiJGnTuIeIoAmdS6S6XoesbgBWfs3ahbxbBD
         rV10v/om16A5INBaQudFZK1Cd+Qg6YB/toLdIw9DHtBM4rKkqgjYTh0qfhOgH4r6mrw9
         G+x7bCpH8ai96b7lD3onPtbVnhXNctpGNNaco8ULhVDUWEmRKCqzuTukPZccjfQgSPYS
         bsweOHmR3uS8i6hYBCKte8teBlK0+4/vKiO8dkxD2C4VN4jIy6AVp7sJo/GTU3F1ejta
         vAQLElfCZ29g7UQPn0D0G43sW+Mflv26Xaqc55Jy4F+MMvmZooJi5IOL3OWy2NlIZaDV
         mAWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=fYJnVxYaI8tzKr4MQExI2Hhm8BPHPiRQ3gkR7VBAd5I=;
        b=AG+RYv8Io0r+YkRU0od1z9ogBMQMGciHBP3I7o3QVN8ktcQo/c0d14Tr955A0XPEN2
         TdAzPIVXobZ3sisANbMmvRfu/KvaDcpoeUdQwB7/x3Vk1a+tBvxuLjg+nE/06Q+9+/iD
         PAYAusq5p+vQywHBw7VAC5wqciDdvWD7iuP79Hyj/OglsWB2JXZ6DzhaKWEN9yJXnM3A
         NfoBtviL2Syf5Pux/2Vnl5Q4QXyKbKo4rOzX7EInDWBEJCR0msv3ZTFqCiq23GEJ+Oeh
         SnSPw5am2/09clw0eBVDcFHKn+s+IWPL84yKBCosx3PWDKWuQYPXBtCqabhCLuspvpSn
         jrnw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z29si1822110edm.182.2019.02.18.06.20.32
        for <linux-mm@kvack.org>;
        Mon, 18 Feb 2019 06:20:32 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B8AE015AD;
	Mon, 18 Feb 2019 06:20:28 -0800 (PST)
Received: from [10.1.196.69] (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E1C283F589;
	Mon, 18 Feb 2019 06:20:10 -0800 (PST)
Subject: Re: [PATCH 03/13] mm: Add generic p?d_large() macros
To: Peter Zijlstra <peterz@infradead.org>, Mark Rutland <Mark.Rutland@arm.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Catalin Marinas <Catalin.Marinas@arm.com>, "x86@kernel.org"
 <x86@kernel.org>, Will Deacon <Will.Deacon@arm.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>,
 "H. Peter Anvin" <hpa@zytor.com>, James Morse <James.Morse@arm.com>,
 Thomas Gleixner <tglx@linutronix.de>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
References: <20190215170235.23360-1-steven.price@arm.com>
 <20190215170235.23360-4-steven.price@arm.com>
 <20190218111421.GC8036@lakrids.cambridge.arm.com>
 <20190218125327.GT32494@hirez.programming.kicks-ass.net>
From: Steven Price <steven.price@arm.com>
Message-ID: <e877f289-ad3d-8b24-3602-89734aa328d5@arm.com>
Date: Mon, 18 Feb 2019 14:20:09 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190218125327.GT32494@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 18/02/2019 12:53, Peter Zijlstra wrote:
> On Mon, Feb 18, 2019 at 11:14:23AM +0000, Mark Rutland wrote:
>>> +#ifndef pgd_large
>>> +#define pgd_large(x)0
>>> +#endif
>>> +#ifndef pud_large
>>> +#define pud_large(x)0
>>> +#endif
>>> +#ifndef pmd_large
>>> +#define pmd_large(x)0
>>> +#endif
>>
>> It might be worth a comment defining the semantics of these, e.g. how
>> they differ from p?d_huge() and p?d_trans_huge().
> 
> Yes; I took it to mean any large page mapping, so it would explicitly
> include huge and thp.

Yes your interpretation is correct. I'll add a comment explaining the
semantics.

Thanks,

Steve

