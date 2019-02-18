Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC628C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 09:16:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 738342184E
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 09:16:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 738342184E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A4518E0005; Mon, 18 Feb 2019 04:16:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 054A98E0002; Mon, 18 Feb 2019 04:16:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E85838E0005; Mon, 18 Feb 2019 04:16:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8A1918E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 04:16:28 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c53so6945623edc.9
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 01:16:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=QSd1Ak0wqqWuI3DaxeXT3BfhjDbcISdj4h6hnpJFMuE=;
        b=mUk988rOWGVEcom1dzJwxtNWFt8vdb+olLSMSjGDqL4sYIIRSuajl0f+sxh+uya3sb
         r77LP5NB3+KxYspL2d7ABQbNeo8LY8hKZ2SwU7G5rUFbH13VvZhZld94DrnwfNgz/jFv
         1qBHjIQ0s1M0b1whaCP2QAVVQ0zyvOH8vHeeqk1WjXnM2oovq/oB09AIu+1o5f+z/TeV
         palDsnOQ/dH156JaixqHUe5wlMkFXT1fPB/rh+c2dkaFplb5Jrt8WpzsF5dneN/9Yi+f
         GEsGgOfR0ViUqXrUHintaCXu3AVCKq7cRtL/eIIJ5ZW7Aq1GlpaASmkr8F+pK3Lw8zMN
         00gg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: AHQUAuaY91DnZklfRPpsIVsR5JVp9hSCI5fsmFPWVfSyMi7i4rtpGqOY
	lasD+SEDId85tuUZriMtX5iH8j8qQtXhDGdDO7xjzkXT5DhxI2AxUKbAcBB/se2SAFKEMwoGuSZ
	hrcNr9uWY4Juokn06sqKrxjIOjHHrOZRL6YKueJzDStUC3szwCbHpOJMtaKhLL/ISRw==
X-Received: by 2002:a50:adfa:: with SMTP id b55mr18575603edd.160.1550481388091;
        Mon, 18 Feb 2019 01:16:28 -0800 (PST)
X-Google-Smtp-Source: AHgI3IblR30bjg0LtJX92rG7Vd9+r5oKpnARkKJmZM8vqQnZkxVKHJSEMXvhrxeIwEGBzaW/7WgP
X-Received: by 2002:a50:adfa:: with SMTP id b55mr18575558edd.160.1550481387200;
        Mon, 18 Feb 2019 01:16:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550481387; cv=none;
        d=google.com; s=arc-20160816;
        b=iZpP+4/mNOO1JCSaZkAToAyWwr/jzt9g7ziMjQ4OVr1cNnZ8po8VRlsC6Essb5dtXr
         fP+LdPJRVCgqeZVCjgcn9JDXGtBEXkIUO6PQkTsRLrd1rz9//DrzKJkT4hdplYHhPPft
         FIyu48TVejmuXUhFb3P7GvjdqM18ufdgZdhIdbpFde1xfg7f100FUxoqLI2Im4u2Vb03
         KGcK9JWuiEJEgIIyiypI0fCwVF9tfoDDaKyeoK6w6c0f6rVAh5x1+GW3IoBH19BullVg
         cqPoc4uJc0YswsLyPWC1Qn1xEUIHcblfVlbPJ//ryVHC+IBDSO9I++4Jw6V8WN7faXK8
         nlhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=QSd1Ak0wqqWuI3DaxeXT3BfhjDbcISdj4h6hnpJFMuE=;
        b=EOhwsHrGXgV2bUc+y1pogp7vMkVeXHH4iaGNV3E0D1pMU0e42MUyJtGscS+8YLhBP7
         SnxBOGn46Lbh3RIDma8vqvsEH67gWmJmg5W1wttORCULEg4X1QfHQEievM4Mgv/TDl94
         VbftPMot/j6sTeP1UaQO89+c0L6HbyVbsvTMK1IsyT91cDhl+ck9mXi8b8hfYYle1B9F
         4boHRo8vXEG7S303zPy5tzNSGywewCk+t+mTbTuzv+yoZf5xJ+yy9nXXor3QlhrVjqJc
         6xr3cfvPi23p8Xzte141Hl+rK8JJ7G0fXjeh/f0cG2ZeqgYJbuOzB5MI9Z8IUOikw9Xv
         GdjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g18si319073edh.385.2019.02.18.01.16.26
        for <linux-mm@kvack.org>;
        Mon, 18 Feb 2019 01:16:27 -0800 (PST)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 25D9BA78;
	Mon, 18 Feb 2019 01:16:26 -0800 (PST)
Received: from [10.162.40.135] (p8cg001049571a15.blr.arm.com [10.162.40.135])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 6011C3F589;
	Mon, 18 Feb 2019 01:16:22 -0800 (PST)
Subject: Re: [RFC 0/4] mm: Introduce lazy exec permission setting on a page
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org,
 akpm@linux-foundation.org, mhocko@kernel.org, kirill@shutemov.name,
 kirill.shutemov@linux.intel.com, vbabka@suse.cz, will.deacon@arm.com
References: <1550045191-27483-1-git-send-email-anshuman.khandual@arm.com>
 <7f25d3f4-68a1-58de-1a78-1bd942e3ba2f@intel.com>
 <413d74d1-7d74-435c-70c0-91b8a642bf99@arm.com>
 <35b14038-379f-12fb-d943-5a083a2a7056@intel.com>
 <3da12849-bc56-cb9b-f13f-e15d42416223@arm.com>
 <20190218090433.bxtty3rrgo4ln6hp@mbp>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <b1a09e8b-7975-3f5c-8fd3-76b3a3447371@arm.com>
Date: Mon, 18 Feb 2019 14:46:24 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190218090433.bxtty3rrgo4ln6hp@mbp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 02/18/2019 02:34 PM, Catalin Marinas wrote:
> On Mon, Feb 18, 2019 at 02:01:55PM +0530, Anshuman Khandual wrote:
>> On 02/14/2019 10:25 PM, Dave Hansen wrote:
>>> On 2/13/19 8:12 PM, Anshuman Khandual wrote:
>>>> On 02/13/2019 09:14 PM, Dave Hansen wrote:
>>>>> On 2/13/19 12:06 AM, Anshuman Khandual wrote:
>>>>>> Setting an exec permission on a page normally triggers I-cache invalidation
>>>>>> which might be expensive. I-cache invalidation is not mandatory on a given
>>>>>> page if there is no immediate exec access on it. Non-fault modification of
>>>>>> user page table from generic memory paths like migration can be improved if
>>>>>> setting of the exec permission on the page can be deferred till actual use.
>>>>>> There was a performance report [1] which highlighted the problem.
>>>>>
>>>>> How does this happen?  If the page was not executed, then it'll
>>>>> (presumably) be non-present which won't require icache invalidation.
>>>>> So, this would only be for pages that have been executed (and won't
>>>>> again before the next migration), *or* for pages that were mapped
>>>>> executable but never executed.
>>>> I-cache invalidation happens while migrating a 'mapped and executable' page
>>>> irrespective whether that page was really executed for being mapped there
>>>> in the first place.
>>>
>>> Ahh, got it.  I also assume that the Accessed bit on these platforms is
>>> also managed similar to how we do it on x86 such that it can't be used
>>> to drive invalidation decisions?
>>
>> Drive I-cache invalidation ? Could you please elaborate on this. Is not that
>> the access bit mechanism is to identify dirty pages after write faults when
>> it is SW updated or write accesses when HW updated. In SW updated method, given
>> PTE goes through pte_young() during page fault. Then how to differentiate exec
>> fault/access from an write fault/access and decide to invalidate the I-cache.
>> Just being curious.
> 
> The access flag is used to identify young/old pages only (the dirty bit
> is used to track writes to a page). Depending on the Arm implementation,
> the access bit/flag could be managed by hardware transparently, so no
> fault taken to the kernel on accessing through an 'old' pte.

Then there is no way to identify an exec fault with either of the facilities of
access/reference bit or dirty bit whether managed by SW or HW. Still wondering about
previous comment where Dave mentioned how it can be used for I-cache invalidation.

