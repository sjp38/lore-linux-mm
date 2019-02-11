Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F5AFC4151A
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:36:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0A3F222A2
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:36:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="n7nfDm/D"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0A3F222A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6FBFE8E0149; Mon, 11 Feb 2019 14:36:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A9DD8E0134; Mon, 11 Feb 2019 14:36:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 573A78E0149; Mon, 11 Feb 2019 14:36:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id F18D08E0134
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:36:41 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id o5so29249wrh.7
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:36:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=D1a0L7OGkiUm/CdwA+tD4SnrFPDYPK1wPMaIJUcQTMU=;
        b=RIMHT1Uz6d3ecOo02P9AREmmIOwl4s3BDyfUy4AIDCs4UkAn0hbSFATQ1AYyUptVmV
         aOOzbqCvDFElgWGWh7sb9BMB9m7a56FIFdN+n1xWZOMzft2Ub39/mwUR/lTdT5NFwT+9
         fLK1uhACV+iRH/Pal56a6LW+z5cVrEgCLGRvKlmMi4RXIlxBHQ+sJefL2D3ZZj4avC9Y
         3a60qKzGMBVngD0/RRm+iFABi+OC6/VXkleX7DNRZoeQJf96yomnYwaKM0NOrHSJx8KE
         u6NQITgVK6MFEwfNuklGbeClbatBPK5dmsckr9O6N6JwE9UrJGV0ggW3c87Hrcbv+lYk
         iCzw==
X-Gm-Message-State: AHQUAuaxzUvRihLnW5Wj+vVdWnl+7PgS19njJooAxhFxLYOoX2WqGMuD
	6dkqRbJt4+roSqhb7usp0GT+H7YGIh/yi45DfIMkZcVKcdDz7DkuRgzPbuaSU2wgqosoyXBRQzN
	5cCx9n8Y0/cm9t+BL6gHB5s9eBmHYRihiqh84JbzIq12Rm48aJIGIIXcuvb6apHNT8/UZBQPIuq
	ZqKUjV5nA3QT34XWMHZp8RI7/xavREoMG+SoaIdv7f9Y6a4CbEbDn8xvQ5+PEJ/Q9xQixTgUkfl
	ZmvqLwh4v8pq7fx+MlSqfwKJzvG1kITXQRnKeuWTYhhqpgBRjJhu81qN0U4QV/PfPQD5xmhKz0q
	ayWQNMUoN2rwLf1Fh5CiDYCodohdeQCNZZNgtgjme7LgsWP5hRjhY3rcKCMOB8oLtWPBn7vWOaK
	E
X-Received: by 2002:adf:ba48:: with SMTP id t8mr17155595wrg.147.1549913801583;
        Mon, 11 Feb 2019 11:36:41 -0800 (PST)
X-Received: by 2002:adf:ba48:: with SMTP id t8mr17155555wrg.147.1549913800637;
        Mon, 11 Feb 2019 11:36:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549913800; cv=none;
        d=google.com; s=arc-20160816;
        b=DfPEtxwHfKrj8XkY6XqcvozsJ6+uMNygo6qRrOxB6L4y8nRZrK2T96kjO+9gGBWQkl
         ARziS4H3z/e9wTfz5fwp4CazYsy82cZ0JrbjlMfJBaVWB/3yeUW8SNPqDDNFlO8rdDhH
         MdAi9J98m68RMA1AaO+l7gcua3TOY4c37ioqmF1aamLdCMsjISC7mmDRYaEeLBKMsy79
         +nPulVJaIk/DXpzCH6SD4FmVQ+tWur5AJ3kgiYqIS3tDHpQstN1VYLm7mEjdAuiTwfms
         rYspldcoMLbMkx3l95TMyeRBplLlyFlwcuPU5NIvcjrooF7A4oXFbB3/LkLZ3gKQx6om
         712g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=D1a0L7OGkiUm/CdwA+tD4SnrFPDYPK1wPMaIJUcQTMU=;
        b=I6ULELsoTUWiCl+SlTQ4xc15WiAYxRY8l8xpycfag34XzGUanu1Lx5q9fRUjV/YoIW
         co8wvsr48jhxictfHPqHJQ4re+BYZdR5SVOx2HWy9eNZvyYTYqeKi21s/a/ZniyFYu8V
         g0eqWQnNVXpOA3v/W4c4uoXbs4enTTcxYn5HuYuy9niuDyyWlp9ws/IvTfoymWUXx5aQ
         bmEK8xRJ5vl7KV47lf05HCMwPB6kW9JumZxTO589eCoNX0d2j3lM+1EkhTtEHq2jV3uw
         L8a+SGTRUPiYUCRq7c5LofbsNHdU68Au8tEVTtlA/GdzToe3RNB/2nBWLSeJOBcjqYd0
         n5Yg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="n7nfDm/D";
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l1sor3732115wrx.37.2019.02.11.11.36.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 11:36:40 -0800 (PST)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="n7nfDm/D";
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=D1a0L7OGkiUm/CdwA+tD4SnrFPDYPK1wPMaIJUcQTMU=;
        b=n7nfDm/DOfDnL23se9DEzD7Gng5WydSa6aLdnPMA63H8vEkIKqEB+OrdIlCoU34fkP
         N4cmX+uZsJuo2D+0RCkICRdcR3pBHws+wP5KXIfvW10gExLBNzKx4G1BUsCDAnpeM0gI
         2T6n3JUEKjsaqGfLolCtBNLr263gjj2S1jESfckSiGhCN8dzDxrlIRKaMaRPXZV+iM3f
         ep0DzxPJwJfV4YoPu17ACwBQLwkUEQPHHFfityMaGeQ57ljCxtas6o4Ff/04Ur5rjHYZ
         fyjxWlH0cPWSgrrE0yM9n0O3ms8eA3WUl3prmYRPBxZx3msDuPy/GMW2XpX1bh3RYfHd
         o6Yg==
X-Google-Smtp-Source: AHgI3Ib2q/0QJVb/6qpcqP9LGdsUeG0bWflyAb3+BNQ1U33M3QNkI4RiTzo7vzw9FTjKVPbrjNXMBQ==
X-Received: by 2002:adf:cc83:: with SMTP id p3mr11514429wrj.292.1549913799770;
        Mon, 11 Feb 2019 11:36:39 -0800 (PST)
Received: from [10.33.115.182] ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id e27sm23137197wra.67.2019.02.11.11.36.35
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 11:36:39 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH v2 09/20] x86/kprobes: instruction pages initialization
 enhancements
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20190211182221.GM19618@zn.tnic>
Date: Mon, 11 Feb 2019 11:36:33 -0800
Cc: Rick Edgecombe <rick.p.edgecombe@intel.com>,
 Andy Lutomirski <luto@kernel.org>,
 Ingo Molnar <mingo@redhat.com>,
 LKML <linux-kernel@vger.kernel.org>,
 X86 ML <x86@kernel.org>,
 "H. Peter Anvin" <hpa@zytor.com>,
 Thomas Gleixner <tglx@linutronix.de>,
 Dave Hansen <dave.hansen@linux.intel.com>,
 Peter Zijlstra <peterz@infradead.org>,
 Damian Tometzki <linux_dti@icloud.com>,
 linux-integrity <linux-integrity@vger.kernel.org>,
 LSM List <linux-security-module@vger.kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux-MM <linux-mm@kvack.org>,
 Will Deacon <will.deacon@arm.com>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Kristen Carlson Accardi <kristen@linux.intel.com>,
 deneen.t.dock@intel.com
Content-Transfer-Encoding: 7bit
Message-Id: <173B309B-21A4-4247-BF41-8C4D0267272E@gmail.com>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-10-rick.p.edgecombe@intel.com>
 <20190211182221.GM19618@zn.tnic>
To: Borislav Petkov <bp@alien8.de>
X-Mailer: Apple Mail (2.3445.102.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Feb 11, 2019, at 10:22 AM, Borislav Petkov <bp@alien8.de> wrote:
> 
> Only nitpicks:

Thanks for the feedback. Applied.

