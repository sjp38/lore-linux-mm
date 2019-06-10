Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9F8DC468C1
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 04:36:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C7EC20820
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 04:36:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C7EC20820
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C7F16B0003; Mon, 10 Jun 2019 00:36:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 377E56B0006; Mon, 10 Jun 2019 00:36:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 267966B0007; Mon, 10 Jun 2019 00:36:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id CED316B0003
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 00:36:28 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id p14so13487457edc.4
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 21:36:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=QEjpBEhXhMs1hPZZ/vbr/4veXTMMJxl7rW7tZ6D1L0A=;
        b=pbn7I1z2XyiNKa4Bd6gxbq7paUCih61t0Dm1D8mpcE+Jo3NrvsHjrNw6I2qFkPlQ5/
         SUqhbgX+VraTgsUxvr4CzC2cn6eP5zbgeYAYJw2IrpSRu9sXMenbG4EY5SAfkDbac35A
         C1IL3UpgIspqpYJ/guX1tSVuDHEeJbL0BsYLyQTxEpjtfhKjB41GJVwFafdj2Q5FH+bm
         ddW0otF0AAXZ2Fvp1Qp03xo6RORUcUTK59H56ws1z8xywdOH13ZwuniaWcciBEMWjSaD
         FwKEfXCQkLqetVpxv3k5zp7W2yv0jmG3IlSBSZah/o0d+k3hDfMi+7D//KlAq2ebiwce
         X7EA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUinGXoDJYvODKrw/pse5haki0eW17ew2gQsf47vI8UYr+zVWel
	L6dsu8yn1LpwGy5O50l59gxFLlLWe1JecqOSXFA8fxcdUQF0enfJi4UAu1a8cEUfC9H88dY3qJC
	MKqiVHi6hywGrtRifQjMc8Voj80lR+sV4HdL08iay+0qb4m1lrg2VA7zq5N+o2jTetg==
X-Received: by 2002:a50:a56b:: with SMTP id z40mr21824209edb.99.1560141388417;
        Sun, 09 Jun 2019 21:36:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxAajEUWfiKYpB7kSS00sKJQzDKk11SlQlBdnmUa5QKwTfwNnQ1hsZvrLmeIybfQ3vwa2vH
X-Received: by 2002:a50:a56b:: with SMTP id z40mr21824178edb.99.1560141387799;
        Sun, 09 Jun 2019 21:36:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560141387; cv=none;
        d=google.com; s=arc-20160816;
        b=SlfCgBsQMBQl390V/0k0WBLfMnWJ/6oUU8Mmfpg+1lNHZ5lvBQdwzW0mXOHPGx457+
         lCJY+dByW3UsSBPJq+c+YQ4CQeDaUjOuxvBJaSm+EhjIf6lWY+Q+QR4ia+ruIQgxJfXg
         zZRp0lCeSr6tFq5l32APFyjIZokRaD2oDFcqzNAPaQUwf/LT6hzupmeqyU/Y+kj6x1T6
         W0Rj8n10Pl+4jnuQzxkCz/3eQ2AAciVa6r7qfLZVfUheTnwDmu9nlOlAerDI8q90tdDt
         azWg/S38hkImI91onLIVTDCVgJNTDIQG5rMvWyvi8CICYe7H0XWebd6GY/OL1Xx326rG
         paCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=QEjpBEhXhMs1hPZZ/vbr/4veXTMMJxl7rW7tZ6D1L0A=;
        b=ul26ZN+uL6bzHWknA93Q9sIOLMDqRObefDpb+/1Ak47Fxjkf0ICOM+PciTRedliXp0
         yf5Wy33YlXDP5SkOIYJA6dF3EChH49d70awgqQnqsIf2V11qz1/Tvsoo5E1/6NLNdzQ4
         rR8SClpVlOvW6X5YDRxntNw//eizvL3HhJ+ByE8UHoURtPsn8LGyYv1wXhF5wW0VfPVY
         tv7kc4CY0K4OgCJqQO9sTsN4iVBCSQC9zvZZC8X4MQNyWboDDrcRpE/3VoCJ7ie5K171
         YDfmIfU3EJ84gHMNQCepwl0JW7YHru4Qgc/cMkRNSFGU7XlAn0M90OcqGSVjJu8qPd4f
         X03Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id q22si2918141ejm.54.2019.06.09.21.36.27
        for <linux-mm@kvack.org>;
        Sun, 09 Jun 2019 21:36:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9C058337;
	Sun,  9 Jun 2019 21:36:26 -0700 (PDT)
Received: from [10.162.42.131] (p8cg001049571a15.blr.arm.com [10.162.42.131])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A664B3F557;
	Sun,  9 Jun 2019 21:36:16 -0700 (PDT)
Subject: Re: [RFC V3] mm: Generalize and rename notify_page_fault() as
 kprobe_page_fault()
To: Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
Cc: linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org,
 Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
 Matthew Wilcox <willy@infradead.org>, Mark Rutland <mark.rutland@arm.com>,
 Christophe Leroy <christophe.leroy@c-s.fr>,
 Stephen Rothwell <sfr@canb.auug.org.au>,
 Andrey Konovalov <andreyknvl@google.com>,
 Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>,
 Russell King <linux@armlinux.org.uk>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Tony Luck <tony.luck@intel.com>,
 Fenghua Yu <fenghua.yu@intel.com>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Yoshinori Sato <ysato@users.sourceforge.jp>,
 "David S. Miller" <davem@davemloft.net>, Thomas Gleixner
 <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>,
 Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>,
 Dave Hansen <dave.hansen@linux.intel.com>
References: <1559903655-5609-1-git-send-email-anshuman.khandual@arm.com>
 <6e095842-0f7f-f428-653d-2b6e98fea6b3@intel.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <bc8e2140-dc78-ce99-a336-91733c2fda67@arm.com>
Date: Mon, 10 Jun 2019 10:06:34 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <6e095842-0f7f-f428-653d-2b6e98fea6b3@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 06/07/2019 08:36 PM, Dave Hansen wrote:
> On 6/7/19 3:34 AM, Anshuman Khandual wrote:
>> +static nokprobe_inline bool kprobe_page_fault(struct pt_regs *regs,
>> +					      unsigned int trap)
>> +{
>> +	int ret = 0;
>> +
>> +	/*
>> +	 * To be potentially processing a kprobe fault and to be allowed
>> +	 * to call kprobe_running(), we have to be non-preemptible.
>> +	 */
>> +	if (kprobes_built_in() && !preemptible() && !user_mode(regs)) {
>> +		if (kprobe_running() && kprobe_fault_handler(regs, trap))
>> +			ret = 1;
>> +	}
>> +	return ret;
>> +}
> 
> Nits: Other that taking the nice, readable, x86 one and globbing it onto
> a single line, looks OK to me.  It does seem a _bit_ silly to go to the
> trouble of converting to 'bool' and then using 0/1 and an 'int'
> internally instead of true/false and a bool, though.  It's also not a

Changing to 'bool'...

> horrible thing to add a single line comment to this sucker to say:
> 
> /* returns true if kprobes handled the fault */
> 

Picking this in-code comment.

> In any case, and even if you don't clean any of this up:
> 
> Reviewed-by: Dave Hansen <dave.hansen@linux.intel.com>
> 

Thanks !

