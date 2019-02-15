Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13B07C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 03:58:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A976621A80
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 03:58:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A976621A80
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 29EB18E0002; Thu, 14 Feb 2019 22:58:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 24D368E0001; Thu, 14 Feb 2019 22:58:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 13E398E0002; Thu, 14 Feb 2019 22:58:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C6CE98E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 22:58:31 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id q62so5908944pgq.9
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 19:58:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=w17C4ONSG1fP/iU9e+ow+yU2qGMcWGgJAEi0UtCb5DM=;
        b=PAT3N10KILJPdXxkQ2lkt12nE3yS9GEb6cM1NDouG+s7OrxiIsmImaH6QDfgulqmji
         u4HvN/seC4zcvxBEd5o1l1f9X5BuGou+ZIbn8fbA4fiSMrYEH79TGzEK9kh0D66EgcPM
         nTb/5bQRX0Ha3mJOsviSmgdQmSBKAa8GIQZovKF6wbJeOxc0gzkKvz3K82jlUCN9uy2E
         3mbpCCqSSbHoFXtUnLb0m21aTOTd9Nw4ELWDRGZqMQBCH2V6UM/J8tkDOFWCYldIcbwr
         c42s1pmq4NURMMS/VVLd8DjzZf2PHW3sdXXAZRJM3tIZDUvgyeH/fWx1YDRmdFbo2ZbU
         0jlg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: AHQUAuY1X2fc2VHssafcKuQDgEmQxLzbbfOyL3AozJ9zDG8i9urejFpQ
	EBJXxqNEY90OaBUaGK75K50/GpFk9nezGgg4DpfIBsthakZwCLkIu9dWQz//KIPPk7lL76RiDWI
	lR5mmcfvlcgSkcubRCgNhvyhXpR0BWTLG33iFvpgfVFfcAID817jPgTKg2hsVQic=
X-Received: by 2002:a63:c745:: with SMTP id v5mr3406462pgg.261.1550203111452;
        Thu, 14 Feb 2019 19:58:31 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY1Wh5l1vXycG49u55OlP3A3olDN4dKiRPv5nAN+OqZP4a1c/cL9aoXQt+7+HYbvji06o1o
X-Received: by 2002:a63:c745:: with SMTP id v5mr3406394pgg.261.1550203110482;
        Thu, 14 Feb 2019 19:58:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550203110; cv=none;
        d=google.com; s=arc-20160816;
        b=RylOL85Hga5b8WCtM2Q+517XT/AuqTcFNOb8ouPnrSMGUGXp4z0tPeDQ0cTqLSFRLH
         n2qw0hsznyGYZ6rgLxblCn9NZekEbK8ku74QNqVCjOLttIu+OYkgusMH3ELm4lCVlsTu
         ZoLEg5Kh7+5jWwq+Owg5ugKxevEIDgcITNVCrrF49XjXuZTrdvWLXH97388rMqv/5oHr
         qAFFFYlRjwYGyGsmOmNwpDdVAXvSbLHQNLHyVq4XbgWXG0cJ8zTlv3qt6pU4Er8/Z/0A
         1JRt+fHbUR0awrZh8DqLd+hcVi9FhsYctG6n89kk8eoRgSu3tfQnYubYBYDaAjCwLSyH
         5irg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=w17C4ONSG1fP/iU9e+ow+yU2qGMcWGgJAEi0UtCb5DM=;
        b=0O+i8IvO/0RxwdhqTzAlgr7S3cvccn4VRz/mNPRBimUBhyQKxgfmqCptopWT15AQpT
         huB1mQGFLDH8w02y5BWRqHeUOTc8m4D5/+J3qHdPcgoms3bXzMqGsa3ffc58LK61o0h4
         CT+wyKzoKpHjFL3wXyZl4WcrEOfiGfcVKn6n3wXJJSm+3KrpNyshmnRKNXx4cbOwxcjT
         0A38cyPfLkw6gRgF2gpiHhc1NaXSpNTSybxvT29rgvGiYITrE6k0VeIZOJ/kIstBv/Rj
         4WXMULDDwWnL4Q8lYoiuufbnhrQ3k1IdiGyCfwyCnw+8i2T7oyHIF9E31NqRO59+0rpA
         5qMg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id a9si2808354plp.323.2019.02.14.19.58.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 14 Feb 2019 19:58:30 -0800 (PST)
Received-SPF: neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 440zyC4WM0z9sPT;
	Fri, 15 Feb 2019 14:58:27 +1100 (AEDT)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Matt Corallo <kernel@bluematt.me>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linuxppc-dev@lists.ozlabs.org
Subject: Re: [Bug 202149] New: NULL Pointer Dereference in __split_huge_pmd on PPC64LE
In-Reply-To: <CCDBD6B9-31CD-4B94-AA8F-9BEF1C133AED@bluematt.me>
References: <bug-202149-27@https.bugzilla.kernel.org/> <20190104170459.c8c7fa57ba9bc8a69dee5666@linux-foundation.org> <87ef9nk4cj.fsf@linux.ibm.com> <ed4bea40-cf9e-89a1-f99a-3dbd6249847f@bluematt.me> <8736q2jbhr.fsf@linux.ibm.com> <A61367CF-277E-4E74-8A9D-C94C5E53817B@bluematt.me> <87bm4achnu.fsf@linux.ibm.com> <CCDBD6B9-31CD-4B94-AA8F-9BEF1C133AED@bluematt.me>
Date: Fri, 15 Feb 2019 14:58:25 +1100
Message-ID: <87va1ld7oe.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Matt Corallo <kernel@bluematt.me> writes:
> Hey, sorry for the delay on this. I had some apparently-unrelated
> hangs that I believe were due to mpt3sas instability, and at the risk
> of speaking too soon for a bug I couldn't reliably reproduce, this
> patch appears to have resolved it, thanks!

Thanks.

For the archives it went upstream in a slightly different form as:

  579b9239c1f3 ("powerpc/radix: Fix kernel crash with mremap()")

  https://git.kernel.org/torvalds/c/579b9239c1f3


cheers

>> On Jan 21, 2019, at 07:35, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com> wrote:
>> 
>> 
>> Can you test this patch?
>> 
>> From e511e79af9a314854848ea8fda9dfa6d7e07c5e4 Mon Sep 17 00:00:00 2001
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
>> Date: Mon, 21 Jan 2019 16:43:17 +0530
>> Subject: [PATCH] arch/powerpc/radix: Fix kernel crash with mremap
>> 
>> With support for split pmd lock, we use pmd page pmd_huge_pte pointer to store
>> the deposited page table. In those config when we move page tables we need to
>> make sure we move the depoisted page table to the right pmd page. Otherwise this
>> can result in crash when we withdraw of deposited page table because we can find
>> the pmd_huge_pte NULL.
>> 
>> c0000000004a1230 __split_huge_pmd+0x1070/0x1940
>> c0000000004a0ff4 __split_huge_pmd+0xe34/0x1940 (unreliable)
>> c0000000004a4000 vma_adjust_trans_huge+0x110/0x1c0
>> c00000000042fe04 __vma_adjust+0x2b4/0x9b0
>> c0000000004316e8 __split_vma+0x1b8/0x280
>> c00000000043192c __do_munmap+0x13c/0x550
>> c000000000439390 sys_mremap+0x220/0x7e0
>> c00000000000b488 system_call+0x5c/0x70
>> 
>> Fixes: 675d995297d4 ("powerpc/book3s64: Enable split pmd ptlock.")
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
>> ---
>> arch/powerpc/include/asm/book3s/64/pgtable.h | 2 --
>> 1 file changed, 2 deletions(-)
>> 
>> diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
>> index 92eaea164700..86e62384256d 100644
>> --- a/arch/powerpc/include/asm/book3s/64/pgtable.h
>> +++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
>> @@ -1262,8 +1262,6 @@ static inline int pmd_move_must_withdraw(struct spinlock *new_pmd_ptl,
>>                     struct spinlock *old_pmd_ptl,
>>                     struct vm_area_struct *vma)
>> {
>> -    if (radix_enabled())
>> -        return false;
>>    /*
>>     * Archs like ppc64 use pgtable to store per pmd
>>     * specific information. So when we switch the pmd,
>> -- 
>> 2.20.1
>> 

