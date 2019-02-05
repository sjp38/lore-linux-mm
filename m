Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 252EAC282D7
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 09:18:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB85A20844
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 09:18:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="lHmUoXPY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB85A20844
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A4498E007D; Tue,  5 Feb 2019 04:18:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 653C68E001C; Tue,  5 Feb 2019 04:18:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F4798E007D; Tue,  5 Feb 2019 04:18:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id E90938E001C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 04:18:52 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id o5so893091wrh.7
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 01:18:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=27z0ZYNcv37KAn9EWdpLBTvefC4+qLAJthht315+v24=;
        b=kdsYhzysL89M8bmko55oAMwRMAAPXvginyiNBeMkfA7yB68hUYdxufzD9vg36g6gzJ
         JgXYSsRqymZwvbbrePh3kR8lpZGCRwyUtgsTvXZX+5xEebgEb4kEUofEyZlPH0qVr1Dv
         hx3eHsPvu2mUNz0S1w2cyFPrWCY3nGDlsJBIb7k4MxCx5a5Mzu4IGKqaP+/iPLqurJX3
         FV3riPFlRSuP/OrO6fXTXSI2SfsPo+NOdWtV643QpoElpvGJbEP5rG7naL0MWDPSc/9C
         cg8syQ9e6t8tC23QWEOJpw1FS09Ljhb/QxKsDQZoOjVb24TyddCMIfyt1OseaGk+Dn9F
         iv5w==
X-Gm-Message-State: AHQUAuZyCJ1ftKlIENTTCl2GeDuI73SVvwQ5782UTaSNApsj2/ZnAI0T
	fuWnBUmdwQ+B1w+a7EziFZjMvCobjlrvye4m3bk1DqnDW76IIFK4hPB9QFPn5Ad5z75vvMyHa+t
	xrpkccSmrtQI8xq7S77iuWXD6+BptRuItueqOFXawCovQhae9E8crtWMzVWS5Q8NH9Q==
X-Received: by 2002:adf:fe83:: with SMTP id l3mr2918988wrr.117.1549358332510;
        Tue, 05 Feb 2019 01:18:52 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZlzfIcozrWHYtPgzFppIdViVZwecsEOGuA9V+8sW+Sh02LX4v+dtpuj5/vt3JwUIncWsuc
X-Received: by 2002:adf:fe83:: with SMTP id l3mr2918941wrr.117.1549358331564;
        Tue, 05 Feb 2019 01:18:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549358331; cv=none;
        d=google.com; s=arc-20160816;
        b=GXTsx3FdZ4TyeJ4ab2alRvU882hUpM5tS7KY8VwCt8cYSLw4MaDZGI4WVaf4aNLbmO
         7N5874JHS3opPA3Dzk9/KvtH64hRHZNYOXRZZeZu3qjYj2VvQi3X9+BbGmDThdJvT33b
         p0ENxx+4ErmTw/+OXh72Cr0BrV7m8ma50RqcSlaFLsJwxZ7yoibLyURkegO9+brpBfEs
         YEYn2dRHyeWw/MavEe/Yg6CPXOBNIee+5Rvz+OqNEEnvbRwP8tnlT93zzp6l9EO5VLIf
         n2MG3w9DvQ7/nT92Bvxm6pCbwEzqDIWoWuZMWUQGxsFGhvMIgf2xqmA+GzBK9zH55wA6
         yWjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=27z0ZYNcv37KAn9EWdpLBTvefC4+qLAJthht315+v24=;
        b=EoqINfiYEFFMPyNY5h2T4fMlzuTXhsUlQYo5170X8jhShZHFOQFg+N01X4nTEWnwKa
         +/Yc7WEfC8X/2cnSOTfT4R9yRyvmh3WMER78hM9cE53Gu2AsrPr+LFF6LIFxzwiHpxwh
         K5xj8DPtSND3qxg5hnSVrnx2bJW1FBppCQhJVxeECd66f+FpNoAPN2sX5YZZzEgDpzMD
         kPYdbiGyShXbnVkLIMfyvXqjawL7z+1cUQezr4U22kfiEOfrqCSQkWzPgtEW0E/VzQLg
         Mq/3YeAvVtBOlkSb+JKcFs8mYSz3uiR8LhX9Jsl8ib0mWcpxZQiaYN9Elx2/1VRfdWdG
         TWRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=lHmUoXPY;
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id e18si5143942wrw.126.2019.02.05.01.18.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Feb 2019 01:18:51 -0800 (PST)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) client-ip=5.9.137.197;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=lHmUoXPY;
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (p200300EC2BCB6B0041C3B5D5EB4D55D2.dip0.t-ipconnect.de [IPv6:2003:ec:2bcb:6b00:41c3:b5d5:eb4d:55d2])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id C4CA01EC02AE;
	Tue,  5 Feb 2019 10:18:50 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1549358330;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=27z0ZYNcv37KAn9EWdpLBTvefC4+qLAJthht315+v24=;
	b=lHmUoXPYkWLZS/JSO0PVbQzoLRAdR0EjlaGqBzoguPTBfePCmw46XVjYaic1MT6q92G6I6
	JRB/OdTUe32hWMX2ytZm5EDzC9y4VLLamRgY2c333m92lAfUlzBCTXfy1SDy+YCiil6x9G
	6ps4QH+9C5H1UYRDZu1yx+DDOiyUr+M=
Date: Tue, 5 Feb 2019 10:18:41 +0100
From: Borislav Petkov <bp@alien8.de>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org, x86@kernel.org, hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>, linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org, akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
	will.deacon@arm.com, ard.biesheuvel@linaro.org,
	kristen@linux.intel.com, deneen.t.dock@intel.com,
	Nadav Amit <namit@vmware.com>, Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>
Subject: Re: [PATCH v2 05/20] x86/alternative: initializing temporary mm for
 patching
Message-ID: <20190205091841.GI21801@zn.tnic>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-6-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190129003422.9328-6-rick.p.edgecombe@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Just nitpicks:

Subject: [PATCH v2 05/20] x86/alternative: initializing temporary mm for patching

s/initailizing/Initialize/

On Mon, Jan 28, 2019 at 04:34:07PM -0800, Rick Edgecombe wrote:
> From: Nadav Amit <namit@vmware.com>
> 
> To prevent improper use of the PTEs that are used for text patching, we
> want to use a temporary mm struct. We initailize it by copying the init

Please remove the "we" from commit messages and use impartial, passive
formulations.

Thx.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

