Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5EF26C3A59F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 20:43:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 129D22173E
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 20:43:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PAg0D/hp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 129D22173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B59726B0008; Thu, 29 Aug 2019 16:43:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B09F46B000C; Thu, 29 Aug 2019 16:43:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A1F936B000D; Thu, 29 Aug 2019 16:43:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0020.hostedemail.com [216.40.44.20])
	by kanga.kvack.org (Postfix) with ESMTP id 7ED566B0008
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 16:43:34 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 0114762E8
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 20:43:33 +0000 (UTC)
X-FDA: 75876641106.08.boy18_3c312d7a6ea09
X-HE-Tag: boy18_3c312d7a6ea09
X-Filterd-Recvd-Size: 3334
Received: from mail-ed1-f47.google.com (mail-ed1-f47.google.com [209.85.208.47])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 20:43:33 +0000 (UTC)
Received: by mail-ed1-f47.google.com with SMTP id f22so5516355edt.4
        for <linux-mm@kvack.org>; Thu, 29 Aug 2019 13:43:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=HwUu5Uo8W7FWucPPa6v/Knz+oqJoCajx8nXIsYvP/bs=;
        b=PAg0D/hpJTA1UJ7qhrDyCtDlVxU9Q4kqmipKsOTMGSVjutteSc/cQVvsFNTL+64F7Z
         jiYefDbBACasXUgSPwDxUcQjDBfwoZ9vW31z2fZgdGFrbq8g3kgK0fIonU1q6h7I8heB
         ajP7p7/jNrjgIDBZ0/TrUm2GE6+VAHUanXQSVXuYDPxxVDvySWEIVtU/AJnU0zqVnaYm
         sVjd8m92/qLeMWNGTh4GHEPOR6BeevIwCEnlmnrYQi8R/RRo9HNZ40wOsaiJQhL7AZZn
         K0pnnvTTgP/cWltKuBmEKvXiIUFkVadMVBJQNxQsBET9A0yp1FJloD+svESABnZN/Vis
         Ozvg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
        bh=HwUu5Uo8W7FWucPPa6v/Knz+oqJoCajx8nXIsYvP/bs=;
        b=VmnB5xG98GKWh9G4ZSZgCJ9ZWaePgb4X9jTZLUaq8CZ9faDxLY1V3CagAcDTwu0TqI
         sdnnsHQ45evuPA0LVRuqeNX5fFdvku4Xk8OrSA3TcoaqedXjsh+1L4mvjpeYcvxCvzUO
         esanlS/rS7cplLvAJ0yExGCS/Fw+tT/vRSVrn+VTXD1V7R640ntuj4325YBJbBTMAISN
         pX3QZaCyHBJPxCF02lVl7N9ex3DyHKfiRiNVLXJ4qoxy5S6orDXpQYb+eY6AbCLbCVx0
         lLzFnrkFeZy2J5uZRC7jTEDFJr9casW1DZOLPMgg6h6UNKtTVlA7jRCkRkUMuIdLFIrC
         ztWQ==
X-Gm-Message-State: APjAAAUZjK/KRwlSvuUiAL6HJH4w1nAxPS29DqIkjBOi5CyAa6PN3prD
	NURr5wY3w4YIvxOMXdSjkyhw7p6hLkrWhJ5KAj9J/pCC1Ig=
X-Google-Smtp-Source: APXvYqwFZ9IZy4buJrMd5SqADQvorpMvUMwDTib6bDSmpenDJhMB2yL6jvfISi+OvadeE4Qw7/2NyY1dGwS90n+YxTw=
X-Received: by 2002:a05:6402:13c1:: with SMTP id a1mr4261926edx.106.1567111412017;
 Thu, 29 Aug 2019 13:43:32 -0700 (PDT)
MIME-Version: 1.0
From: Paul Pawlowski <mrarmdev@gmail.com>
Date: Thu, 29 Aug 2019 22:43:21 +0200
Message-ID: <CAKSqxP8QYJx5k1FnN=v996eQNBvAZDNr-xXXPNmHj8KGuhtmyQ@mail.gmail.com>
Subject: DMA mappings cannot be used by the device in a resume handler
To: linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,
I have an issue where the device is unable to access the system DMA
memory mappings in a resume handler. This issue is mitigated by adding
a `msleep(20);` before sending a DMA address to the device.

The following is the call flow during my device's resume:
pci_enable_device -> pci_set_master -> msleep(20) which I want to get
rid of -> a write to the device's BAR region with a DMA address. The
DMA memory region is question is allocated using dma_alloc_coherent
(doesn't matter if the allocation took place before suspend or during
resume).
If I get rid of the `msleep(20)` the device fails to read the DMA'd
memory properly and crashes itself. The 20ms duration has been
selected empirically.

Are there any better possible solutions to this problem? As far as I
am aware the device lacks any sort of a 'ready' register.

The resume code in question if anyone wants to look at it:
https://github.com/MCMrARM/mbp2018-bridge-drv/blob/ba0df879c6b64a59ac12f8d6f763b3e39fab49a1/pci.c#L333

Thank you,
Paul Pawlowski

