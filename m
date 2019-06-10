Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B683EC468BC
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 08:18:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E4F62082E
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 08:18:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OJysVsS4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E4F62082E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 126426B026C; Mon, 10 Jun 2019 04:18:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0AFCD6B026D; Mon, 10 Jun 2019 04:18:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E9D166B026E; Mon, 10 Jun 2019 04:18:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id BC29A6B026C
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 04:18:12 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id z10so6441581pgf.15
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 01:18:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id;
        bh=wZDIYtcBm6YBkeyQZrwF6W6HfPYDVvweCiUtUBQSDhE=;
        b=eoOU48SUfAfPPZNr4CERr9GHVYwo8Z9yOAwctk7CKhPRIEUw2JuhrE+7DM4jCNiC39
         /tAMBVRsGjW/VkGcynLuTQ6nT3VhBbL7K1I6PQWmcfGkn4VIvO1KelY8rKGt1mmHUKIa
         nEcYejCvAfv5EkfpdUWgZwcL3j6YXhnlyI/FPl0eL088Q/imyfS4grSYnDTik9Legjr2
         1K9nGgU1u1/WKw5sLl/RjFPXCocNWEsyGbvvCelMvDYVEvHwBsPGkBf94m6PXDiIY3mn
         bE20OFMr+SmhSj6yL+Hb+bmQaTpyH6lSaC9uOQrD0HntP1i2ttn6EdJ8Bp78GySL3bec
         JPjg==
X-Gm-Message-State: APjAAAWpiy9Eqo5cPPm0wirok7CsafgmhY9rfJatUk91SV7q0VoUL5qz
	nx+iZ5tricVVrhnsEN9TGlYj9S+3RQIns4nHMVtdjsAZrO2i2np1bDruaiWetvYOGuLTqWvAWEj
	YDtAHFh4fN5rA3bMEWB//iwUSYoEm5gaFYuNQR6n5caGOn4ARwTFKFmcpAjV5Je0=
X-Received: by 2002:a17:902:70cb:: with SMTP id l11mr8428940plt.343.1560154692310;
        Mon, 10 Jun 2019 01:18:12 -0700 (PDT)
X-Received: by 2002:a17:902:70cb:: with SMTP id l11mr8428904plt.343.1560154691670;
        Mon, 10 Jun 2019 01:18:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560154691; cv=none;
        d=google.com; s=arc-20160816;
        b=v2fBPOsvSmpEP6KRzW6lCCW6XWXDc5x6xTRDyg6g6bHINN0rzo/XH9fxynU+wZVRmo
         0YQzdZwzc5f4+XGoG1X2SKZDGBFEJZxH5MvBapavzyQC+IFcNWjEM6Th+KC7uXnMGrI3
         pwX4XzDdeREe24m4oJveIGKf6UOMXSIS45/yITJ8oY91AZGdVtvvGCUjo8SLNq6u3S5I
         2g7DrTptiTklEzx65s7E2+T32aI/QJ9DpDSvKCfA7HPM1CxmFg7Zt8LqPaYU6/zNZEry
         8MuKSWdxMgsiYIXSIqenmc2LW4X1CZ3HLUtqNW23yiiG1wZ1j2pifjTPCUsn4Uc6Zq08
         xOhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=wZDIYtcBm6YBkeyQZrwF6W6HfPYDVvweCiUtUBQSDhE=;
        b=LIeNo6RpRb32hSrWNmXJ5lFZSJe8V+0YmdRrNz04ULW3qIFU9YPso8QHRalk+69BYB
         yO75NbA7llv1Hu4BQMSHZeGpAzrjl0WofUpIRbAnfNHKWcC+cDS5mfpQVW37TTiNLNlF
         yib1BVDd7uYcoUtDKoHViFdjmYZQ9mXgNw0SICyT2jXAbvGYwo8HSszOhWbddewp2y+l
         N/+smsjS1lKJeXPTpp1nSLrxYAVJQqecsF2oHf5bpiv0FKdexBgjBfjgFwBh91fpIqnO
         4OV1awRKROb79//shqNjhcGGGAbJdqTMQGHEF6sV9f6hTtF8AniBq2XJaq+TaeL8FS7d
         MEGw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OJysVsS4;
       spf=pass (google.com: domain of nao.horiguchi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nao.horiguchi@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 66sor4970170plc.7.2019.06.10.01.18.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Jun 2019 01:18:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of nao.horiguchi@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OJysVsS4;
       spf=pass (google.com: domain of nao.horiguchi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nao.horiguchi@gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id;
        bh=wZDIYtcBm6YBkeyQZrwF6W6HfPYDVvweCiUtUBQSDhE=;
        b=OJysVsS4wUoxpTrYPZCzSuUr4dVnQwKGoNVhbBMASOTHgAReWykQJuWYzmunROa2Uv
         LeuumQ3UqH2lSV3lSkc5h0Wk39Q5j/HGV8RyT2xj8Ets+MCl6cegN3FhhZM1Rt2vtlIS
         lORjLczZVJ4kIrgl5Ixgg7a12Vkafcy9uWxPvhKI2gXHiIPHnBbTXk/5K6oYl5wDH1HQ
         /NIQzsGHcNkaPqUd5RAfNI2U6YbCVQ3EsiPK3ymyy73AyzxteL8LeW+M6YIjF+B+l7QD
         zvWQ95bE26Q6Jq4th4uSyvPXP5w8eXYSecAHYUnagWW2JLrwhKLLJIf/4/UycO/xZvdc
         mDkg==
X-Google-Smtp-Source: APXvYqwZP/N/nuah30nBCi60qQxwirzSlklAIR0pdCjT3zNj8/gP2jcnz1KC411PHNZJZcjQfFwdAA==
X-Received: by 2002:a17:902:4181:: with SMTP id f1mr66838981pld.22.1560154690983;
        Mon, 10 Jun 2019 01:18:10 -0700 (PDT)
Received: from www9186uo.sakura.ne.jp (www9186uo.sakura.ne.jp. [153.121.56.200])
        by smtp.gmail.com with ESMTPSA id j7sm9525014pfa.184.2019.06.10.01.18.08
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 01:18:10 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	xishi.qiuxishi@alibaba-inc.com,
	"Chen, Jerry T" <jerry.t.chen@intel.com>,
	"Zhuo, Qiuxu" <qiuxu.zhuo@intel.com>,
	linux-kernel@vger.kernel.org
Subject: [PATCH v2 00/02] fix return value issue of soft offlining hugepages
Date: Mon, 10 Jun 2019 17:18:04 +0900
Message-Id: <1560154686-18497-1-git-send-email-n-horiguchi@ah.jp.nec.com>
X-Mailer: git-send-email 2.7.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi everyone,

This is an update of the fix of return value issue of hugepage soft-offlining
(v1: https://patchwork.kernel.org/patch/10962135/).

The code itself has no change since v1 but I updated the description.
Jerry helped testing and finally confirmed that the patch is OK.

In previous discussion, it's pointed out by Mike that this problem contained
two separate issues (a problem of dissolve_free_huge_page() and a problem of
soft_offline_huge_page() itself) and I agree with it (althouth I stated
differently at v1). So I separated the patch.

Hopefully this will help finishing the issue.

Thanks,
Naoya Horiguchi

