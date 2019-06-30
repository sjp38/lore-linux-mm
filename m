Return-Path: <SRS0=QnEd=U5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61072C5B576
	for <linux-mm@archiver.kernel.org>; Sun, 30 Jun 2019 04:40:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA2B3206A2
	for <linux-mm@archiver.kernel.org>; Sun, 30 Jun 2019 04:40:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA2B3206A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 65DF76B0003; Sun, 30 Jun 2019 00:40:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 60DAC8E0003; Sun, 30 Jun 2019 00:40:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D86A8E0002; Sun, 30 Jun 2019 00:40:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f80.google.com (mail-ed1-f80.google.com [209.85.208.80])
	by kanga.kvack.org (Postfix) with ESMTP id 00BE66B0003
	for <linux-mm@kvack.org>; Sun, 30 Jun 2019 00:40:50 -0400 (EDT)
Received: by mail-ed1-f80.google.com with SMTP id y3so13404668edm.21
        for <linux-mm@kvack.org>; Sat, 29 Jun 2019 21:40:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:subject
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=tuWaEnwN9yE4g1QwgaGCgWIC2IM105I5Nc4PIF0YlVI=;
        b=llkyQWWMr8uTk6nIxqcd4oePVx3gt3jhOsYrQjliIWxRoG9FvNW1rLXibQn0a20j4i
         TwabC6AyQd8m8ZTWimEvIdgdHQJDTqENGKeHpVOCy5WrabxbLfPPhkT+yITtCTAVpsU8
         H+FKT9YIZJhwaBYRVlBGBs2ut4TjtSWv1LrqpaLv+7cKtq7OZA4iRHGll56e4FlySWdl
         fGU70XcyVitts7GeQXLa9O0Y2VHLfYKSuXYwSV00YQfD/kjAFOCOQINfLq+5SxvYFaq4
         +qYBWiebiE0spO2iCWXt7awjZPSdWkcq7R7/E3BGtwsnZpb5V9Iz70HyLm30P87lYdCZ
         O69Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAW2by/dR9xSUvwFevrE/X/RuFc6g00N6s6qObDqYnUlBsjMNoO7
	ouwaaSDxjRfV8REjOJQzLYz2p43XDuRr4a6Bjv7CA/x7TNXNJDCpsaBMtRB8enqfs4wI4aX1Jje
	gN2naoYJ7zgCBEADlqzFWlEBjZRz9v7Mv7/IlgFBvx5NCZkP5ollN15GAAH5WATsrWw==
X-Received: by 2002:a50:e718:: with SMTP id a24mr20811548edn.91.1561869649486;
        Sat, 29 Jun 2019 21:40:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyRKVETObeHQjNfXUq80mVmZE7Yh8kuI5m80kx5532qHgmO2dBIRC9tstbxC08zO6aYLVvm
X-Received: by 2002:a50:e718:: with SMTP id a24mr20811491edn.91.1561869648627;
        Sat, 29 Jun 2019 21:40:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561869648; cv=none;
        d=google.com; s=arc-20160816;
        b=KhAS7lAVAtxkH/pbRpPx7tENzVA/Z3wm7z//8ZRoQJ0q4WXS0iefPNFrehZy0XPavR
         8BiCiZpA+I8DeFV8f/Wt0Av7u4MDn2VOVtyWFE96gVWPp6eiop6pF29RaIxhSfIOYmDw
         9PhNEGc7eNgFvGZJ3bKuPBZHLGXXwGemrnR9oUtdglkhoUxglSWo/DskPC6d+C6wHW3C
         6rOkBJoFEdvSWsIURP60jc0P3y9VJztpPVoWMgOwJlXpYSK3kH72LiODAOrDAGlBeiFC
         i65Lli11rr9n8d6Vfd+DnJT/qXFdu7xCzr9nVsWWVJ9kYsmCAFrYlOn74NktWcXI5P3A
         /mTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:subject:from;
        bh=tuWaEnwN9yE4g1QwgaGCgWIC2IM105I5Nc4PIF0YlVI=;
        b=NogdhzGQ3OlZnX5x+7gQjyoNglMm2ikJQg//mMo9r6C85CZxoDMCKr5oaWmhA41wlB
         rkEhe7SbSADEnrnQhylVInS5sy8uWCns8/anzzX3KLfk0p+sx2Ch63mgCGjmK4P/el/T
         Ko3jc1+A+U8weujbgHgLcoy1FmIbPK7RNNsE//K/DmPC+LaV2DZG0kO6X2XWe7KKYoDU
         8dagM/myoazYmQUQcQ8rgl25rxjJZArZpJ9yzbJwwu8soK6Yy5WKAdsPJn2AZKQz3FyY
         QGvmZf+AURHCodRnkmpVKi+dnyUcLj8/zHMXy4vEpKoVqtWroE3PHCRc0oqSZy+WKD3B
         PY9g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id c49si5732634eda.166.2019.06.29.21.40.48
        for <linux-mm@kvack.org>;
        Sat, 29 Jun 2019 21:40:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 5A8E728;
	Sat, 29 Jun 2019 21:40:47 -0700 (PDT)
Received: from [192.168.0.129] (unknown [172.31.20.19])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 5ECD73F706;
	Sat, 29 Jun 2019 21:40:37 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: Re: [PATCH] mm: Generalize and rename notify_page_fault() as
 kprobe_page_fault()
To: Guenter Roeck <linux@roeck-us.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Mark Rutland <mark.rutland@arm.com>, Michal Hocko <mhocko@suse.com>,
 linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon
 <will.deacon@arm.com>, Paul Mackerras <paulus@samba.org>,
 sparclinux@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>,
 linux-s390@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>,
 Michael Ellerman <mpe@ellerman.id.au>, x86@kernel.org,
 Russell King <linux@armlinux.org.uk>, Matthew Wilcox <willy@infradead.org>,
 Ingo Molnar <mingo@redhat.com>, James Hogan <jhogan@kernel.org>,
 linux-snps-arc@lists.infradead.org, Fenghua Yu <fenghua.yu@intel.com>,
 Andrey Konovalov <andreyknvl@google.com>, Andy Lutomirski <luto@kernel.org>,
 Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org,
 Christophe Leroy <christophe.leroy@c-s.fr>, Tony Luck <tony.luck@intel.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Vineet Gupta <vgupta@synopsys.com>, linux-mips@vger.kernel.org,
 Ralf Baechle <ralf@linux-mips.org>, Paul Burton <paul.burton@mips.com>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org,
 "David S. Miller" <davem@davemloft.net>
References: <1560420444-25737-1-git-send-email-anshuman.khandual@arm.com>
 <20190629145009.GA28613@roeck-us.net>
Message-ID: <78863cd0-8cb5-c4fd-ed06-b1136bdbb6ef@arm.com>
Date: Sun, 30 Jun 2019 10:11:03 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190629145009.GA28613@roeck-us.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Guenter,

On 06/29/2019 08:20 PM, Guenter Roeck wrote:
> Hi,
> 
> On Thu, Jun 13, 2019 at 03:37:24PM +0530, Anshuman Khandual wrote:
>> Architectures which support kprobes have very similar boilerplate around
>> calling kprobe_fault_handler(). Use a helper function in kprobes.h to unify
>> them, based on the x86 code.
>>
>> This changes the behaviour for other architectures when preemption is
>> enabled. Previously, they would have disabled preemption while calling the
>> kprobe handler. However, preemption would be disabled if this fault was
>> due to a kprobe, so we know the fault was not due to a kprobe handler and
>> can simply return failure.
>>
>> This behaviour was introduced in the commit a980c0ef9f6d ("x86/kprobes:
>> Refactor kprobes_fault() like kprobe_exceptions_notify()")
>>
> 
> With this patch applied, parisc:allmodconfig images no longer build.
> 
> In file included from arch/parisc/mm/fixmap.c:8:
> include/linux/kprobes.h: In function 'kprobe_page_fault':
> include/linux/kprobes.h:477:9: error:
> 	implicit declaration of function 'kprobe_fault_handler'; did you mean 'kprobe_page_fault'?

Yikes.. Arch parisc does not even define (unlike mips which did but never exported)
now required function kprobe_fault_handler() when CONFIG_KPROBES is enabled.

I believe rather than defining one stub version only for parsic it would be better
to have an weak symbol generic stub definition for kprobe_fault_handler() in file
include/linux/kprobes.h when CONFIG_KPROBES is enabled along side the other stub
definition when !CONFIG_KPROBES. But arch which wants to use kprobe_page_fault()
cannot use stub kprobe_fault_handler() definition and will have to provide one.
I will probably add a comment regarding this.

> 
> Reverting the patch fixes the problem.
> 
> Guenter
> 

Thanks for reporting the problem.

