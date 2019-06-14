Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC26AC31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 12:22:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B064E20850
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 12:22:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B064E20850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5AD946B000A; Fri, 14 Jun 2019 08:22:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5846C6B000D; Fri, 14 Jun 2019 08:22:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 454836B000E; Fri, 14 Jun 2019 08:22:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id EC4E46B000A
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 08:22:56 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id b1so471501wme.3
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 05:22:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=xnIo4846sNVEoZ3693soibpfE17aMAAOJqurHgrpruM=;
        b=hrRX+4b+sqC8TPULs65RrdZ6JOZ4tVukp2Ze8MmxOIJ+bTc0GfHRxs9yUW9wHkd2+m
         te1Xjs5rL7dR/DYdHxrx3ksOq90hUKcMGafTJaABiz+4ckVcT1kdYmU1+G+CJ6EB9agD
         aZTX4mvug/vMt61RZ6ljRjCj7YpZNro0MGw+76mDHrBZgd2cnAdoyvZbZZSAL8WkClrf
         SJEIIdzvKVAdgqwuzx3S8K2nwrGnbU3Aala4exhKgfa04AUZiwWSzsCJHEIIbXV7BYAv
         6YQkbws3fSlnllnnFnP6hcs1vOes9W8ZxtLEkB+8A/u1tDofP0XWQjwTmCYA5U0USu+C
         sFVQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAWgpPZAEiT/ubdpgqwd82kg47em+RtArX+gTT5vdoBddPd1wOvL
	Jtp1rzb2UbWnvyIRrTQj296Huo5Myj0TsWImIEm5/mmLpVISb+mx4MnCK+wfcy9AKNWVUFLOG6t
	9NauKpRyQMJv7Y1JdHDkjK5dxb183nuYNkepxbUTH0rn6nYyvvUaop9YrOspn8H4hAA==
X-Received: by 2002:a5d:6b52:: with SMTP id x18mr41015001wrw.341.1560514976496;
        Fri, 14 Jun 2019 05:22:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz6nLH0FHrS9UdzA3MsOLL/9Ff7R/+NeHGyOLBv+vxU5ffnavIgB0sGRckRQvZ9SLLy9Ful
X-Received: by 2002:a5d:6b52:: with SMTP id x18mr41014967wrw.341.1560514975773;
        Fri, 14 Jun 2019 05:22:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560514975; cv=none;
        d=google.com; s=arc-20160816;
        b=ykoAaPKH5/ESwTOtTkVb49us+3VQVD0d8b7qGfXmS43F8erHhdpaFshpTD9QXdDHY5
         e6hwO9Sk9THqSgET2BcQvvDvIK3aKpa8FxBDeVyJvoAabhGyUk1zE/aTMXTHWtmN2Boj
         N8EwN6s6bwf7RBFjHRQzp8C7NWge5+XCF+k+cVq3QiG89DsWAiFloX02df5T/G6qsZ9N
         w3GSWWKT4w1iu8a2i+IzhQZY1GUq7f5y/WPKfDjrk7ivrFO6kWen+ijTHh/56JrBe7gO
         Y8N97nAwSexPfC3TgUmWNOi7sBoswaDP1nbsJRTXuMyUibWUDGfdx6VOg0YzTPtuctp9
         BNTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=xnIo4846sNVEoZ3693soibpfE17aMAAOJqurHgrpruM=;
        b=PNfS6WkevLpoweMTru7QDDX0r1zazjNaiEPgCJlhzynXJw0nMR+7+h2cMwP0N+vXXX
         kt+lIKChjsL+PaZCUM8Fc2hlHc2UbKjCaQbUQoGzJvZOwtaTgyUqURb8CMAY688kzgzN
         RmAnADS4gtIm31uybVO40t9th/9PnYsnYE07xmmFyt9NlmgPYXvkaVQEPAHLAoTbDZX3
         5EVpf1nXuOYMh/00OkYQDM95kZ2NilYyetCUzJXCGXUyKgNdUBK56yllvP0vfp6gYoGk
         I8X1yYhrPlaYJpu/BD68tRzHtoqIb6foAAIUnsrAoopNt2cn20SdbVggk4DmOMJClCpC
         LT6g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id o6si2489672wre.118.2019.06.14.05.22.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 14 Jun 2019 05:22:55 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from [5.158.153.52] (helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hblEL-0002pf-BB; Fri, 14 Jun 2019 14:22:53 +0200
Date: Fri, 14 Jun 2019 14:22:52 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Anshuman Khandual <anshuman.khandual@arm.com>
cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
    akpm@linux-foundation.org, Catalin Marinas <catalin.marinas@arm.com>, 
    Will Deacon <will.deacon@arm.com>, 
    Dave Hansen <dave.hansen@linux.intel.com>, 
    Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, 
    Ingo Molnar <mingo@redhat.com>, 
    "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
    Michal Hocko <mhocko@kernel.org>, linux-arm-kernel@lists.infradead.org, 
    x86@kernel.org
Subject: Re: [PATCH] mm/ioremap: Probe platform for p4d huge map support
In-Reply-To: <1560406781-14253-1-git-send-email-anshuman.khandual@arm.com>
Message-ID: <alpine.DEB.2.21.1906141422370.1722@nanos.tec.linutronix.de>
References: <1560406781-14253-1-git-send-email-anshuman.khandual@arm.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 13 Jun 2019, Anshuman Khandual wrote:

> Finishing up what the commit c2febafc67734a ("mm: convert generic code to
> 5-level paging") started out while levelling up P4D huge mapping support
> at par with PUD and PMD. A new arch call back arch_ioremap_p4d_supported()
> is being added which just maintains status quo (P4D huge map not supported)
> on x86 and arm64.
> 
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: x86@kernel.org
> 
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>

Acked-by: Thomas Gleixner <tglx@linutronix.de>

