Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1BDBC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 16:44:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8262F208E4
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 16:44:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="uWq2IC7v"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8262F208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1CE956B0006; Mon, 25 Mar 2019 12:44:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 17E076B0007; Mon, 25 Mar 2019 12:44:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 020FD6B0008; Mon, 25 Mar 2019 12:44:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id A47C66B0006
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 12:44:29 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id u6so1151537wml.3
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 09:44:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :openpgp:autocrypt:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=NSY5EkU+HnGH2HB3kclwoIJRstfiL3cyMYhG7Hik+t4=;
        b=rYA1PSqNUQWqVlylJczXR3e+6kOjPP+1zhKhrNHPLDpdg8Nwyet9r/VwNXeEsOFNsu
         zEY8YV3pm1j+VrMTg/2dLk7XNePKzasbisEWKosDMzhEVlVDnr9kkSXpvxI5AsyGZFEr
         /NpMm9wOfxnPQ0RhnDPxUObBQiaBd1hhnZ4QtT0jRdpVCGCH/kbAz9XYBB+zeQj/y6KX
         yB9KQVsNwUDVXfyL/RtV/dtYfg3x4sImmK3/gZsVbuE3twAxXYBkuVcagA5FdcOL29ZE
         9RvN0rKOTGd9B05OebIBoJlokbPC7inWWBccwntQDoLYN7A7yURj3mTisUCS2aGDoyw6
         p5Gw==
X-Gm-Message-State: APjAAAWqDzA25+M/OJfgMYChcLhiTzEoJ2HmFaKXqjx8YBKr9VBGxP1S
	UBTcKp2q2wGIwFvmM+1he63TyLYS48pjgxMAq6jpLxtpjTb41f5C52xorMrOW7M63g9LV0AZ2Xq
	sb7A/5IfC5gfuCHwojy0uOiVhOTnAu3kEvPdPK5fbJ0YMagd+2ekpVJDJTOtQm+NKZg==
X-Received: by 2002:a05:6000:12c7:: with SMTP id l7mr15273235wrx.4.1553532269203;
        Mon, 25 Mar 2019 09:44:29 -0700 (PDT)
X-Received: by 2002:a05:6000:12c7:: with SMTP id l7mr15273200wrx.4.1553532268439;
        Mon, 25 Mar 2019 09:44:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553532268; cv=none;
        d=google.com; s=arc-20160816;
        b=qzxRg+nagzJvqfpJsINlg5cAdVmlz5bnaAXnXKUnQ5hEDYZexfo549OXoUA0Esoage
         azglhPk4Z9i4+9xMLcrJKe18Dd0DXHO+/tQS3hVJIGR7nuGmhCcg43PF4FOk+vixURWF
         fX6Xvpv9B3O4VJ5kLa68XZ0z6jmOCH4PsmlMBQnWhLwdFc8nNq7FqOqxEWRpc++CVsCe
         GOS+Liggzim/qGiasyPcbtu3qSLw4qtvsFVmJxFnXhkdGPAeZLEJfQoXMlfyxMUC2K8O
         kNG4N0edbHxb417KSOG3d1GCy2iUeRW0e6Vb1cAbQvrnFAmd2L4iPjS5nDC/Tj4/TcRZ
         VMHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject:dkim-signature;
        bh=NSY5EkU+HnGH2HB3kclwoIJRstfiL3cyMYhG7Hik+t4=;
        b=ux20N66IDTXyJX+88+rPOJQpT96jbpIk8DoyXo4iif9/8BuoLfwyAuZCOOo1ATVmHW
         bbDfLeMyP8NzQGO7Fbi2eW0qaTZdDppzPes5lAsEjMiNLzfSl2xp8kqXBnPbPOfLI7P5
         JXLM9uHgbdE9WOkrTkuIkI7IJn1MV4wwhDlfFaVkZTnJc8/j2oplB7n4pr9ecl3N+0T+
         BHWO+qHDpOy3zn8CovoRTLDKCBr5M8xLF99EFRElxeE54DctyHgdJk0/tN+c+il9K3q6
         /dmc6EjpJNGmAoLdSEP4FaiR/xmPD8xJ6Lirw2bkJ2Y9Mu07mFIEk06VhT1lCMNvDQNE
         6Avg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uWq2IC7v;
       spf=pass (google.com: domain of f.fainelli@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=f.fainelli@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b6sor4386564wro.35.2019.03.25.09.44.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Mar 2019 09:44:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of f.fainelli@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=uWq2IC7v;
       spf=pass (google.com: domain of f.fainelli@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=f.fainelli@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:to:cc:references:from:openpgp:autocrypt:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=NSY5EkU+HnGH2HB3kclwoIJRstfiL3cyMYhG7Hik+t4=;
        b=uWq2IC7v80rd2dDJL2ZGY2d6q0F0j+4eANf+70QxyHjeKCR92EC59ZJTvB51S83KJs
         VchT1a9/rEPKp1XeLd4LQnMzKyRBj3Y5PgiNhudWPgD/Dze7L6UTX4iikiPHnu0WrMZc
         G37NEIswHw3otFUXGmslgIZxX3QSEbCbdusgrUmdqDfRYc3pcFXykZySqh4enVrtiUU9
         BMmK0ANt47eYDD7dnlpTto3rYf/diccySvN7lKMURFakmIFo+II8xBs/8+foQLKWSeUM
         BFQGAxbLAsLXfRfXgVRo4epx5dxxx0nXpmY8WuSWlnSxZXq6O1InMTOHdc04XjDfsC15
         zdUg==
X-Google-Smtp-Source: APXvYqyY6oZz4yWnt5x5aPIVtRQfDGGu8qZyPlOF/+TkRHBLNmgRijjVW43+yKepgDP95t9lQrc4ow==
X-Received: by 2002:a5d:4646:: with SMTP id j6mr5841417wrs.56.1553532267961;
        Mon, 25 Mar 2019 09:44:27 -0700 (PDT)
Received: from [10.67.48.231] ([192.19.223.250])
        by smtp.googlemail.com with ESMTPSA id b134sm35248839wmd.26.2019.03.25.09.44.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 09:44:27 -0700 (PDT)
Subject: Re: Why CMA allocater fails if there is a signal pending?
To: Russell King - ARM Linux admin <linux@armlinux.org.uk>,
 Peter Chen <hzpeterchen@gmail.com>
Cc: Michal Nazarewicz <mina86@mina86.com>, peter.chen@nxp.com,
 fugang.duan@nxp.com, linux-usb@vger.kernel.org,
 lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
 linux-arm-kernel@lists.infradead.org,
 Marek Szyprowski <m.szyprowski@samsung.com>
References: <CAL411-pwHq4Df-FsBu=Vzd4CR6Pzee2yR579hHeZuh8T7fBNJA@mail.gmail.com>
 <20190325102633.v6hkvda6q7462wza@shell.armlinux.org.uk>
From: Florian Fainelli <f.fainelli@gmail.com>
Openpgp: preference=signencrypt
Autocrypt: addr=f.fainelli@gmail.com; prefer-encrypt=mutual; keydata=
 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
 M5kY0ACeNhCZJvZ5g4C2Lc9fcTHu8jxmEkI=
Message-ID: <7905eeb4-51ce-956b-31ed-33313bcfe7eb@gmail.com>
Date: Mon, 25 Mar 2019 09:44:17 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190325102633.v6hkvda6q7462wza@shell.armlinux.org.uk>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/25/19 3:26 AM, Russell King - ARM Linux admin wrote:
> On Mon, Mar 25, 2019 at 04:37:09PM +0800, Peter Chen wrote:
>> Hi Michal & Marek,
>>
>> I meet an issue that the DMA (CMA used) allocation failed if there is a user
>> signal, Eg Ctrl+C, it causes the USB xHCI stack fails to resume due to
>> dma_alloc_coherent
>> failed. It can be easy to reproduce if the user press Ctrl+C at
>> suspend/resume test.
> 
> It has been possible in the past for cma_alloc() to take seconds or
> longer to allocate, depending on the size of the CMA area and the
> number of pinned GFP_MOVABLE pages within the CMA area.  Whether that
> is true of today's CMA or not, I don't know.
> 
> It's probably there to allow such a situation to be recoverable, but
> is not a good idea if we're expecting dma_alloc_*() not to fail in
> those scenarios.
> 

This is a known issue that was discussed here before:

http://lists.infradead.org/pipermail/linux-arm-kernel/2014-November/299265.html

one issue is that the process that is responsible for putting the system
asleep and is being resumed (which can be as simple as your shell doing
an 'echo "standby" > /sys/power/state' can be killed, and that
propagates throughout dpm_resume(). It is debatable whether the signal
should be ignored or not, probably not.

You can work around this by wrapping your echo to /sys/power/state with
a shell script that trap the signal and say, does an exit 1. AFAIR there
are many places where a dma_alloc_* allocation can fail, and not all
drivers are designed to recover correctly.
-- 
Florian

