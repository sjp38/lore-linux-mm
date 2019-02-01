Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6299FC282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 14:30:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B8C8218AC
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 14:30:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="ACamr810"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B8C8218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A89CC8E0002; Fri,  1 Feb 2019 09:30:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A133A8E0001; Fri,  1 Feb 2019 09:30:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B50D8E0002; Fri,  1 Feb 2019 09:30:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 315D48E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 09:30:52 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id w4so2306308wrt.21
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 06:30:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=hGy3GLIGKGb9pinyZWtR7KgWAhS96C0NlmjqSrh8BOc=;
        b=M2F5oYK/FmMwhhHwVbD0SH5V/o+DuBrTmDkM3aOGfHFEus4aI0Hd3paOHGw+97Et73
         2UUoQqciDLM0eEiXR6P5MMrPf0HDTdpkZCpLDXibaV23xhnCgwEorabPR/RdOpKazSN8
         O5kc1PdWwqvNoC7bkH7scxtTAvM+Zjh5dCfwYe9vUMWdo8EooYIEROuMwuDXSrAHkm3m
         BzIiJQwoNp4R/ruVo6TuMMu/Cu8ED7nz/ToqA+taapl7yQdDkBRdGLSSZTtNfsZ7DlIN
         SVW7+VXs/hcniK20mPueaUr2tF6DA74RDlATasAG8HopJpZlncGwSHEgUH4Uth9nshsf
         BaqQ==
X-Gm-Message-State: AHQUAuare/HyvmtFg0TGCjrewljOVacQCAPFG7LJKH1f4M6TKI+/ggLg
	aeWRs4WYaB3dtDswk58aXWQG1mxy8Rqbx67k/GDykndLcedApARmOT/F/MveSP0/1hV8zxDTe4c
	2zwbsmXn1mzEaa2vMmATi2AMZFgXeFgtqX9k+3sZ6dvc+MEldratj6yd6xXslIIF/cw==
X-Received: by 2002:adf:fd81:: with SMTP id d1mr31598515wrr.105.1549031451742;
        Fri, 01 Feb 2019 06:30:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ5ub/u1gRDG5hdmkOTl/D67DfJE6NlYn5OTL9I+hIl686O+bIUJ1RNg56A9gmsKZuw36g3
X-Received: by 2002:adf:fd81:: with SMTP id d1mr31598460wrr.105.1549031450904;
        Fri, 01 Feb 2019 06:30:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549031450; cv=none;
        d=google.com; s=arc-20160816;
        b=qdl9wcdrWZNeQ9RNZfnL06tYfq15FNAVq0HcikWkItWKeQ/xxuKznY9swfVM0PgUJy
         GZFFefrmTew/LyMODc7E62svDPmbw03fJMaN3yo3tucuIMmnargbnr6DsG39lUQMknuS
         TwCOyvt17xCtACLezEoZzjaZa2RXIXJ/gqt5FSAm8tAXBG4k/P5xTzbTVJTNIfJfSOgv
         Qe92r7RTJ42ygQC7bT6spXtOTtgrnsv5IRO/WCi0JFwkRkzbuqIg4zOaZCZBJjPktenl
         lSx+kGygFJaBDe4Efnqe3W9e7ck2hH+RO+kcT3Gf67jAxgNWtfIgmacKuZktzObivUt2
         mP+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=hGy3GLIGKGb9pinyZWtR7KgWAhS96C0NlmjqSrh8BOc=;
        b=as0IzV6iQrGJIXNi2E18sHv8k5XvILvjgiKY8Gw5OXoPTvQBAu4/tuNvnX/H7Or1yt
         Gpc3yvLJJsOE7NcszVyyFk36lPU7b/XiXxD8PPj9z+6uIV5oVolYS5WvT60ojK71V5tj
         pOGAsyN+7x5yUVuweZLO3pf+5pAaNxN42o59/alVo8odsc02TVIRqZcouPKmoM9H/NqN
         LymXGawIfynFlpDihxMCuz2/L30yp4W2OJtMub+Wd+BcQu3pzj0UygJX4hI1kib/SlVc
         fxhhEAKdO/0Gbzej6ShRffsPwpGej0Ea5Op/tCZAETzwn8+OZY24sYNCbzalpMCckbhh
         xpsA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=ACamr810;
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id o7si1728646wma.116.2019.02.01.06.30.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 06:30:50 -0800 (PST)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) client-ip=2a01:4f8:190:11c2::b:1457;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=ACamr810;
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (p200300EC2BCC5000206D6264C5583287.dip0.t-ipconnect.de [IPv6:2003:ec:2bcc:5000:206d:6264:c558:3287])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id 0F3181EC00EE;
	Fri,  1 Feb 2019 15:30:50 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1549031450;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=hGy3GLIGKGb9pinyZWtR7KgWAhS96C0NlmjqSrh8BOc=;
	b=ACamr810wxngmD5P7ITX3jRkAM8RnQ7lgDj8hCv8KJNHwpHtx63zQ1KgDxJiOuw016BmFd
	8Gw3WEaVgFuLB124lpF+r6Jqk5+KaT5sjn6tzXCeRkOAmp2WJgWgMho3FOgLi8Txztc4UX
	vtNr0ctoByEfL3wPDJrQJo4deuKdilI=
Date: Fri, 1 Feb 2019 15:30:40 +0100
From: Borislav Petkov <bp@alien8.de>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	Marc Zyngier <marc.zyngier@arm.com>,
	Christoffer Dall <christoffer.dall@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>,
	Tony Luck <tony.luck@intel.com>,
	Dongjiu Geng <gengdongjiu@huawei.com>,
	Xie XiuQi <xiexiuqi@huawei.com>
Subject: Re: [PATCH v8 18/26] ACPI / APEI: Make GHES estatus header
 validation more user friendly
Message-ID: <20190201143040.GJ31854@zn.tnic>
References: <20190129184902.102850-1-james.morse@arm.com>
 <20190129184902.102850-19-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190129184902.102850-19-james.morse@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 06:48:54PM +0000, James Morse wrote:
> ghes_read_estatus() checks various lengths in the top-level header to
> ensure the CPER records to be read aren't obviously corrupt.
> 
> Take the opportunity to make this more user-friendly, printing a
> (ratelimited) message about the nature of the header format error.
> 
> Suggested-by: Borislav Petkov <bp@alien8.de>
> Signed-off-by: James Morse <james.morse@arm.com>
> ---
>  drivers/acpi/apei/ghes.c | 46 ++++++++++++++++++++++++++++------------
>  1 file changed, 32 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
> index f95db2398dd5..9391fff71344 100644
> --- a/drivers/acpi/apei/ghes.c
> +++ b/drivers/acpi/apei/ghes.c
> @@ -293,6 +293,30 @@ static void ghes_copy_tofrom_phys(void *buffer, u64 paddr, u32 len,
>  	}
>  }
>  
> +/* Check the top-level record header has an appropriate size. */
> +int __ghes_check_estatus(struct ghes *ghes,

static.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

