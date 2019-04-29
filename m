Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4508C43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 02:06:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3CCC520693
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 02:06:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ozlabs.org header.i=@ozlabs.org header.b="ZDh+JJdW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3CCC520693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=ozlabs.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 862466B0003; Sun, 28 Apr 2019 22:06:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8195F6B0006; Sun, 28 Apr 2019 22:06:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FFD36B0007; Sun, 28 Apr 2019 22:06:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 386036B0003
	for <linux-mm@kvack.org>; Sun, 28 Apr 2019 22:06:04 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id r13so6467356pga.13
        for <linux-mm@kvack.org>; Sun, 28 Apr 2019 19:06:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ifUYKzvlVQ0C5bdH0fKRJjKjAZawWXmgnRh/ZT7iL88=;
        b=WF4x+IKKuwxDA6Igw4Zl9wMJVrNc2lzUyJPV1+Vz/JxaGDALSKp0ILdp+s73gnp7Be
         Iu130qh77ws2R00CEqRhlIOGZsQ3ox5/NXwwxmRhD5o1f3U/oc4+jvhWoFxGNsuleQHZ
         ZHzA0jByv06jUUb6pcWnMqjwdRVM2qj7P+cbhfIL49SANTgbuZkevFNJMmdQwA6VGNDL
         FFTt3c7D4ZiWgcwolUKTQCmhfMgLnCNE5cKoa5agp/D0OSK4bAZ2kfs1JdLyLdthEuMr
         zhDhNTYYVNnSb7zGR9bofFBJFoch9mk6ptCG9pQFjldI86qR2Yujlmq5FmTXa9mxNyRz
         V54A==
X-Gm-Message-State: APjAAAVE6Q6yP13iYY8+YaGbNnGd7Hl4nCm08uGdwWhsLPPdb7uA1FTe
	GXqtEItsRUA6HJNsC+NyNtVxI0X9cmfoVy6xGmkQB0IrP7RZMIcvTw2JFmlWrJFqlnJdikPTXDQ
	JmZg2p8S0Qbjq0TCm+te08PUCwkOP3Ab5FoJRjRonuCGtkQpsJiyfHzYoNiqT0Xhfjw==
X-Received: by 2002:a62:e411:: with SMTP id r17mr15215857pfh.127.1556503563689;
        Sun, 28 Apr 2019 19:06:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwV7glKHsB+HbcWJBVNpsOTeBTEwxxYhllaS0uZg8h/uCuPKcRxbuSj+s39flMEh5mUJqR0
X-Received: by 2002:a62:e411:: with SMTP id r17mr15215786pfh.127.1556503562498;
        Sun, 28 Apr 2019 19:06:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556503562; cv=none;
        d=google.com; s=arc-20160816;
        b=Q9e7HHcy7QiA15SfNdW5uF7pI1mgFXFGfSZk+kyrrKT3fNe40i22PoxDpY8u4dm+J6
         yTfH3z7acMKzRIafAL7koQlziOfOefSI+sT9oulgL+6W4JSB1PB5aWresX42oDkTbUZg
         UFMy+ZLYiDgfps3iSWZk+HgDWUqHaRVokk6xyeX4Z1dB+eDgLIJ/NGDbAT5K3Y7m2fUR
         /HnnJA6sN26ohAHOHCZYJmVcBviUYcyDCqPZ6ovftb+wBmgPN/ewseX1i2fINJbWh7mW
         PKrxq7qxqhv7gWvLioqhqJnKGSdUwqqYwxRvX5x7w6rgafwyb14+ZTJTvOsCy8Odzqz9
         HHDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ifUYKzvlVQ0C5bdH0fKRJjKjAZawWXmgnRh/ZT7iL88=;
        b=n3Nq/oYqUDjIu/05ohbHTTM5nK2wVmEyWyVFEeTr2kMuCTYGvmb8M6VF/LWNQO6Llt
         T7Iy5f+ZlE3JtYevyWArNad5VQeqpsE17offWytb0j2yxjKajhwmINwJOxd5+aY/ofHx
         jP/wOSjcI5bXNDrCm8OMEIy2ExksHUXt8gEh0LpDoew/jbE8o9CdURvRLhNWRgroXa7M
         6KhOVNxX3oiG8sT2l98wyEWpM7g5ly0FHTPM0moKaP5HroxC/YwM8NcyCAaDIokKjjfQ
         md4RYhoJt7ajGqZRJyBJv3YH5l89E2dM8dAbrq7wcmARmN8c8MvFrIk7PGYI5kqNhW+T
         sV9g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ozlabs.org header.s=201707 header.b=ZDh+JJdW;
       spf=pass (google.com: domain of paulus@ozlabs.org designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=paulus@ozlabs.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ozlabs.org
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id h36si29323437plb.50.2019.04.28.19.06.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 28 Apr 2019 19:06:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of paulus@ozlabs.org designates 2401:3900:2:1::2 as permitted sender) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ozlabs.org header.s=201707 header.b=ZDh+JJdW;
       spf=pass (google.com: domain of paulus@ozlabs.org designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=paulus@ozlabs.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ozlabs.org
Received: by ozlabs.org (Postfix, from userid 1003)
	id 44sp0j4Vkwz9s7T; Mon, 29 Apr 2019 12:05:57 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=ozlabs.org; s=201707;
	t=1556503557; bh=C9jMjFQh8bIIcTLpSucBn3+IOPxRQfPJx62R3f27fHA=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=ZDh+JJdWNbUnjZwYJ2OgXrlC5Te6OdRn22WeQuX4mEFi/3J71pfQo+39F6D6VmfIs
	 gN6aTHh8fhD28hDxoQTNfGh80vVwOayHLTgGy/WObYcwr29+LgPtSFjpNYGvpucq7e
	 RFvR2OWhFp0B7fWmnkVIVl5FSX1jogLJM1ivdGOqA7fkxhMHaDiTR0CdT1LUZLyBXU
	 kNwsUKwXM2eBaXfB8xSfPnOIqb8nOoKndLFvhgA8sb3l7oGWYMgduupXvs/dphOqD1
	 8Md0UWqf3a3EcS154gfVMUDHZtwTRPKEseYrZA6+ZANLVUVipPwrDyKTM5PLPIDLER
	 jBXEXZZQAZv0g==
Date: Mon, 29 Apr 2019 12:05:55 +1000
From: Paul Mackerras <paulus@ozlabs.org>
To: Steven Price <steven.price@arm.com>
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>, James Morse <james.morse@arm.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will.deacon@arm.com>, x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Michael Ellerman <mpe@ellerman.id.au>, kvm-ppc@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
Subject: Re: [PATCH v8 05/20] KVM: PPC: Book3S HV: Remove pmd_is_leaf()
Message-ID: <20190429020555.GB11154@blackberry>
References: <20190403141627.11664-1-steven.price@arm.com>
 <20190403141627.11664-6-steven.price@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190403141627.11664-6-steven.price@arm.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 03, 2019 at 03:16:12PM +0100, Steven Price wrote:
> Since pmd_large() is now always available, pmd_is_leaf() is redundant.
> Replace all uses with calls to pmd_large().

NAK.  I don't want to do this, because pmd_is_leaf() is purely about
the guest page tables (the "partition-scoped" radix tree which
specifies the guest physical to host physical translation), not about
anything to do with the Linux process page tables.  The guest page
tables have the same format as the Linux process page tables, but they
are managed separately.

If it makes things clearer, I could rename it to "guest_pmd_is_leaf()"
or something similar.

Paul.

