Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3279C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 11:18:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57D9D205F4
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 11:18:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57D9D205F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E6A518E0009; Wed, 20 Feb 2019 06:18:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E1A818E0002; Wed, 20 Feb 2019 06:18:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D0B158E0009; Wed, 20 Feb 2019 06:18:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8CDA48E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 06:18:48 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id v82so18585455pfj.9
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 03:18:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=fymqQS0lkki3yuAVEY16ovgvmO8/V/KFLIYaKxTVUNA=;
        b=OipVli1gfVaGZsWVyzEmQTX56VeN2S0F2Gau3JRBZlyDv7tNyC+WtsGAYHdz5dS3G2
         DtLkUeYL+vS//lnC1z9CJdXBQlF/EoY4oEJu/K/Uj6KnIh4+rIdKYxeGYu05GX0JU9Fd
         R1CmYYeA8CilzLQqqACrde/SocJ17IN3PT6H+CF79vGc6XXW7BlHOw8hX620zBUftAlT
         MHDxZ6aAhq9sJPU5o5ZVrDUjkcDGsdH8wzEVAeh+A+wdmSD4RE+fnuBGL8ckCpACHanq
         N+PjZXrnBZjetjNKl9eeyR8JeWEvn9xg8QUoyCVPZckwoXUmfRCFosvAmbPbqU5MSQWH
         4fxA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: AHQUAua1XElifk9DJgzn/XIDT5GXpEz5lDXKhHZNrHOr50kUvBsxwSad
	KFzWLm1u6mgoU4U0YnsPHB1NgJ5j7pAc21caWzof10vM1/whrprhnRaVPt1d2aUfnQ90oU0DVex
	Js17n5y1lZ3MwdOJrCswaWvGm2I5LzwX/LBPIwvYPgImCHccSSgapaXAjH9+bro0=
X-Received: by 2002:a62:b618:: with SMTP id j24mr114614pff.120.1550661528272;
        Wed, 20 Feb 2019 03:18:48 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZxw/CxWEu/SoeeA8pxbAZLXEMcSq+jBIt8t4JS8yAcPQCaMfma6rvUu3ydT0vmd9cQwQVf
X-Received: by 2002:a62:b618:: with SMTP id j24mr114565pff.120.1550661527408;
        Wed, 20 Feb 2019 03:18:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550661527; cv=none;
        d=google.com; s=arc-20160816;
        b=mx8bzZ+3eE0DxHugk4bqiA2SzkkXVcKB111vLS/u7DRam8CRyLmIBGPl1CF3rfyozp
         Qto3+CHNJZg2omAZL2Teo5hmJh3vA7yZk8e3r8TS6oTGNQMgVpUxJcK4bexO4Y7bdplE
         c6J4DQ0QUl8Q++xUDCIoIZl2M1G1rTjSMq7gTxCIKP+2OrZuIa++3RAlUeWOQleGI45O
         DNuJ6/T1KJN08Uhdw+mEv+znrNXghrw2tOBpU5DQclUMRuk+YjFNyG7+etT8ntKbsSLy
         13n8oOR1mQPHtXA413q+DWCnUTGVSbvxc28pEOugUFFE+WDyN4uUAGtth94LwvOucL1u
         3PQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=fymqQS0lkki3yuAVEY16ovgvmO8/V/KFLIYaKxTVUNA=;
        b=LIoEhfIb4bgbISvf8gPeoQ0OYgFvwMSb0Md/QhIpN9KCYV43v/dmcyD56dqPWNNO4H
         D11HgxKSjcOhLrVL6DZ+BQBQTROePqiIVgoVoOPC+sz0VYDgSm77ffiU8SfnIPePxUNg
         58PGmlkzzdlIPYXzqE1OKVAW1w9WqRrefc7UwtYQLyQFwPo8iD1JaA3AXWcHY0IAqTnR
         +n4I+nPBnnyH2iYKdI/9Frwy/Aqp9WcjrI/hyEKloeLdMEw4g+lMtFpXzA7czGitKwqr
         iKwznEgcKSU0aaeE5Jt3XqGHZ8MZRtqJPQAgKHjauHrQLBGNZftCSqKDG3MnDelgCCJQ
         kg9g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id x186si18821716pfx.269.2019.02.20.03.18.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Feb 2019 03:18:47 -0800 (PST)
Received-SPF: neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 444FTs4sxKz9s71;
	Wed, 20 Feb 2019 22:18:41 +1100 (AEDT)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Segher Boessenkool <segher@kernel.crashing.org>
Cc: Balbir Singh <bsingharora@gmail.com>, erhard_f@mailbox.org, jack@suse.cz, linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aneesh.kumar@linux.vnet.ibm.com
Subject: Re: [PATCH] powerpc/64s: Fix possible corruption on big endian due to pgd/pud_present()
In-Reply-To: <20190219201539.GT14180@gate.crashing.org>
References: <20190214062339.7139-1-mpe@ellerman.id.au> <20190216105511.GA31125@350D> <20190216142206.GE14180@gate.crashing.org> <20190217062333.GC31125@350D> <87ef86dd9v.fsf@concordia.ellerman.id.au> <20190217215556.GH31125@350D> <87imxhrkdt.fsf@concordia.ellerman.id.au> <20190219201539.GT14180@gate.crashing.org>
Date: Wed, 20 Feb 2019 22:18:38 +1100
Message-ID: <87sgwi7lo1.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Segher Boessenkool <segher@kernel.crashing.org> writes:
> On Mon, Feb 18, 2019 at 11:49:18AM +1100, Michael Ellerman wrote:
>> Balbir Singh <bsingharora@gmail.com> writes:
>> > Fair enough, my point was that the compiler can help out. I'll see what
>> > -Wconversion finds on my local build :)
>> 
>> I get about 43MB of warnings here :)
>
> Yes, -Wconversion complains about a lot of things that are idiomatic C.
> There is a reason -Wconversion is not in -Wall or -Wextra.

Actually a lot of those go away when I add -Wno-sign-conversion.

And what's left seems mostly reasonable, they all indicate the
possibility of a bug I think.

In fact this works and would have caught the bug:

diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index d8c8d7c9df15..3114e3f368e2 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -904,7 +904,12 @@ static inline int pud_none(pud_t pud)
 
 static inline int pud_present(pud_t pud)
 {
+	__diag_push();
+	__diag_warn(GCC, 8, "-Wconversion", "ulong -> int");
+
 	return !!(pud_raw(pud) & cpu_to_be64(_PAGE_PRESENT));
+
+	__diag_pop();
 }
 
 extern struct page *pud_page(pud_t pud);



Obviously we're not going to instrument every function like that. But we
could start instrumenting particular files.

cheers

