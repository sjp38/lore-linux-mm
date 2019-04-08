Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1C62C282CE
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 04:28:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 645AF20880
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 04:28:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 645AF20880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EEBAD6B0277; Mon,  8 Apr 2019 00:28:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E9ABD6B0278; Mon,  8 Apr 2019 00:28:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D898E6B0279; Mon,  8 Apr 2019 00:28:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id B8CC26B0277
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 00:28:29 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id q23so7393681otk.10
        for <linux-mm@kvack.org>; Sun, 07 Apr 2019 21:28:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=rSfLJpPoxkcWnD5TvPALzZmiASLea00JcqmEWCd86/U=;
        b=CfJ5bYK5Aynmobh9P2/fPdYoIEjnyDEXnVt+zX2DbP7enJ5NTX3ILcpknoyjzkz4Ua
         8I4XlVgU8PY5xqzhdz+ZIS3S0KQCAaq5br0FkhaaS5CTS2hpx9KOrWcSirxchU8or3Wz
         Ze5asGje9AR+OHPvhmoqvZ/sAmx8yz78U3i7ugc7ublOoNkSOkFA0ZNQeg3DYJdgVUZH
         yx2zJXJqoJc3jkoKNCTeCdkSh5zfuDeIspNmh61qKxBCPo8QgZ28CkyN1APGK4SaEG3+
         33vo+ttdCz2a8G0hm5w+q0vcH+FLyaGAfJVVJgRyfpnN3erGJXkLgxbzk34BrjTNAhrv
         InVA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fanglinxu@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=fanglinxu@huawei.com
X-Gm-Message-State: APjAAAULBEfY+vPGIVabUIiZCrKWUB6qUkx7QieTCNdUdcfdW/MYuwBk
	4EA0M1cMPAjp5w9+sSdbSvd69t4/7eM/1XxPI00YxMnxOroDdT7ONsbhyqT0nYUXUvccA2uJkDD
	iEkiM44FeRAZdwVzpYaDOlZ7gaFdMRMwQpn1lB3CZJ2vjoVUurpcQEaj1nbCvm1EHjg==
X-Received: by 2002:a05:6830:1114:: with SMTP id w20mr17463972otq.29.1554697709431;
        Sun, 07 Apr 2019 21:28:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz9LzuW4gZBf3UwSXrtGJLTKfPCclxRlw7WvZm2vnyxRF9G7NCQvXcm4zdMDWm5mSTa+AJt
X-Received: by 2002:a05:6830:1114:: with SMTP id w20mr17463959otq.29.1554697708985;
        Sun, 07 Apr 2019 21:28:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554697708; cv=none;
        d=google.com; s=arc-20160816;
        b=DrMXu50HzvzPzKsALcnkSoy7g+Hc1CfKpP/5Dmsvwari/3mu1QD0gQTHixYTQjm66g
         g7kpjvAwvuFvFw4jPzCGPH1gmlRb2Aq3Cr6U/sn+tbMuLG8obykQgLtorZOBOBuP8jsl
         90kB2BARCHPfAYwsOQqQdtJ70zb2w9tdnEr8Iyb7HJTrRBe4wp/j7J9ZmjCCL2f9cJaO
         06F0wcwyPt2LFB/B9iZqviqyRLo91JalSnkVtyNLzs4zSB7UK7UxiaXmnvxW43YSl2R+
         cBiwWlgpv4E20yXEMmO3m4l3OmK+wuZIv3zCHCg2bg7KzzxEfo49dtMjUP6XmmNBObuu
         xf7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=rSfLJpPoxkcWnD5TvPALzZmiASLea00JcqmEWCd86/U=;
        b=XBrEgmsMpTtfUkErFR6Pa9gGqdxcmf7a1SkjNZB3/oJUAeXuVBUJlsv9smXMbCY+Yc
         VyGrJIsoSbW/wYDxsWav/rIYAao01232rnxwRmPJWTJhbjrQ/TGruLYyq63WagTala+Y
         CaLKFqzAYnExn1U4K+FXjCH41SBcatPYJWDhKdMyBJDJXGFNYg+bzHBMD/MLfQ17jw+d
         SZ15sk2Qnybe0AC65iodFIYGYCuKLc08lAyJY/U5RCfa+CTbtYNy94YVWe+ldKafXRTX
         8X2xUc7xzcZhUKD6dae9r4Ch0cJpV8dzLILQw4LrSja0hJv8st1UEP1YA6M1dj1Tu0Ax
         fCSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fanglinxu@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=fanglinxu@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id h19si12805174otl.309.2019.04.07.21.28.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Apr 2019 21:28:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of fanglinxu@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fanglinxu@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=fanglinxu@huawei.com
Received: from DGGEMS411-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id 350B8BA8B3CAFA11F114;
	Mon,  8 Apr 2019 12:28:22 +0800 (CST)
Received: from huawei.com (10.66.68.70) by DGGEMS411-HUB.china.huawei.com
 (10.3.19.211) with Microsoft SMTP Server id 14.3.408.0; Mon, 8 Apr 2019
 12:28:14 +0800
From: Linxu Fang <fanglinxu@huawei.com>
To: <akpm@linux-foundation.org>
CC: <fanglinxu@huawei.com>, <linux-mm@kvack.org>, <mhocko@suse.com>,
	<osalvador@suse.de>, <pavel.tatashin@microsoft.com>, <vbabka@suse.cz>
Subject: Re: [PATCH V2] mm: fix node spanned pages when we have a node with only zone_movable
Date: Mon, 8 Apr 2019 12:26:24 +0800
Message-ID: <1554697584-16272-1-git-send-email-fanglinxu@huawei.com>
X-Mailer: git-send-email 2.8.1.windows.1
In-Reply-To: <20190404121427.0959934dbce398b242b6e67e@linux-foundation.org>
References: <20190404121427.0959934dbce398b242b6e67e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.66.68.70]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> How does this differ from the previous version you sent?

I just changed the module name of the patch title, the content remains unchanged.

