Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1FB9C04AA6
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 14:20:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D75D2084B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 14:20:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ft8P4O83"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D75D2084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ACD3D6B0007; Mon, 29 Apr 2019 10:20:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A7BB16B0008; Mon, 29 Apr 2019 10:20:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 992046B000A; Mon, 29 Apr 2019 10:20:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 615096B0007
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 10:20:55 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id a5so5462019plh.14
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 07:20:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=TO2quwiNR5yJblHIcZgxLZbgOYDCm0fx9p5rJ0zvPqM=;
        b=ZkSuwXiWwajsai+0HRrydHDThXWDR5REIL4AOkMJU5twQrU6F5B6QlfRh2oBu+WSBr
         /DixW4a12PNfS3heiJjA+aqZJC74aqodnPIcYRUHFHKwRdNLsW/Moc5xLXU309S2J8EA
         YUy6y3sibwRgKhDzUgX3mfiJZkUJj3TfrbLJYZ3Zix4gkTnseJWKa75Xz89OXBLyqyl8
         Sp7rtJNIEqiFm4OeZBMhQ/GqzPJGk57g/odLtD3KaSiKXKbpHRO0NU2LdAs2Me8Ha9tb
         /IwI+/i+tpH6QDgYpQUiRJ4OnHQOZxlQ3jq3uLz7MFHSHd/NgPZerendfw+DsFh4bRi6
         8Acw==
X-Gm-Message-State: APjAAAXPPKkR17lZ7TGJh8DW31RhWo43VCHRtpYxzEQ6SgXdHaG+wG5u
	sfXanEsd9JjLWd0aJRKZpd92xLbBwG1LPxAyAKa0wvRTWGRjaRaQpJ5qje1YSR3QpNtxchpTKLy
	g+qLdHwOAzftOt0a+AQIN3T9IN2EDHG7VvJxL9vDjOXlbGCs4dRZqns6ragbjAhrtgw==
X-Received: by 2002:a65:644e:: with SMTP id s14mr6128605pgv.290.1556547654956;
        Mon, 29 Apr 2019 07:20:54 -0700 (PDT)
X-Received: by 2002:a65:644e:: with SMTP id s14mr6128512pgv.290.1556547653813;
        Mon, 29 Apr 2019 07:20:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556547653; cv=none;
        d=google.com; s=arc-20160816;
        b=yIkgHUIPaMHq5zv3zJdhRFgmDnkp+DktxBE6xsJdjcrO1tWFCKw4k8k4Zy53GzVGCf
         4ESzP/Rwu0+9gJMXlWdZxtKFoezAzaEghQ6Eu7yEge1PGYFM/3FtabT1I32zmYMr6Cxy
         kP1ytYGxwDjPUTW7cim2reW9dAt+N7pd3V9rKcFFd0IKTLE+jDLpEzsiDvIHDwqYpsHK
         IqmrsPPVFQY3LvF0lYe/y6+O0vhAjurDm1PQope29phBBZj2SMtYGnq9v3U/aU1nhd/W
         CHgJaCdcoYoKTFNNwOwtfYyO9rcnOkfyvsS9DCTMC/O9Gw337hjTFoFldoA8aEHdSWvy
         2+Cw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=TO2quwiNR5yJblHIcZgxLZbgOYDCm0fx9p5rJ0zvPqM=;
        b=NqSfqeW6C69CMyLhd99L6C3I6XZJXVzyf4BSJjtY9fvrAV6k/yOFyWT9frsO6QDbZm
         ZdaFGUjP8BNm9xNACcz1AAkZSh60YYxanP5YEr9189yjN6Lom+rDDYN+/SMOR1xPJQNa
         m/BPQwAEGT/P23Hv7ypR5C3Ox2Yenhmond3Eeoy/zncToBjCVBhLZENKCT2oSEwMSH62
         /hpmNl+il4S0+PDyTzUc/TkQKSEDP1AIhP0xaUPFVpSAaUT1dY+/zERm6K304SnkUQxl
         64SPSCsZWip1Chl6Nz58bdGfOAYklHkT2dSF2jiNHKND+icAJss6qmnuEb1Jq7+flH/Q
         ADNw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ft8P4O83;
       spf=pass (google.com: domain of nishadkamdar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nishadkamdar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id be4sor16595732plb.25.2019.04.29.07.20.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Apr 2019 07:20:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of nishadkamdar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ft8P4O83;
       spf=pass (google.com: domain of nishadkamdar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nishadkamdar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=TO2quwiNR5yJblHIcZgxLZbgOYDCm0fx9p5rJ0zvPqM=;
        b=ft8P4O83KzFQvD8ubncSKWF2nbgiB3n/zTSGEm90HoxLKvrLSmOzTMyAal6sslq974
         e/RikpOTnTFYfnGU9r2DUB97U41GWmg6+83w/oYIioXaP72rY9wTf4++qulVX0gfNQbE
         xZkKOfxyrqXWTf3mqaDRjt57y+Lx/fAWtQjW1x5QVieTlerl6r3VCd2xyQbWQ79mh84N
         zUs3DQ5wYh4irTUABN1Uxf05iE+lbLZlJ9QVm52bt8Cza/dQob7UJ+F2VD2L1UHy/TlX
         GgSYNxyek47krautLrsCLiPUg2TXaUSGhtiwMlscJx5PFTP1O0EssJxg53wyCwu35s6C
         iISQ==
X-Google-Smtp-Source: APXvYqxhNAE4WrtTIHV/HhgiCDI91aTl3p/Pi2/ecloRq5bRRQn+vE4G9yQCBV/IqAJb96mzBGYcIQ==
X-Received: by 2002:a17:902:2ba9:: with SMTP id l38mr210415plb.220.1556547652685;
        Mon, 29 Apr 2019 07:20:52 -0700 (PDT)
Received: from nishad ([106.51.235.3])
        by smtp.gmail.com with ESMTPSA id h65sm110564714pfd.108.2019.04.29.07.20.46
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 29 Apr 2019 07:20:52 -0700 (PDT)
Date: Mon, 29 Apr 2019 19:50:36 +0530
From: Nishad Kamdar <nishadkamdar@gmail.com>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Greentime Hu <green.hu@gmail.com>, Vincent Chen <deanbo422@gmail.com>,
	Oleg Nesterov <oleg@redhat.com>, Will Deacon <will.deacon@arm.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nick Piggin <npiggin@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Joe Perches <joe@perches.com>,
	Uwe =?utf-8?Q?Kleine-K=C3=B6nig?= <u.kleine-koenig@pengutronix.de>,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH v3 2/5] nds32: Use the correct style for SPDX License
 Identifier
Message-ID: <20190429142013.GA12127@nishad>
References: <cover.1555427418.git.nishadkamdar@gmail.com>
 <f6a7c31f4e8b743a2877875ac3fc49ecb8b9eb0c.1555427419.git.nishadkamdar@gmail.com>
 <alpine.DEB.2.21.1904162034260.1780@nanos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1904162034260.1780@nanos.tec.linutronix.de>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 08:35:38PM +0200, Thomas Gleixner wrote:
> On Tue, 16 Apr 2019, Nishad Kamdar wrote:
> 
> > This patch corrects the SPDX License Identifier style
> > in the nds32 Hardware Architecture related files.
> > 
> > Suggested-by: Joe Perches <joe@perches.com>
> > Signed-off-by: Nishad Kamdar <nishadkamdar@gmail.com>
> 
> Actually instead of doing that we should fix the documentation. The
> requirement came from older binutils because they barfed on // style
> comments in ASM files. That's history as we upped the minimal binutil
> requirement.
> 
> Thanks,
> 
> 	tglx

Ok.

So according to license-rules.rst,
which says

"This has been fixed by now, but there are still older assembler
tools which cannot handle C++ style comments."

Now there are no assembler tools which cannot handle C++ comments ?
and the document should be changed accordingly ?

Thanks for the review.

Regards,
Nishad


