Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70A41C43218
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 05:13:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 401162063F
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 05:13:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 401162063F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A48536B0008; Tue, 11 Jun 2019 01:13:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D2536B000A; Tue, 11 Jun 2019 01:13:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 872776B000C; Tue, 11 Jun 2019 01:13:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 37D416B0008
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 01:13:52 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id s7so18814110edb.19
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 22:13:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=DYCngMJLOK/2cJ+86BjE3TjH5m/AAcN6WZ8gmMI5TH8=;
        b=bI7ePWDWQ4z5qRCJR6M8RTjA9XpL/wVbMsN/OKdV571p2rM7F6WGIirqStmEW1ZIGl
         KC5D/7S4Z3pp7xEHLrb+MbsKY6dKRWmJUtEz/C7CBdWe2rJwqikfD/JQcw89HQXFz16z
         WRIDkSPWnCTJjv0ZahxG1S87vLbiQY4zqrpANLT1dvaWyEQ03hbu9CrX1ZYJ9uNATbCa
         g9GUS0Ce2k6/bgmAd/8sBvPMDrseJS0UErf9MNakYOpTfC0jV8B661MmysOED4slOSl7
         eXBEJdd/kYyoh3N8u6QQdarHrlzNG85PqIdZkSS9GdLDP7VaGtyoSVhEbqXZ5KXfDnTW
         nn3g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXqo3hQY/2rRnwU+qUzIm6Rw/rV8kzq0ZInryURtwhrfIsRmh3T
	rRJs3ZHhNhPNein7luiwr8XnJ8Pfdgzlar1DJJn1vYHyZFZJMyOPMHnPGAASR3bvZcv/pz13h/x
	rkygR7cYW6Z/invBvDQeO5ZY2wUXlZwCnCyyuG9sQmS5j/F9wWyKZIA8kzp3mEkfwIw==
X-Received: by 2002:a17:906:eb93:: with SMTP id mh19mr39718114ejb.42.1560230031744;
        Mon, 10 Jun 2019 22:13:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqys665I5mbfeEOiC6RxrP/waLBk7wmEd1B3hVtMPr3zMdm8mQJwiRz13KrRqPHymFdYdiI7
X-Received: by 2002:a17:906:eb93:: with SMTP id mh19mr39718073ejb.42.1560230030963;
        Mon, 10 Jun 2019 22:13:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560230030; cv=none;
        d=google.com; s=arc-20160816;
        b=wJcJJCmlrQxG3/QOvggXhHuIMNhphfa9cW+3MrwyZd/VdF/7/VdZvgqsfEuzUtGEl4
         iyStQZJny8qaoMBfYfupGE+MFuW7ee/0e+w8uJaos/njoxooe0gk9pP4xde2OMpxM7H/
         6B73CcaORayJuSOnb2Cmerns1vGmicBaBytb+24QR2iZyA98LECxXxsLerRZIGYzlocM
         zMVtxQoXG77zfiJs9wvAEpM0VPF7oaEBjgSEBS6M5SdYux8k3a6jAcONEWfw5UZBAio/
         evPPLpI4QLXvGmdo/gRbJ0ELjmkf8I5MXqgJCHMqV/LfCYoMKUaLlQU4Gk0QpcHOuuWT
         sQiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=DYCngMJLOK/2cJ+86BjE3TjH5m/AAcN6WZ8gmMI5TH8=;
        b=QJhpDsvdttOPP9jLWITjDRxC8UJk5UTtfawGVbplJFfyX48sMNIGa1uo33k4qHgqWX
         V2fOrTQCWg0OiIbhw68IWX0npkmvocrRpfStAjN4s95US5IUtbBC+/43tml3JT75E4ba
         PQ0hHLR2Z5q5mC9C2U350eLc64/TSHSrTTyLsWB0+0R9k7Pe6VEZ5Rv9kE2i2SzSJ/67
         1Sht3rAR3Jsh1HtCN1ybvFaMKIJfumICeqhMfzdOHkfd9XRWNCdE8A6VEOiZsQ0MEoe0
         n0Mskgl0iGx2zSGm5rPnDKXVWoA2CRfTNVNtXz9SO6ATA+LMBGhS2W/mGdnAj13ZmJ9B
         XQ3w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id w4si7674813eji.83.2019.06.10.22.13.50
        for <linux-mm@kvack.org>;
        Mon, 10 Jun 2019 22:13:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E9DC9344;
	Mon, 10 Jun 2019 22:13:49 -0700 (PDT)
Received: from [10.162.43.135] (p8cg001049571a15.blr.arm.com [10.162.43.135])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id F2A743F73C;
	Mon, 10 Jun 2019 22:13:41 -0700 (PDT)
Subject: Re: [RFC V3] mm: Generalize and rename notify_page_fault() as
 kprobe_page_fault()
To: Leonardo Bras <leonardo@linux.ibm.com>,
 Christophe Leroy <christophe.leroy@c-s.fr>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
Cc: Mark Rutland <mark.rutland@arm.com>, Michal Hocko <mhocko@suse.com>,
 linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>, Paul Mackerras
 <paulus@samba.org>, Matthew Wilcox <willy@infradead.org>,
 sparclinux@vger.kernel.org, linux-s390@vger.kernel.org,
 Yoshinori Sato <ysato@users.sourceforge.jp>, x86@kernel.org,
 Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>,
 Ingo Molnar <mingo@redhat.com>, Fenghua Yu <fenghua.yu@intel.com>,
 Stephen Rothwell <sfr@canb.auug.org.au>,
 Andrey Konovalov <andreyknvl@google.com>, Andy Lutomirski <luto@kernel.org>,
 Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org,
 Tony Luck <tony.luck@intel.com>, Martin Schwidefsky
 <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>,
 linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>
References: <1559903655-5609-1-git-send-email-anshuman.khandual@arm.com>
 <ec764ff4-f68a-fce5-ac1e-a4664e1123c7@c-s.fr>
 <97e9c9b3-89c8-d378-4730-841a900e6800@arm.com>
 <8dd6168592437378ff4a7c204e0f2962d002b44f.camel@linux.ibm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <7b0a7afd-2776-0d95-19c5-3e15959744eb@arm.com>
Date: Tue, 11 Jun 2019 10:44:00 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <8dd6168592437378ff4a7c204e0f2962d002b44f.camel@linux.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 06/10/2019 08:57 PM, Leonardo Bras wrote:
> On Mon, 2019-06-10 at 08:09 +0530, Anshuman Khandual wrote:
>>>> +    /*
>>>> +     * To be potentially processing a kprobe fault and to be allowed
>>>> +     * to call kprobe_running(), we have to be non-preemptible.
>>>> +     */
>>>> +    if (kprobes_built_in() && !preemptible() && !user_mode(regs)) {
>>>> +        if (kprobe_running() && kprobe_fault_handler(regs, trap))
>>>
>>> don't need an 'if A if B', can do 'if A && B'
>>
>> Which will make it a very lengthy condition check.
> 
> Well, is there any problem line-breaking the if condition?
> 
> if (A && B && C &&
>     D && E )
> 
> Also, if it's used only to decide the return value, maybe would be fine
> to do somethink like that:
> 
> return (A && B && C &&
>         D && E ); 

Got it. But as Dave and Matthew had pointed out earlier, the current x86
implementation has better readability. Hence will probably stick with it.

