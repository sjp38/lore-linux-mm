Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1123C04AB2
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 15:03:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D767205C9
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 15:03:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D767205C9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 25C756B0003; Thu,  9 May 2019 11:03:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 233316B0006; Thu,  9 May 2019 11:03:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 149FA6B0007; Thu,  9 May 2019 11:03:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id BD76A6B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 11:03:51 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id p14so1734937edc.4
        for <linux-mm@kvack.org>; Thu, 09 May 2019 08:03:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ky9K8qS8j5BIE07EOS08UdkCfuORwqAeyY98/ndNtb0=;
        b=Aiu5LZv8pnpP7HIkEbqGfZdMTGReqp3lsTi4qlPp12JgJMT6JgBBDk/7C/4ZhzdFUA
         RmNdmrmJmptUMGz0KOwe9TPw+3pQIgp6Z9BMDU58b4hwJr8+386Q5QrX/ulo9SHy4QWh
         eiQLqyxY9IYHsFHenfg0eHTbwAcrcA9MXYhfahJRB4Txhkj0xtn68YjGzNEewOKIH8lD
         c53X2pCutu9m0dO5eRiH0jwbomb/sO/NZ1ejNvwlCvtSZ+ZGmYjdIvQz83ZQ9aX8mYwp
         etcoe7WN6xSKj6VY6hsV3Iy12UeeVYO32AkGmxM+t7XHEEq5pb0cT2lJkOZA89UvDeOD
         Bg+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAVldNVTOlqba37Vxp/B6KWai1ElBkJbMTkATdG7I2Pl56cYYoG0
	QXEWL2XUEXCcrlZXi3Dw69Gv1g/Qha5cTqg+DJqN4a/UQ3A04rT05aOAviPkdccnlCXL7AakCZw
	A8r3HrUIiPxJc1O6qaGRNRTt1GYVofsGY6Jxm8LTDNTIfaR2vo/fh+Tn3ayLO4b30eg==
X-Received: by 2002:a50:89b0:: with SMTP id g45mr4696346edg.200.1557414231359;
        Thu, 09 May 2019 08:03:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyV4YcouKs8zVKuP9E5o0qEgxb4HI9cxrLofr+fxIviQizytJmqyVVyA94rbNeawyE9KCob
X-Received: by 2002:a50:89b0:: with SMTP id g45mr4696215edg.200.1557414230266;
        Thu, 09 May 2019 08:03:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557414230; cv=none;
        d=google.com; s=arc-20160816;
        b=oNIaSxA1LBJv9gtVKAGjlr0qsUueuQKknBvqNMggg/KL4isncaUhcAnHeFJlqeX8IY
         tnJIuTJnwIwc7sJU59i8i9GPh5y8d/gTafa6Fkg5FEreE7QLlKFGILXxfC4s1pWbcqQ0
         eYCdWgxFRXRUlPNPHTHT+20tTeweUn8z7602JO5PmcflzcQL1fuXHfo3hHkOe3+jnMyN
         gaztb6a950Rgna9UMalCJhKcUBd3Ou4zNPXqVJAYG+l+ZrYCg3bC4zk7xn/hq135Un9O
         P2O6RvcG0k6H6cES3h7UqUEnFGm8ObuqDMnNiyMU3JxA58zofaZ6HfXz7fEdtYdow5ZM
         FnHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=ky9K8qS8j5BIE07EOS08UdkCfuORwqAeyY98/ndNtb0=;
        b=X0d3Z4CesXCFUEVD0GF+PH14xRD3w/thZkf0EQnOgn/ZKQHTc/EhKIb0tXSZsqiDaA
         jkyJabUD7uiqb//4VPbe4J/N1IommtukzZBeQXgVhptUzbgTOFXs6X/4V4OyVdtN1/9Y
         /no1R5QqD7W/ehWRNjoLzIH26LBLAxxY3eWnQjJ3WtJXG0V3xGzSx3QUOZAfdrcKyDF5
         //nj0HTq8dfzECePGUEtAgErIsHRGvtWMVP8zMPFOgBAuPLHaDUHgjWG6lInPMacLRVJ
         aRbrBWsZr8oC62Cdm0eYfb3PWdcwwb6sjqv+QONiSPIJou940P5gcod19CViKMo5YAsX
         yooA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w15si1236800ejv.87.2019.05.09.08.03.49
        for <linux-mm@kvack.org>;
        Thu, 09 May 2019 08:03:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 2EEA7374;
	Thu,  9 May 2019 08:03:49 -0700 (PDT)
Received: from [10.1.196.69] (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 52BDD3F6C4;
	Thu,  9 May 2019 08:03:45 -0700 (PDT)
Subject: Re: [PATCH v8 05/20] KVM: PPC: Book3S HV: Remove pmd_is_leaf()
To: Paul Mackerras <paulus@ozlabs.org>
Cc: Mark Rutland <Mark.Rutland@arm.com>, Peter Zijlstra
 <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon
 <will.deacon@arm.com>, linux-mm@kvack.org, "H. Peter Anvin" <hpa@zytor.com>,
 "Liang, Kan" <kan.liang@linux.intel.com>,
 Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org,
 Ingo Molnar <mingo@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>,
 Arnd Bergmann <arnd@arndb.de>, kvm-ppc@vger.kernel.org,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>,
 Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-kernel@vger.kernel.org,
 James Morse <james.morse@arm.com>, Andrew Morton
 <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org
References: <20190403141627.11664-1-steven.price@arm.com>
 <20190403141627.11664-6-steven.price@arm.com>
 <20190429020555.GB11154@blackberry>
From: Steven Price <steven.price@arm.com>
Message-ID: <bf689c22-92ab-e0bf-65d8-9cd495d9e6e1@arm.com>
Date: Thu, 9 May 2019 16:03:43 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190429020555.GB11154@blackberry>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 29/04/2019 03:05, Paul Mackerras wrote:
> On Wed, Apr 03, 2019 at 03:16:12PM +0100, Steven Price wrote:
>> Since pmd_large() is now always available, pmd_is_leaf() is redundant.
>> Replace all uses with calls to pmd_large().
> 
> NAK.  I don't want to do this, because pmd_is_leaf() is purely about
> the guest page tables (the "partition-scoped" radix tree which
> specifies the guest physical to host physical translation), not about
> anything to do with the Linux process page tables.  The guest page
> tables have the same format as the Linux process page tables, but they
> are managed separately.

Fair enough, I'll drop this patch in the next posting.

> If it makes things clearer, I could rename it to "guest_pmd_is_leaf()"
> or something similar.

I'll leave that decision up to you - it might prevent similar confusion
in the future.

Steve

