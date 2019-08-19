Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECDBCC3A5A0
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 15:46:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B115522CE2
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 15:46:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="g1nXlHoC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B115522CE2
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4CF3C6B026E; Mon, 19 Aug 2019 11:46:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 459216B026F; Mon, 19 Aug 2019 11:46:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3212F6B0270; Mon, 19 Aug 2019 11:46:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0128.hostedemail.com [216.40.44.128])
	by kanga.kvack.org (Postfix) with ESMTP id 0910E6B026E
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 11:46:26 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id A06D1181AC9AE
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 15:46:25 +0000 (UTC)
X-FDA: 75839604330.27.jewel19_5525edba7845b
X-HE-Tag: jewel19_5525edba7845b
X-Filterd-Recvd-Size: 4295
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com [209.85.210.196])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 15:46:24 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id f17so1386607pfn.6
        for <linux-mm@kvack.org>; Mon, 19 Aug 2019 08:46:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=yBo5l6Hb3i4HlgUMt0iRUlNpHTn17B/raGae53BLtlo=;
        b=g1nXlHoCW7Y2bR1cRffuS4BNOtNrOe4CRBULxbwa13Z2T1F/a5TXCs/ygYuh3oJpQ6
         iP9w/DB2iE5KseeaCoduO9chHspnlj7HeAyriaYqmf10ipcW7mCi/0Eo8NM8dvhRD/Hx
         Os8in9EMk2OfaRBYl2cEpm5IXC3V7vGcD33PouZWEjieE1Pj+je2Nn7CaFF5BZvonZEg
         u/VzJS+Hh/sdPpYsAqxeVCaiJsfiwPNG/PICBeFKxv0wfCAXdG6WShSIhktx1rp96BE0
         +xWyt40ufdMRvdwQUi3opN+XtIpHJ8cXudqQeN1u2+KGLLvmxDa1RGlF7itwhCQRAOWu
         FM6g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=yBo5l6Hb3i4HlgUMt0iRUlNpHTn17B/raGae53BLtlo=;
        b=p4j130l6Vv2zGbAnyjLOf5+SBH9nevEjMsViP6sZ/ONEFjCeB3xeoVsFWoxpTIjTJ+
         A+Yz+CzlJ1+shhHQTtc/7HhL2d5Yel+MQj5r6omfTL54HDBQY8KD4GSNuFxnSVpzhmB5
         sT0ppj1HyhqYra6YxaF9KDM42reiEkGT41JIb7UprOouzmZeE2/wiSYztphD45Wo42ku
         rW6J0xVPtpVY26dpzI512n/EyGPGS6lIbXR3IWRt3opVogFwSHZzzHpgQ+vIUMN9ouNN
         VfX+Wr1C7c8hbFzvW/Try2qQSCgP9qr/MANUnsbOcnPrlUaQMje6Y5PwYWSiJi0rYnXv
         IlPQ==
X-Gm-Message-State: APjAAAU9NTIt7Fk7fg/t6bRK5rdC0SqQEot7ibEAqWdQ2fWEabBp4LVY
	0rTPPFbRyotQZcB+J1OXi/1My6TCo+NmK0aWwq6oBw==
X-Google-Smtp-Source: APXvYqwspcK95c1b7EzpNDYbzikjHPsqF9/mQX2RFrao6OHlpeBL0OGlH5Hg7JHZ2diW7v8MOGMj1LGIgGpYj/VFqkM=
X-Received: by 2002:a63:c442:: with SMTP id m2mr62735pgg.286.1566229583644;
 Mon, 19 Aug 2019 08:46:23 -0700 (PDT)
MIME-Version: 1.0
References: <20190815154403.16473-1-catalin.marinas@arm.com> <20190815154403.16473-3-catalin.marinas@arm.com>
In-Reply-To: <20190815154403.16473-3-catalin.marinas@arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 19 Aug 2019 17:46:12 +0200
Message-ID: <CAAeHK+w7Y=UgwTyjyVt6bBSi=DZROkMaz1B6-0BefK3AjSPpYw@mail.gmail.com>
Subject: Re: [PATCH v8 2/5] arm64: Tighten the PR_{SET,GET}_TAGGED_ADDR_CTRL
 prctl() unused arguments
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Szabolcs Nagy <szabolcs.nagy@arm.com>, Kevin Brodsky <kevin.brodsky@arm.com>, 
	Dave P Martin <Dave.Martin@arm.com>, Dave Hansen <dave.hansen@intel.com>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 5:44 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> Require that arg{3,4,5} of the PR_{SET,GET}_TAGGED_ADDR_CTRL prctl and
> arg2 of the PR_GET_TAGGED_ADDR_CTRL prctl() are zero rather than ignored
> for future extensions.
>
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>

Acked-by: Andrey Konovalov <andreyknvl@google.com>

> ---
>  kernel/sys.c | 4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/kernel/sys.c b/kernel/sys.c
> index c6c4d5358bd3..ec48396b4943 100644
> --- a/kernel/sys.c
> +++ b/kernel/sys.c
> @@ -2499,9 +2499,13 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
>                 error = PAC_RESET_KEYS(me, arg2);
>                 break;
>         case PR_SET_TAGGED_ADDR_CTRL:
> +               if (arg3 || arg4 || arg5)
> +                       return -EINVAL;
>                 error = SET_TAGGED_ADDR_CTRL(arg2);
>                 break;
>         case PR_GET_TAGGED_ADDR_CTRL:
> +               if (arg2 || arg3 || arg4 || arg5)
> +                       return -EINVAL;
>                 error = GET_TAGGED_ADDR_CTRL();
>                 break;
>         default:

