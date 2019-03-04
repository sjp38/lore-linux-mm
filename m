Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0178C10F03
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 13:16:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8728920830
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 13:16:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8728920830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20EDD8E0005; Mon,  4 Mar 2019 08:16:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 195318E0001; Mon,  4 Mar 2019 08:16:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 05E128E0005; Mon,  4 Mar 2019 08:16:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9E1328E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 08:16:55 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id 29so2600857eds.12
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 05:16:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=eBdK89kLVUJPHT8ZWFzjm3+mucLgD5VYryVZKZ9KcUY=;
        b=Zgj+yq7ZqA7uoBEXa3LZQ1znAJ1dp7cAzWSg04joywEacZYlhV6K666oXSeI1RtD67
         QxsRk7MOosVBg8YMew12dHQMIdC3Nrec+HyYzGvdIG9E5GLO1s4Gb0OJTV7FUmitimS8
         u9bQYDkoDwlyTjHLizjQsDCsOGtF/GdQhotb1Jfo23ICv9ZYU4qalo4As0o3NkjR8rJD
         BirnUcv9paqHYs0qHI7CF0KtBwIWHS7IrIIaNHab7YVj0qWANqDN2oJZ6LGVRsKCxnBI
         zFyrGr7NF5OvEglJf43k8TXaAmLMOwaKlfpyrf7bvTsxzsHXGRbr6TpAXKcR53CZFbHH
         Qi1Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAUKy3CcA6/x47fc5BEwGvXcF5WkmDneLbdN1KbTKCmOIbktQVQM
	1TsFgW1kEhETCdWOusrjZCglA2SjWmFLB27leZ5Cen+yyir2rVURNDqjl9LqU2zRSzEXJI+mUQM
	XbQIrP/DZHSqDEtPUuKj+OY0duCJUCVGeEJ/Bl/zqulljz1EIIwcjsn9A1gSqj4mINw==
X-Received: by 2002:a17:906:b742:: with SMTP id fx2mr12845883ejb.199.1551705415200;
        Mon, 04 Mar 2019 05:16:55 -0800 (PST)
X-Google-Smtp-Source: APXvYqz3OtFb6lGjxk+RVY2pCEYi51+xuJ2ifIpwxB52LGOXcid/4haposrFuwwmQTJOYatkNYY5
X-Received: by 2002:a17:906:b742:: with SMTP id fx2mr12845835ejb.199.1551705414310;
        Mon, 04 Mar 2019 05:16:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551705414; cv=none;
        d=google.com; s=arc-20160816;
        b=g80T4yyrxWjeUdmUH6AVHhMai/1nQuQw10ePHz6sHVI5WzpYgH1IztpDqaZBm+NmS+
         wyuWRNsoHuTBt0tO/h8Y6EsqoEzqSY2i7DrWLYku0V2l08oEWCJyccYGuyGHR++v03Wx
         a2htFMRZ7iQhZLchHfDsXRSo2wB7UGj1oIjapblh5vdOe3SY9kdZF+vV4xaL0KygLVzO
         xrpsxEiZEpFoozLT5Xb5aiw79XlOTX+2b3CDdIJpcFnPlS/AEoaSfYK4/Uz93d1WShlh
         039UY/goZu0blnVMqBpcCgnu0ugex3gJStN2tRia/6dcsXj9fu7WvDeUDa4CGEGFaI2d
         WRQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=eBdK89kLVUJPHT8ZWFzjm3+mucLgD5VYryVZKZ9KcUY=;
        b=lJtIzzdoNqVpgNFDTZ2kLNSidYOczowZGqPXES4yGr89BlKnNz7f045ESS5I+Lx7zY
         KY/4e5zYg16NnSxCqKwW9fbP5+6XfKSLYdSvzw0+67p6R5OWdeIWzqcZkhP1TEPeBUzu
         0tu/GfLjhKO6Q0aOFP9eMR+DQplGr/FANXG4ZXLOG3rSytDzjylWj5TKcNZEG6gf8QgZ
         RkE8GggEJkOF7js5TlXdI4+ZO5vA7sgMUwUCCZfucHOFqW/X3wyyKV4y4NvrS3HW6x6M
         Y/uWmu/VrGKHTcdfsbihAtXMyFaO9qZv652cov3O5+LTx+TmRNZEvNQ4eJvz/onia15q
         ltYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w27si2342049edi.262.2019.03.04.05.16.54
        for <linux-mm@kvack.org>;
        Mon, 04 Mar 2019 05:16:54 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id F35CEEBD;
	Mon,  4 Mar 2019 05:16:52 -0800 (PST)
Received: from [10.1.196.69] (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 5F6333F575;
	Mon,  4 Mar 2019 05:16:49 -0800 (PST)
Subject: Re: [PATCH v3 08/34] ia64: mm: Add p?d_large() definitions
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Mark Rutland <Mark.Rutland@arm.com>, linux-ia64@vger.kernel.org,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon
 <will.deacon@arm.com>, linux-mm@kvack.org, "H. Peter Anvin" <hpa@zytor.com>,
 "Liang, Kan" <kan.liang@linux.intel.com>, x86@kernel.org,
 Ingo Molnar <mingo@redhat.com>, Fenghua Yu <fenghua.yu@intel.com>,
 Arnd Bergmann <arnd@arndb.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>,
 linux-arm-kernel@lists.infradead.org, Tony Luck <tony.luck@intel.com>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-kernel@vger.kernel.org,
 James Morse <james.morse@arm.com>
References: <20190227170608.27963-1-steven.price@arm.com>
 <20190227170608.27963-9-steven.price@arm.com>
 <20190301215728.nk7466zohdlgelcb@kshutemo-mobl1>
From: Steven Price <steven.price@arm.com>
Message-ID: <15100043-26e4-2ee1-28fe-101e12f74926@arm.com>
Date: Mon, 4 Mar 2019 13:16:47 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190301215728.nk7466zohdlgelcb@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 01/03/2019 21:57, Kirill A. Shutemov wrote:
> On Wed, Feb 27, 2019 at 05:05:42PM +0000, Steven Price wrote:
>> walk_page_range() is going to be allowed to walk page tables other than
>> those of user space. For this it needs to know when it has reached a
>> 'leaf' entry in the page tables. This information is provided by the
>> p?d_large() functions/macros.
>>
>> For ia64 leaf entries are always at the lowest level, so implement
>> stubs returning 0.
> 
> Are you sure about this? I see pte_mkhuge defined for ia64 and Kconfig
> contains hugetlb references.
> 

I'm not completely familiar with ia64, but my understanding is that it
doesn't have the situation where a page table walk ends early - there is
always the full depth of entries. The p?d_huge() functions always return 0.

However my understanding is that it does support huge TLB entries, so
when populating the TLB a region larger than a standard page can be mapped.

I'd definitely welcome review by someone more familiar with ia64 to
check my assumptions.

Thanks,

Steve

