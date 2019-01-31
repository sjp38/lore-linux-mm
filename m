Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD7BDC169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 14:04:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C3EE20869
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 14:04:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="fCoIrdlK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C3EE20869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A4138E0002; Thu, 31 Jan 2019 09:04:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 003BD8E0001; Thu, 31 Jan 2019 09:04:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E10998E0002; Thu, 31 Jan 2019 09:04:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 84FC18E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 09:04:53 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id d6so1093176wrm.19
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 06:04:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=F4J2uLikAoq7IMqwoDmzvPi1Ik6Af4vYItHqPyipSm0=;
        b=T+U8InWR5QV1nL0CwA4Kf1cnkLtylmuktyxrd2VuqfTVYt4pKSICMN4RXFq9snasIb
         IpttqvNd+6rEweM3m2gM/bftrDwjcQsB9+Hz72nYT5u8ehldw27ghydMf2GsFemYijfG
         V6ECv+9C5FsU5NMl1ITkC86fuuxMgzxZF5N7yot159oE1Zb9O7SCm2BV6iSB6QA6KrGT
         lGPpmpJyBjY/bJDujbru78j72U1OTbDbAq+DBVC223og64LLt6ulBbSeijDzAo9Hv1OQ
         1Jz+WwLYDjlr4Lr1oQhORVxETXbdopCaQ5olWgrWnF5+l+FVd+mV4XSgFPGIhq/fQ+MZ
         +scA==
X-Gm-Message-State: AJcUukcxWeyYcWesNHw2u7u1JWiWBvOV4aSN9qh6N2PZn49i5gBs9Ks6
	5Lif301uWUAJBPIy5ww0pMAZhzzzAlb8lIigVpihCPQAXJgzgzd38kigtEgnZxa/oIKHw4SmMlL
	vjXGcyqSVktU6e/j8w9gLOg/gN0aj7pePuVfX2NiZ5ygIvNElb5174RLcm+W1C4WwwQ==
X-Received: by 2002:a1c:7e56:: with SMTP id z83mr21315845wmc.100.1548943493078;
        Thu, 31 Jan 2019 06:04:53 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5+9ZbyiJmP9Pr0wA2psQ9AJqsEM49GbiujrBbCapcjprUFMoZG4zE6cqq3pOjS9tr7mKwd
X-Received: by 2002:a1c:7e56:: with SMTP id z83mr21315778wmc.100.1548943492121;
        Thu, 31 Jan 2019 06:04:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548943492; cv=none;
        d=google.com; s=arc-20160816;
        b=0ecgHel3RejysKDa22KILIrXTOX0u9r3qM0G1KlsqOvbesg3uPfKhSPkYQU3ZpdBEv
         HNMAbJk0xqhIY0AcZ7FVT+LIK7OZpsJdEW1jf7i9a32KsgzRh27ZtvmVPyORIfjEq47e
         KZ/dylaHT+YmjAcgQa10DxesRSBiQwrkQpwYk6elXoKDKAPN5x2U/dyxWS42ZpwXCmsa
         AfkOkDLf0bGtjZ1ntouDMPjIgZgZD7fNop9W1FUK9jKsnXv5zaBdW7lC/W0lCAuhAnUh
         w6Yy3gMFTXZWyhWPzUtKzEqI0k5y2BtYi0qRWTgD5W3GVMzn87IyUwjHVvjEQyLaO15e
         WNMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=F4J2uLikAoq7IMqwoDmzvPi1Ik6Af4vYItHqPyipSm0=;
        b=WAy6PywfTuoZe26mhCzuHbmiGTT2mid1cUP3HHX7uG2BHD4//N3otyyADDffHkzC4a
         4VXEstS5Qp1vVngWITni/FqAUtXhZZPeKwi9bTlwgjYKkO9F1idWaHjzwqjgrM4bi9n3
         yVELe47SaQLeVFHZxVMOYov4nhdYK/aU5hJml34ievICaBPKvbKppYJzEDDQpse2UsMG
         J2YuzQ2fe1y1Z3kfdxmHHlACVWKu5UyTafP96UR+1gAwJTadPn+z4kTU2KsjC16qXluH
         m4jBmqngRXQQHwAf5s32YgeGyrKMWu8hb6GDjIDXcy4zgCVCK+3481mA8SCgKmAlAqyo
         5hdg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=fCoIrdlK;
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id z17si3373494wrp.53.2019.01.31.06.04.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 06:04:52 -0800 (PST)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) client-ip=5.9.137.197;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=fCoIrdlK;
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (p200300EC2BCC5900EC67343C9A90F8C7.dip0.t-ipconnect.de [IPv6:2003:ec:2bcc:5900:ec67:343c:9a90:f8c7])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id 52E0F1EC027A;
	Thu, 31 Jan 2019 15:04:51 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1548943491;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=F4J2uLikAoq7IMqwoDmzvPi1Ik6Af4vYItHqPyipSm0=;
	b=fCoIrdlKedlHxik0G+cXRPX1nnwoDCiFMR/pDc7oMLd8bKdG+FzQqyjwsQdGZBFvGoEZn+
	8Jihza1oDXoy0Aieg4PDIQUFxOq/pL9ccN3ecngyNeo0fD6BClD5qWWaCMK69pKxLF71iB
	bMJet2+ajkmjeM9n3DxGOIQnhRhnx/4=
Date: Thu, 31 Jan 2019 15:04:42 +0100
From: Borislav Petkov <bp@alien8.de>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	Marc Zyngier <marc.zyngier@arm.com>,
	Christoffer Dall <christoffer.dall@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>,
	Tony Luck <tony.luck@intel.com>,
	Dongjiu Geng <gengdongjiu@huawei.com>,
	Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>
Subject: Re: [PATCH v7 22/25] ACPI / APEI: Kick the memory_failure() queue
 for synchronous errors
Message-ID: <20190131140442.GL6749@zn.tnic>
References: <20181203180613.228133-1-james.morse@arm.com>
 <20181203180613.228133-23-james.morse@arm.com>
 <20190121175850.GO29166@zn.tnic>
 <58053f17-5f03-8408-7252-a38ed3d448a9@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <58053f17-5f03-8408-7252-a38ed3d448a9@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 23, 2019 at 06:40:08PM +0000, James Morse wrote:
> My SMM comment was because the CPU must jump from user-space->SMM, which injects
> an NMI into the kernel. The kernel's EIP must point into user-space, so
> returning from the NMI without doing the memory_failure() work puts us back the
> same position we started in.

Yeah, known issue. We dealt with that on x86 at the time:

d4812e169de4 ("x86, mce: Get rid of TIF_MCE_NOTIFY and associated mce tricks")

> > Now, memory_failure_queue() does that and can run from IRQ context so
> > you need only an irq_work which can queue from NMI context. We do it
> > this way in the MCA code:
> > 
> 
> (was there something missing here?)

Whoops. Yeah, I was about to paste this:

void mce_log(struct mce *m)
{
        if (!mce_gen_pool_add(m))
                irq_work_queue(&mce_irq_work);
}

we're basically queueing only into the lockless buffer and kicking the
IRQ work.

> > We queue in an irq_work in NMI context and work through the items in
> > process context.
> 
> How are you getting from NMI to process context in one go?

Well, #MC is basically an NMI context on x86 and when it is done, we
work through the items queued in process context. But see the commit
above too - for really urgent errors we run memory_failure *before* we
return to user.

> This patch causes the IRQ->process transition.
> The arch specific bit of this gives the irq work queue a kick if returning from
> the NMI would unmask IRQs. This makes it look like we moved from NMI to IRQ
> context without returning to user-space.
> 
> Once ghes_handle_memory_failure() runs in IRQ context, it task_work_add()s the
> call to ghes_kick_memory_failure().
> 
> Finally on the way out of the kernel to user-space that task_work runs and the
> memory_failure() work happens in process context.
> 
> During all this the user-space program counter can point at a poisoned location,
> but we don't return there until the memory_failure() work has been done.

Sounds very similar.

Actually, yours is even a bit more elegant. I wonder why we didn't use
task_work_add() then...

Thx.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

