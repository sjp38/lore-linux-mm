Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EAE1DC10F00
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 20:17:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA27E218FC
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 20:17:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=googlemail.com header.i=@googlemail.com header.b="BOoXzi1T"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA27E218FC
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=googlemail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 42CD16B0003; Thu, 21 Mar 2019 16:17:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3DC7B6B0006; Thu, 21 Mar 2019 16:17:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2CCF06B0007; Thu, 21 Mar 2019 16:17:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id ECC7C6B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 16:17:47 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id h10so26529otl.20
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 13:17:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:from:date:message-id
         :subject:to:cc;
        bh=/wxyUvtToomdZ+5Q9o+FQ/M8e4o6ylXXt1G7gXDkthY=;
        b=a6fh3qeTyv9mI5LDN+WNE+5kXQs2TtU4NDv+UJEeY9Wa8CGRJw5EqRcblU725TBdc/
         2F1a2RiLyODZZGSoH+ZMqqzhRZYxo4JGqgjTsKbN9xaPIxud0gq1G7ZuApK+y2RZT6l2
         qrq2wjhCshqegSXZ4fa5CLz6Q5Gm8XyV/Rcdm3Ro42Ud+K307J8SaAK7HQNWUDFT+dUA
         +MDu8I27e0uEKCjLBmTx2LC0ckWoa3hJRpLk7HznypTXYAgmTZSjE2RV+eZIEJyaXIr/
         SfAj7AUmZN1bMvJB8TT9AQK4kM6jyrTohnk11J85i7JkWTlYBqxldXRftf70YoP9lies
         Tlnw==
X-Gm-Message-State: APjAAAVL/ColJFEge0/rCHz7M/G+XPTKjH+qNGCBZwvoNjHnUQFJI72C
	H9xKaO4j1PC3RMYSxGwuXBrrY+F0muUd2ShHXMsaQOJZEIB68HbIl/fRyGqOuWh0JvPs8NNWuzO
	9MA78Vm1vsmF0REcm/uhWUeOGaKYwKYu9kdhje4wYZCALMpzkoIQwWoJa6YCnGQcM1Q==
X-Received: by 2002:aca:d786:: with SMTP id o128mr834747oig.25.1553199467286;
        Thu, 21 Mar 2019 13:17:47 -0700 (PDT)
X-Received: by 2002:aca:d786:: with SMTP id o128mr834689oig.25.1553199466127;
        Thu, 21 Mar 2019 13:17:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553199466; cv=none;
        d=google.com; s=arc-20160816;
        b=ICvpjMgBsK1kAt07eTGZY/rIASpsL0BjYLtXuJBdGBqNxAMKrm7L7hCsI66jYuMz93
         vYmmwNtIH0bIwglXhBa8kWVN21IzvRULdLTamgctpXt3iMbrfHOkeoyDIQRFUjZYf1R7
         T1eCPo5Lb1RA2fS2S4RzE+YrLUW8Kg4Fy7bu0baCcjWXPZC/WcVPz6+80LQrsWqROnn0
         rcNdcOMD98QCCbAPklCHYEMgu2X/cnP5WEkbTl6YmzdPYZDLLUdDsD314aNpFwOKXH67
         usmo7G87/pzZFItNkflsEojiZ5zubUTb3QWhjtHeWkmmSD62I1ZsWNQoYF8917Z142Js
         LDxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=/wxyUvtToomdZ+5Q9o+FQ/M8e4o6ylXXt1G7gXDkthY=;
        b=WQJ6089xxp8h5s+q/e0YTunEXFkr8V4C1D26zsBQ8htl8oO3N5lXwbBPBAYGKSPI5H
         qtrhUIA87KEDbFp7K4PhLB5Bal8FXFt+qrLwQARdX8vr2Cs2vGvl+gCGH/69OFhWFE71
         nOBUks4hG7BvApXgufQlHWc/xiKMJZfDaJ/zfUKBxMqslKDGW6Az4jLcL0bwyOE3Yxr8
         lGAU24URrvlAf7O2K9ALEpJkI0IT9wEnH7Vqc0yS6NaP2Gc3kaummfp3YVAdh8VOh48O
         srBqwG5WxnpWy/PW/UZq/k8QC9IbYVmLi4804izvn58JhKLsmXYdjyzosr+bDfAubnuj
         hSSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@googlemail.com header.s=20161025 header.b=BOoXzi1T;
       spf=pass (google.com: domain of martin.blumenstingl@googlemail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=martin.blumenstingl@googlemail.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=googlemail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a1sor4159867otk.120.2019.03.21.13.17.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Mar 2019 13:17:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of martin.blumenstingl@googlemail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@googlemail.com header.s=20161025 header.b=BOoXzi1T;
       spf=pass (google.com: domain of martin.blumenstingl@googlemail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=martin.blumenstingl@googlemail.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=googlemail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=googlemail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to:cc;
        bh=/wxyUvtToomdZ+5Q9o+FQ/M8e4o6ylXXt1G7gXDkthY=;
        b=BOoXzi1TLXiHBJG+1HwL+ID2AnLv3oZT6PlJ1aORSU6oRHSSgjPMihc1eXyKPMdyD/
         AqFJYySnhXSr/0KJyrtQDtju9Fr248wnuBcTNenyPVOZ0PHV8QNzp2jvcn1CbBa6l+An
         GMsEqyRqcPt8vX6qgUAu9wZb5RYF6Ezu+PIvFDfPlByy+bkmb4Blb0cd9dqhuxowHTZn
         MTjTD4Bg8pQ9Q9xgazplzVmi36XlNjsp/avPctiTShRqAN8PfMdK3maZbLpXpzZCOXP9
         hrNEmNbrANp5WxgBJCzg9g832X4/sb7Ijvgq0pfVeoOJ2/arzBW23a2dvX/XrfcOvwke
         sHqw==
X-Google-Smtp-Source: APXvYqwUYsousOMTeeL8c+A2HnTXT2l2mWYx2JCiWrVy/yAmVWlPJppOWrh94pnxO/J9vbn6442DXbT8N9OeaM9xXRs=
X-Received: by 2002:a9d:5614:: with SMTP id e20mr3932876oti.348.1553199465574;
 Thu, 21 Mar 2019 13:17:45 -0700 (PDT)
MIME-Version: 1.0
From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Date: Thu, 21 Mar 2019 21:17:34 +0100
Message-ID: <CAFBinCBOX8HyY-UocsVQvsnTr4XWXyE9oU+f2xhO1=JU0i_9ow@mail.gmail.com>
Subject: 32-bit Amlogic (ARM) SoC: kernel BUG in kfree()
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	linux-arm-kernel@lists.infradead.org
Cc: akpm@linux-foundation.org, mhocko@suse.com, willy@infradead.org, 
	rppt@linux.ibm.com, linux-amlogic@lists.infradead.org, liang.yang@amlogic.com, 
	linux@armlinux.org.uk, linux-mtd@lists.infradead.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

I am experiencing the following crash:
  ------------[ cut here ]------------
  kernel BUG at mm/slub.c:3950!
  Internal error: Oops - BUG: 0 [#1] PREEMPT SMP ARM
  Modules linked in:
  CPU: 1 PID: 1 Comm: swapper/0 Not tainted
5.1.0-rc1-00080-g37b8cb064293-dirty #4252
  Hardware name: Amlogic Meson platform
  PC is at kfree+0x250/0x274
  LR is at meson_nfc_exec_op+0x3b0/0x408
  ...
my goal is to add support for the 32-bit Amlogic Meson SoCs (ARM
Cortex-A5 / Cortex-A9 cores) in the meson-nand driver.

I have traced this crash to the kfree() in meson_nfc_read_buf().
my observation is as follows:
- meson_nfc_read_buf() is called 7 times without any crash, the
kzalloc() call returns 0xe9e6c600 (virtual address) / 0x29e6c600
(physical address)
- the eight time meson_nfc_read_buf() is called kzalloc() call returns
0xee39a38b (virtual address) / 0x2e39a38b (physical address) and the
final kfree() crashes
- changing the size in the kzalloc() call from PER_INFO_BYTE (= 8) to
PAGE_SIZE works around that crash
- disabling the meson-nand driver makes my board boot just fine
- Liang has tested the unmodified code on a 64-bit Amlogic SoC (ARM
Cortex-A53 cores) and he doesn't see the crash there

in case the selected SLAB allocator is relevant:
  CONFIG_SLUB=y

the following printk statement is used to print the addresses returned
by the kzalloc() call in meson_nfc_read_buf():
  printk("%s 0x%px 0x%08x\n", __func__, info, virt_to_phys(info));

my questions are:
- why does kzalloc() return an unaligned address 0xee39a38b (virtual
address) / 0x2e39a38b (physical address)?
- how can further analyze this issue?
- (I don't know where to start analyzing: in mm/, arch/arm/mm, the
meson-nand driver seems to work fine on the 64-bit SoCs but that
doesn't fully rule it out, ...)


Regards
Martin

