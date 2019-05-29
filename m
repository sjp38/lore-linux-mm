Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B259DC04AB3
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 04:05:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6CE6121734
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 04:05:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ta44pz2N"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6CE6121734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 073186B026E; Wed, 29 May 2019 00:05:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 025796B0271; Wed, 29 May 2019 00:05:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E7C7D6B0272; Wed, 29 May 2019 00:05:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id CE9DE6B026E
	for <linux-mm@kvack.org>; Wed, 29 May 2019 00:05:18 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id j6so806828iom.3
        for <linux-mm@kvack.org>; Tue, 28 May 2019 21:05:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:from:date:message-id
         :subject:to;
        bh=qoCRgKEqb2cNIP9iBbmcP+1MshPj3Nktj6OiPwbarXY=;
        b=iAqsEk06u3PAHcU9plmABOY8cXmxox6ODQufajPuhSopUl5QlPf3J2+rnFJlNEmGB9
         qaEwTshEZ9zydnhxGgdoke8zwodDts4ffaFrV40tIdRqUsqxKtUhK9/Sty64LHSM8/d7
         hfUnWy9374v4vclP1/KWgExdzbouZiF9TkzSoPFzLphXYazyAOHIBSSPfREbORPuWFK8
         kgkg1tY3nlZHQYybGbA+aCcRUSFOM21/WpZC03fT/4qKHXimJ/9pBVDdcqxCqrsO5TVj
         D8F/z302CY2ko6S97DHiSlGjleePCGtmkVE33D5SO1CBfQ0SqPj2ogBtKEPToNlhb0ZR
         zgUg==
X-Gm-Message-State: APjAAAVKHumGaYJvMUJDP4mJuhK459HCpyoyFEbsswQHc9VdNHE7WWlB
	fKme5oQyJ2uaQQzlJTkyGyYvtWfn714ZJUrNk4fZiLe+H8dLXnxxSrywLO/kfOUtBvsBjJxcopO
	gmiPFWETCe+SK10/ZUTpIf+yI+M1s5oAFbbpS2iyqG60lt0wqnIZVLVV18dhV1kfEAQ==
X-Received: by 2002:a5d:8043:: with SMTP id b3mr72763569ior.115.1559102718561;
        Tue, 28 May 2019 21:05:18 -0700 (PDT)
X-Received: by 2002:a5d:8043:: with SMTP id b3mr72763550ior.115.1559102717668;
        Tue, 28 May 2019 21:05:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559102717; cv=none;
        d=google.com; s=arc-20160816;
        b=p+QPA3o6Vk/52wyWGhEDiR+DuFMoj13N98e9Grd7FSZA3Ueuqqrl+I1m/8hfjgjutT
         DS/Ogfw9sP1a9bTezzLj32C7T4mDNS1DpnDMdQTpBArZLopQS7heJObrrv9WrGlxU82o
         DskQnZiV69eG0RV3Ojxu1wCrAHMH81LHyYopqgIUrGACfG4stNrYSV0mgSbqXcHdEhTX
         l92gPyk4DtTpoi+sIEyds3WxfczhvXgjL+ByeJ2gAIVxgNoO3fOnSLfUNFWB/+UBhc5s
         lgQLXUsoVVjeneD+88a9KDqr/sCYVtbDeMPDB3KNd9TFUIsYWN/5y7scOpygU6fzDKl8
         ytAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=qoCRgKEqb2cNIP9iBbmcP+1MshPj3Nktj6OiPwbarXY=;
        b=G/kdpcE2ovzgAiwLNrmPJqn/IxALSYvqyzIccqsOFkJb4vyPcT785rKH/YuHSHbVGr
         V7G7euQ+9YFrpcHZiEdOfYr/ILPqHVF5m8i2jrENp0cb7I01Lj2eFoBA9jtUP2O+ji3v
         t0r8Icc7iBDfZy5JDTzZ1hb8iIm9Mpd/7H1FY+MkjSYCrlkUN/oXcH80uHwIoi6ONpO5
         OGZlBFZVWJ1ZBeVgnYFgSK+r7KdsRxyGjromHKxplFSXlJqS1GTpm1d9vpgFw79n8oK+
         +WtOCf9o1IqpHO9wtB5PUUw9xnklQ2FeQLcLrMGvreHeRzYei0c4IDkx5Svb3lw7Q9Uh
         oP9g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Ta44pz2N;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f1sor4241751ioc.19.2019.05.28.21.05.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 21:05:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Ta44pz2N;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=qoCRgKEqb2cNIP9iBbmcP+1MshPj3Nktj6OiPwbarXY=;
        b=Ta44pz2N6vCsDgFB/YzCguDFPvKoN0XrV1PKQ4fEBWZ2ERaHYWnbT/J29GnDrAm3Q7
         AM3uZD1QG2eRlrvcinZcs+1PQMK4LTC9YezWYBUZJjfV0pnyMCfIAYJvDNLAzG9vU3pd
         ZmqqDS3xlEC0dFbnkg8AFgLdi8qp+/J9e/SCpqQZUkMua6FjYoQPGJ/LlWLrApM+j5cW
         nugMzWpzkjSlBmEBIygtEQDay08/Ot0Y4z2MUYdVUgzKbMkj6Lou7ahZJWPwW63K1xFu
         e9KoBVdHojf4Tc2uQhUtLlrd8GVkuDSuvPw5JW6NObfBF1ZsnfMG3LOOx45242BscHQW
         /Nxg==
X-Google-Smtp-Source: APXvYqzUgiVnU+ecS/L3fcr3coeSpkq06FPF9E/xGA0Vgap0A2MpheGiZZG3Yep4zHc/xlpCpJr4mEN0UD4EDpMfJ4s=
X-Received: by 2002:a5e:c24b:: with SMTP id w11mr1108900iop.111.1559102717163;
 Tue, 28 May 2019 21:05:17 -0700 (PDT)
MIME-Version: 1.0
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Wed, 29 May 2019 09:05:06 +0500
Message-ID: <CABXGCsN9mYmBD-4GaaeW_NrDu+FDXLzr_6x+XNxfmFV6QkYCDg@mail.gmail.com>
Subject: kernel BUG at mm/swap_state.c:170!
To: Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi folks.
I am observed kernel panic after update to git tag 5.2-rc2.
This crash happens at memory pressing when swap being used.

Unfortunately in journalctl saved only this:

May 29 08:02:02 localhost.localdomain kernel: page:ffffe90958230000
refcount:1 mapcount:1 mapping:ffff8f3ffeb36949 index:0x625002ab2
May 29 08:02:02 localhost.localdomain kernel: anon
May 29 08:02:02 localhost.localdomain kernel: flags:
0x17fffe00080034(uptodate|lru|active|swapbacked)
May 29 08:02:02 localhost.localdomain kernel: raw: 0017fffe00080034
ffffe90944640888 ffffe90956e208c8 ffff8f3ffeb36949
May 29 08:02:02 localhost.localdomain kernel: raw: 0000000625002ab2
0000000000000000 0000000100000000 ffff8f41aeeff000
May 29 08:02:02 localhost.localdomain kernel: page dumped because:
VM_BUG_ON_PAGE(entry != page)
May 29 08:02:02 localhost.localdomain kernel: page->mem_cgroup:ffff8f41aeeff000
May 29 08:02:02 localhost.localdomain kernel: ------------[ cut here
]------------
May 29 08:02:02 localhost.localdomain kernel: kernel BUG at mm/swap_state.c:170!




--
Best Regards,
Mike Gavrilov.

