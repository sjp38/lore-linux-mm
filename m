Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35FD5C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 11:49:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED7982083D
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 11:49:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED7982083D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F3F28E0003; Thu, 28 Feb 2019 06:49:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A3F48E0001; Thu, 28 Feb 2019 06:49:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 76CB88E0003; Thu, 28 Feb 2019 06:49:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 199EE8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 06:49:43 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id 29so8282680eds.12
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 03:49:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=/7lAwAPC/2ojTVRoN3IUwsBKVXVVGeMNQ0XFCyKR9VE=;
        b=Bzo8zmAdl0GB3stCm4Kd46dObEInRTyzQJeJtTscrPS3bj1xXrlrQG1z9HdwXCk272
         6Ug4gYDEESqG6k18XHPc8PAFpv6x4vlJe5CAZjMNsJyIW60D4BeRyKlzk7OK6MwvsWO7
         5LZ4fzGPbVgy+dYwmKU4bjwuGERhByfUWn79KXrNl8ikAcnwwyPuIWmALv8xKEPr9YDm
         lpzhZzw1gTTqHdLl8zxIGWYm5X+cdqCJVggROL5lg/5d8phXRDCgTXurAkELSSCrkpta
         wJPWtGnpmSFP9I7MWuCMfRScl7bZsD/V9djdTbAr+uLDhGokGZVsWlcQnN+suKCOMjvO
         lafw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAub3mNtXyu1IQN5sH35yanNnrlqbgpDde3WNR6PzqJ+srJK0JW4h
	N6paXaO3mWF+y/wzGTwO9SFKpEwj4hbSf6JURmPDEt/OJpAN6lq5Tymm4Fqo35MgLPnYdQDd9oT
	OnOenTXOevGYlH+x58x8yUaixCCG4jqVBuD13H20OpGKchvPJTkt4cTWxT68D9WfnWw==
X-Received: by 2002:a50:ba8c:: with SMTP id x12mr6612822ede.230.1551354582665;
        Thu, 28 Feb 2019 03:49:42 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib4lx2GhnE89PO0rc8U3A8HpAs5kMatpA2QEUA7PcguNBjht/o450s437di8CMIjwf7B8Vi
X-Received: by 2002:a50:ba8c:: with SMTP id x12mr6612768ede.230.1551354581775;
        Thu, 28 Feb 2019 03:49:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551354581; cv=none;
        d=google.com; s=arc-20160816;
        b=EFDRn5b+hMRoSs6w25jpvoUS4kHxkSjBWsExHsyyQr6IKKkYYAOJuNaowSF7kbH/HV
         sFbTTdmdBiDo6fbOYmF6NFcP8A1/DGYBpxdeMOQVw5isgcEtjD40/aMSemEO735jzxvl
         gRvngesXLtponV5yOnOmhZfu3LfEBoJMdOTvc+DpnWu7WZYq6BKHLUDJEhhUInP2QOU2
         mIcovdkowE++9HSBBbLKT6nGeVBrOJ+4Vwwq+mq5TQJIwMbgY6ovM2SDXpaOVnRUes38
         N6OBrTi4lz8HcYF6KFJ4tUzmNWZd5q/+NUOuaPZ6aXiM+RqAjp/gRQfaHUIJWsQTJAWd
         tA0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=/7lAwAPC/2ojTVRoN3IUwsBKVXVVGeMNQ0XFCyKR9VE=;
        b=hIFt7T+NwaqELzBX3nfjd5iybhqFGCvVvaGHbwrNQjN2xDg0PByzJXHpDKUogDVnX1
         d9X44lcxwLpjelQKGFu73mkLNLx0cn/TFiVulgZHHlUkENPrYzYJkxpa5GdHKV/4UrRF
         Bg11+ECqK6IkpOB7R0qwbpxNusrKzxqgQhwpGDAU5BJwEn6JpeETIUlW9xu5H9r4rX4N
         wg/cgebuCGt7PMhk0CNMKFPh7yq3zj6QUCU2GLU0i0yVzCi/g7B2JAcbiwmZ3eA4h8Di
         jmW3dHskItjlMVz8jLOGcbDrjm7/0slrkRPU4qctlenk7smR1tGJyGlbkhPR6qU8nkJL
         cmGw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i22si451113edv.214.2019.02.28.03.49.41
        for <linux-mm@kvack.org>;
        Thu, 28 Feb 2019 03:49:41 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B29A880D;
	Thu, 28 Feb 2019 03:49:40 -0800 (PST)
Received: from [10.1.196.69] (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 6EDAB3F738;
	Thu, 28 Feb 2019 03:49:37 -0800 (PST)
Subject: Re: [PATCH v3 20/34] sparc: mm: Add p?d_large() definitions
To: David Miller <davem@davemloft.net>
Cc: Mark.Rutland@arm.com, x86@kernel.org, arnd@arndb.de,
 ard.biesheuvel@linaro.org, peterz@infradead.org, catalin.marinas@arm.com,
 dave.hansen@linux.intel.com, will.deacon@arm.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com,
 mingo@redhat.com, bp@alien8.de, luto@kernel.org, hpa@zytor.com,
 sparclinux@vger.kernel.org, james.morse@arm.com, tglx@linutronix.de,
 linux-arm-kernel@lists.infradead.org, kan.liang@linux.intel.com
References: <20190227170608.27963-1-steven.price@arm.com>
 <20190227170608.27963-21-steven.price@arm.com>
 <20190227.103837.668255833945043179.davem@davemloft.net>
From: Steven Price <steven.price@arm.com>
Message-ID: <eee95a89-ed4a-dab9-1349-a50eee4f5b77@arm.com>
Date: Thu, 28 Feb 2019 11:49:35 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190227.103837.668255833945043179.davem@davemloft.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 27/02/2019 18:38, David Miller wrote:
> From: Steven Price <steven.price@arm.com>
> Date: Wed, 27 Feb 2019 17:05:54 +0000
> 
>> walk_page_range() is going to be allowed to walk page tables other than
>> those of user space. For this it needs to know when it has reached a
>> 'leaf' entry in the page tables. This information is provided by the
>> p?d_large() functions/macros.
>>
>> For sparc, we don't support large pages, so add stubs returning 0.
>>
>> CC: "David S. Miller" <davem@davemloft.net>
>> CC: sparclinux@vger.kernel.org
>> Signed-off-by: Steven Price <steven.price@arm.com>
> 
> Sparc does support large pages on 64-bit, just not at this level.  It
> would be nice if the commit message was made more accurate.  

Yes you are right, I fear I only looked at the 32 bit changes when I
wrote the commit message. I'll clarify the difference between 32/64 bit.

> Other than that:
> 
> Acked-by: David S. Miller <davem@davemloft.net>

Thanks,

Steve

