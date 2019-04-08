Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB5EAC10F13
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 19:54:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9561B20880
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 19:54:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ecLqHUnz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9561B20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 335016B0007; Mon,  8 Apr 2019 15:54:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 30B076B000A; Mon,  8 Apr 2019 15:54:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 221FA6B000C; Mon,  8 Apr 2019 15:54:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id DCC386B0007
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 15:54:14 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id j1so10664396pll.13
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 12:54:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:user-agent:mime-version;
        bh=1jo2iMrB0owQ9V5kkgcFERnG5vKtykcZHem1fyaBDFo=;
        b=Pix1tEVnVP2VY7tEmffRzfTNAcz9RIjzzO3a/ZLqcUB6tej5lkLrk+GEbWe3aySDqh
         cDdiHhDxlgH4J5KBMXeBRovylmH92BuQA+c2jtSmNhSnw9rC0HESCPlCoucPZtO7izcD
         S7aOn7KIdqJCt+95fcCXwfAEb1X8ErrZPD6fzGFo+w0ph+hGszS1m/vSL2afTrt9C/nf
         jTUFWgP/pqaijTLrfpkTW8kk7Elu2MDLV0UKFPS+wlZPcSbgslSrpw62c31GRCW+3WZv
         6f19mbxGZVJATmyqsx5S/kFB/u+c2IOlkAPQanpS/Gl6t3neUlMd0alUIdUZqmr2TMie
         NANQ==
X-Gm-Message-State: APjAAAVrtuMDm+tmsxBPCQwWnrRGFKvOO1XNTfeOlQc6UY/BokuKYyEe
	IFwreXB+rh9+Auq+F8t2AVcMcWNgVxslsk0inX1jZNiJYK1nF+VnyXTawtHQ7BtYxY3sMyM1MZ2
	eQFyBygJYnTVfN3tuef6eR/3G23q6SdzJojYdEDLhz0MBV+fO9LjwO8HmaaNEb9vAhw==
X-Received: by 2002:a62:3892:: with SMTP id f140mr31648814pfa.128.1554753254422;
        Mon, 08 Apr 2019 12:54:14 -0700 (PDT)
X-Received: by 2002:a62:3892:: with SMTP id f140mr31648739pfa.128.1554753253654;
        Mon, 08 Apr 2019 12:54:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554753253; cv=none;
        d=google.com; s=arc-20160816;
        b=TvVYIRtQU362ZZz27XFL+aHG+BpYK/IyEIw34OFJ/bnZqBH43cflYicUgMMjH8WPgB
         sM6iwKwWLvexKL0qwV0EmzTol2UbyzDOWkXbBN80lb30yDNuiNeC2V8OdUMOpwAW/5Jl
         4UmOAFnv36msnhF5IUKCiDC+lvnc4PrwqVXAEHPMNkvrfko1a/7ArmjMbX7z21qy7KZG
         tWW6afp7gN/ZUV+K20DDt1ElPo5stSXp5+5cN9A8IdAX/jFIvWWZAUKa6XXXtikwYcmJ
         u/IRkJKWwY7V/4XX+78gCWV+Oy+LpU+OVq9bNQBD3jmjQB3fO5snhphPOhnEVTKKldQx
         XUcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:subject:cc:to:from:date
         :dkim-signature;
        bh=1jo2iMrB0owQ9V5kkgcFERnG5vKtykcZHem1fyaBDFo=;
        b=y8r0pAYCODSbs/i2yWmzr5ooQMIT4U5I0RV1j0Twnl29RBxckgTXiHCBcx/bAyBltv
         R5SBtNDTh4tkrDRKGQXLAd4NMbQ4GWD686aTRXNjv3yclffpWeEI9ILU1qVZapo1lhmE
         FwSNaVJVtg/3Quod+WbDePFMBL2bqcMGU1gzd1P/5Sbd/NAFUg0fHhfeCrlWpFverFpe
         ufmr2LfMwJylGwDvdWSCqil0hLverhv5sr4QqY2I7OwFJEoP1tI5G4WDc24ppbv58Yj0
         8MXRu+TtXPdi4MJ2PvhLinAv+uVYFdjEa905v8F2lc91Ng3lok4cjZG1exdti/X/ou+J
         8wIg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ecLqHUnz;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n25sor26543893pgv.11.2019.04.08.12.54.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Apr 2019 12:54:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ecLqHUnz;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:user-agent:mime-version;
        bh=1jo2iMrB0owQ9V5kkgcFERnG5vKtykcZHem1fyaBDFo=;
        b=ecLqHUnzNU7+FbXXx978+5RbQ1KF8vvKyf67EIY6PXNk03FzmiRTrZrDLsmXWptuPL
         /Rb82V3XEi9XGLiZ42bffTnISaWVr3H169b9bpmR2tFq/RhVtkWJOOu/QS9AMyAB8B5y
         2KVZpADsQ1m7nZIrGh806AiIUjWePNUVr4OfPFKZR/9o96Kz6i/CdEVSnOAW/ZwzeiS7
         XZOuLjnCVeaK2C8k3V2V2IkgbdipI+CABwpaebFQEKMN25A86sGs1a/YLs2eCP5+HKSK
         Dkuu9VTxFelntySxMNW/MbT9ehFwaNnQFF+Pu++P/EitwO1spGJDnJa3EgOOKOyQTvkC
         OBZw==
X-Google-Smtp-Source: APXvYqwsb14x+NmywHmVHCl4/zVaonURAC95IyZ53d/9ljhSgpaIiseVXYB3ULyOpRPZCxThenZqGA==
X-Received: by 2002:a65:4185:: with SMTP id a5mr29606204pgq.82.1554753252418;
        Mon, 08 Apr 2019 12:54:12 -0700 (PDT)
Received: from [100.112.89.103] ([104.133.8.103])
        by smtp.gmail.com with ESMTPSA id 6sm12828984pfp.143.2019.04.08.12.54.11
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 08 Apr 2019 12:54:11 -0700 (PDT)
Date: Mon, 8 Apr 2019 12:53:50 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Andrew Morton <akpm@linux-foundation.org>
cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, 
    "Alex Xu (Hello71)" <alex_y_xu@yahoo.ca>, 
    Vineeth Pillai <vpillai@digitalocean.com>, 
    Kelley Nielsen <kelleynnn@gmail.com>, Rik van Riel <riel@surriel.com>, 
    Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, 
    linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: [PATCH 0/4] mm: swapoff: fixes for 5.1-rc
Message-ID: <alpine.LSU.2.11.1904081249370.1523@eggly.anvils>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Here are four fixes to the new "rid quadratic" swapoff in 5.1-rc:

1/4 mm: swapoff: shmem_find_swap_entries() filter out other types
2/4 mm: swapoff: remove too limiting SWAP_UNUSE_MAX_TRIES
3/4 mm: swapoff: take notice of completion sooner
4/4 mm: swapoff: shmem_unuse() stop eviction without igrab()

 include/linux/shmem_fs.h |    1 
 mm/shmem.c               |   57 +++++++++++++++++--------------------
 mm/swapfile.c            |   32 +++++++++++---------
 3 files changed, 45 insertions(+), 45 deletions(-)

Hugh

