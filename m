Return-Path: <SRS0=AzIT=P5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0571FC2F3A0
	for <linux-mm@archiver.kernel.org>; Mon, 21 Jan 2019 12:35:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B2DF82084C
	for <linux-mm@archiver.kernel.org>; Mon, 21 Jan 2019 12:35:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UF2COheU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B2DF82084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6765A8E0003; Mon, 21 Jan 2019 07:35:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6272A8E0001; Mon, 21 Jan 2019 07:35:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5175F8E0003; Mon, 21 Jan 2019 07:35:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id 24AC38E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 07:35:16 -0500 (EST)
Received: by mail-vs1-f70.google.com with SMTP id j123so10546912vsd.9
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 04:35:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=k+MSaycj/9KITYA6lfk8QZCRSnahwfifAXAEb5FjW38=;
        b=oTpdVsk1koqSLWJVg9nE0304uP3FCfstY9dsrsKFqkGl77WqTbMsBfJi5nIlSBBboR
         8e6nhS9MwOmUPWkvnLcmYNFIyTa10jhzrpGFqyWMSZqh0my//74x8T9PClrz6fxUkXLC
         L6qP9N+hQglrulvnTzUEwEWoos0VmlwxVPtgvHMVkYTI/ed9wz+Jxole8YvXBSoc94l0
         +FDRdM3NYEN3fSK2ITzCocNy73vLe6eflgZ0KEMHYfhhMtoclzOt6lkQgHjlwpjoryaz
         yXGDRs+AtUzQUabZ79rAmXLRN0nwy/GJ2yzCeWVQ4hokdkj42Hdo4nRvZq/ZG3+L05qE
         KIiQ==
X-Gm-Message-State: AJcUukfkneBdM0+oDQOt2S4kkG6Qe2NnTdUNaNW9EBpbc+Xh2gA/wzYk
	QckOn0TiZkbttym6A36qSYTAcVc+V+TgZU9iHzS+NlnEsmeCrM1w0Uli9xSCIoqp3UUxARQmL5k
	PFqvoRKkChz+47l37rtfsYWM21vwFYtZQJmoFTTBEU6SWzC4O2FTlhjLJIs7C9Pwa5eXHV7O5tG
	SS+WlUMTVfeM4BZ2k5sdJeGC8TZXlFvx/qO6/vm3yV0nM2FOpJAJqsNgC7TxTRuJsej+nbRmAAF
	6W0pte/vAeGXtETD8kUZAFWMoBUQkbCzcT/LXu2WBjidgcd9RfjmOXkaOPCxM7ZcdLf+ygYIzQx
	uiLIECPcCWBYZ2dUB8Jha1HU/FKrlWliNe4Y/Gk+S6puLK5LSx5FqOoR2QHP646cPm24OMPqIxH
	7
X-Received: by 2002:a1f:2cb:: with SMTP id 194mr11760824vkc.19.1548074115779;
        Mon, 21 Jan 2019 04:35:15 -0800 (PST)
X-Received: by 2002:a1f:2cb:: with SMTP id 194mr11760810vkc.19.1548074115199;
        Mon, 21 Jan 2019 04:35:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548074115; cv=none;
        d=google.com; s=arc-20160816;
        b=ZxBqPqi6S8EyYiIeTVqH7Hb30xQM8sVh3ah8uXuPoks5JuputPcbVxLhop8kPyt3y9
         vggtIJ0MJNSF32BoodrcXmF3nc/uj+f0rpIzYE0GMLWKXZYSPSdbzlslfJvewZvsfeJJ
         T44r7q/OF9TzV+x+NooXPf8RINJaRMHcDG/FG6DkozJYyV+s0F/gvBaBZ+n3Av6OvGEN
         DMWHNiLslmm0FJhCa7ANER0DqabWALiNim8fr9V7sxmyic0rLubTAmpfle0CaKfyN8EP
         5XzFMhc+i7RZ9YRaKF8EPm0Fz5wtHfF5YWHayYRi7kgrOsmK9g9A2GF6oS1LluJCVcx9
         bYhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=k+MSaycj/9KITYA6lfk8QZCRSnahwfifAXAEb5FjW38=;
        b=GP1KSEylSSPeMeSvPYpyzljJ/9z2ifyAl0DjZlFg0JMbHY8DvzzP4wzfvDr1yr+Vij
         nkACOTZAITNzX4LRderjX2HrA6IcuR6nqaBA7LwqQAFaQFKEMlF+edbAoePhQ3dx+ZAw
         PoIXH6cw6qoc5/C0Yo7i0yKONxzsG2/Z5KoN3QV14pMnLaebDMiyYZ3L40vc0XMAPb3z
         f0t2F9t6qFFUFLzm0ugrC5kj3IB9o1JTjO5ieztW9HTcY1A4Wxso/d8+azFeqdGJOFGn
         LfoZxeT/kzjzpsBroJsJJEOeozDsruGsjjrGIfghyPnp9bLf+8fc7l5vdmAl7fZzYeuc
         LT4g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UF2COheU;
       spf=pass (google.com: domain of pintu.ping@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pintu.ping@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l23sor7274430uar.46.2019.01.21.04.35.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 Jan 2019 04:35:15 -0800 (PST)
Received-SPF: pass (google.com: domain of pintu.ping@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UF2COheU;
       spf=pass (google.com: domain of pintu.ping@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pintu.ping@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=k+MSaycj/9KITYA6lfk8QZCRSnahwfifAXAEb5FjW38=;
        b=UF2COheUoysXjsRSEAmwWvy5ArpkdNfz58fuMsj0CWoKN6ba9PggydnGg8dWNnxGdD
         6xNV8hqPBGouluqMMVwCAfevMbvLnz4CkE/80V/tbf82hpdrnJ2eOhqlyJ560TEoeviv
         hS1PZ5IowjEB0S8s0cb0k+voFynUWiRACHTllvcoiQXgdAeZwPkp0wmy15M9i8bzcj8f
         xpMDexfrQSPWWR5ZuTjWHqb6unZrPRJeCqMpfCJ0DER/WUX69ez/UNghdh4iwX5ulSQb
         +uvO8W9H7y7pfSdTKxQGFCs/6HBfoKY939BGG/zfFk/Rq1zuEq4iDiHE7nlofiqJJKaG
         j1bQ==
X-Google-Smtp-Source: ALg8bN7BTMgsv7iqj35UyxppTuxv/Y6UFsAvIzIcZL9zuwtmFozpjinsnmWFAZjBSG8GUGYxUb3A1UBWwOOmUHTeENU=
X-Received: by 2002:ab0:4802:: with SMTP id b2mr12152078uad.47.1548074114497;
 Mon, 21 Jan 2019 04:35:14 -0800 (PST)
MIME-Version: 1.0
References: <CAOuPNLj4QzNDt0npZn2LhZTFgDNJ1CsWPw3=wvUuxnGtQW308g@mail.gmail.com>
 <bceb32be-d508-c2a4-fa81-ab8b90323d3f@codeaurora.org> <CAOuPNLiNtPFksCuZF_vL6+YuLG0i0umzQhMCyEN69h9tySn2Vw@mail.gmail.com>
 <57ff3437-47b5-fe92-d576-084ce26aa5d8@codeaurora.org> <CAOuPNLjjd67FnjaHbJj_auD-EWnbc+6sc+hcT_HE6fjeKhEQrw@mail.gmail.com>
 <1ffe2b68-c87b-aa19-08af-b811063b3310@codeaurora.org>
In-Reply-To: <1ffe2b68-c87b-aa19-08af-b811063b3310@codeaurora.org>
From: Pintu Agarwal <pintu.ping@gmail.com>
Date: Mon, 21 Jan 2019 18:05:03 +0530
Message-ID:
 <CAOuPNLgM-aV51_L4WzwSGPQ4daVqWBgs8mQ8Gdw-f4Kdmadx1Q@mail.gmail.com>
Subject: Re: Need help: how to locate failure from irq_chip subsystem
To: Sai Prakash Ranjan <saiprakash.ranjan@codeaurora.org>
Cc: open list <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org, 
	Russell King - ARM Linux <linux@armlinux.org.uk>, linux-mm@kvack.org, linux-pm@vger.kernel.org, 
	kernelnewbies@kernelnewbies.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190121123503.93fcAke-HeJUVFx-pncBmwTXHZyYVinb3127EUX-qkY@z>

On Fri, Jan 18, 2019 at 5:23 PM Sai Prakash Ranjan
<saiprakash.ranjan@codeaurora.org> wrote:
>
> On 1/18/2019 4:50 PM, Pintu Agarwal wrote:
> >>>> Could you please tell which QCOM SoC this board is based on?
> >>>>
> >>>
> >>> Snapdragon 845 with kernel 4.9.x
> >>> I want to know from which subsystem it is triggered:drivers/soc/qcom/
> >>>
> >>
> >> Irqchip driver is "drivers/irqchip/irq-gic-v3.c". The kernel you are
> >> using is msm-4.9 I suppose or some other kernel?
> >>
> > Yes, I am using customized version of msm-4.9 kernel based on Android.
> > And yes the irqchip driver is: irq-gic-v3, which I can see from config.
> >
> > But, what I wanted to know is, how to find out which driver module
> > (hopefully under: /drivers/soc/qcom/) that register with this
> > irq_chip, is getting triggered at the time of crash ?
> > So, that I can implement irq_hold function for it, which is the cause of crash.
> >
>
> Hmm, since this is a bootup crash, *initcall_debug* should help.
> Add "initcall_debug ignore_loglevel" to kernel commandline and
> check the last log before crash.
>

OK thanks Sai, for your suggestions.
Yes, I already tried that, but it did not help much.

Anyways, I could finally find the culprit driver, from where null
reference is coming.
So, that issue is fixed.
But, now I am looking into another issue.
If required, I will post further...

Thanks,
Pintu

