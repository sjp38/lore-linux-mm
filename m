Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E71DC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:44:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3DF652146E
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:44:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ij/nOVUE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3DF652146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B3ABF8E0003; Fri, 15 Feb 2019 17:44:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE7EA8E0001; Fri, 15 Feb 2019 17:44:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D7718E0003; Fri, 15 Feb 2019 17:44:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5E7F88E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:44:09 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id o7so8574372pfi.23
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:44:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:user-agent:mime-version:content-transfer-encoding;
        bh=HBcjk503nQuKRSQt+/RVqHzYhBzzBuRiWKFD+cpVj7Q=;
        b=k6QAFwGPTWILcxKBv1rKWgmo6IBssxcssjgzuX22XG68mTwbZWZkigh2PvE9J68jg4
         OvfewokAc64X5WYHzDWaiM/pOTn81uFB/J9DWqrbXj2axi4PRJZDjD4B47CLzsS5tiwg
         4zoQ4hEg3j2pE+5IfWE2weXodcr/GXQJz1kjsQccLChmNiRp++RcnuEfdSW4QUGpyYng
         BOgcY3aF/LQjp6Nrb0tua1GcRbJc8KXhiwDNhU1UxlvhoH2yMxP13AF+CbGwqeHCskjg
         CXrarTnXgRHfT1Xjpen1yCKjRhzyw3cRD0Uow/Ytq97UjyGuU1YxbZkjBanaadJ2SsKV
         tKeg==
X-Gm-Message-State: AHQUAubpC1uW0ktrF9gbSqdUDuPnTo1rfVXpf7nn/kxeK0CKSugkVj/B
	aUB6Q6B4D2fLbtuSIkczb5yrVzXOmbnDJ0EucK6oHehdRBZycF1VJtH7zv/8tittlqJgbYhqtP0
	DmCAVOKmmvV3Tc0HQpjqV/7ulCCKJbbdI7a6ZfEIcxqWNqtNw++tKxHFeUO2GSukGBDL5bDRJzy
	2VCwX4lWFXNqut7cRH4tWOqcBTuFmnlrvVAzGjY9E/Z052sdVWPE7BTQ7IQ5ixH7w2iOYJFvKXQ
	yJrBbU9/XukQD+eMSWb5Mpg+/Dczv05ovGj6qBQtFskJZte2h0G4+53srAiLVx2I05i2/lzXkEe
	/MowIJCfF4urlxkhSBAtUXWJa3iZjkhwT2SBzsQCdgD2W6wUOWD9XqiRycZBkc8zp6aY1eu5pEZ
	A
X-Received: by 2002:a62:b2c3:: with SMTP id z64mr12027521pfl.149.1550270648961;
        Fri, 15 Feb 2019 14:44:08 -0800 (PST)
X-Received: by 2002:a62:b2c3:: with SMTP id z64mr12027486pfl.149.1550270648275;
        Fri, 15 Feb 2019 14:44:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550270648; cv=none;
        d=google.com; s=arc-20160816;
        b=0PUbhlOYesCvUALuwkfahrrEGGFd7q8ztefLjlWVrgOT3e/B9kJQuu3QGy/NUbcY1W
         T1Ap1FGK8wx9kypE6D8eSPRPxnu1v1v3WsJj2oyN6XePFTTS0ElAe42ZG3yuFXpDr2fS
         e9k3vw7PUkz76Ihx1NWdtFrjVQPXJRKx4Kb9lFytq/k9xjAVAFxCo67McvOXNc99nbZ7
         jkhyJG8I22WtYlWBikirapm8TY2CbM2cwG2ApixmduT7lYqa3lQ0ZQi1gkWFhDH/g2gk
         FmTxD7HRCLgZUAuvy+Qm5jvd/dTNkf0yDImOAPbgnhg006Z66vEoh1qV4Bui+dubeMRk
         moHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject:dkim-signature;
        bh=HBcjk503nQuKRSQt+/RVqHzYhBzzBuRiWKFD+cpVj7Q=;
        b=LuzW5jOQyo7yIK/jZhCqZJUrRgMS8x7ZCtIzn3t3bJhdn/pdi5rrguDu48pFgUxFBl
         +CmrCP75yh8DSZV3L4p/olhGGayD8kG1+D1SLkUlcbFuH8wvZ/c8oOnCfzc3ySYG+/DD
         JZ/VUNNcCxy6vQANTO3Z3S9o0MyfJYdUMbWTxpZ+O4cH/Z4kPC0p3cd9U4sVg/WcyUGz
         Ab06BnajSjbRvvoxrOR9iZdZbD5XJ1pP4VobJr7SUbwxc7DyEhWrql8IHCHU47k6Tv1S
         2AB2mqupub5PBLj+Dk9wVs/vF3Rb4yMUILUOvsUfHUGT8t1ZAMkqcv8ovmUXJ7juOPk8
         9T0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="ij/nOVUE";
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h68sor11517939pfb.28.2019.02.15.14.44.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Feb 2019 14:44:08 -0800 (PST)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="ij/nOVUE";
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=HBcjk503nQuKRSQt+/RVqHzYhBzzBuRiWKFD+cpVj7Q=;
        b=ij/nOVUEwkqqrwG9/VWRIis6Tn4jNei6jZnSUTGb91GMP0U/r/K8Dycz1T3SfKPx/L
         CAxjFNMxhYSCK7Ukh+OrQwX59qnpkizgpA+rppiFktl97+Kj/WZrct5+j6B79lnn8dVc
         tutGGEsYmFN2i3vgw5CoxxOWJs7AJJnkDypzejhCKmECyoqMQdpGRPpMUD9YI3z8rtGl
         C1vaIFfA9V2+NUPUOGZNGZolJHWZf8JEljC4dgydcXJ40su5OF0jzBV7Nkj61R8folS5
         V+17nKS+51lgVdoPC0Trl5KFvaqroM3WDA1CjqehtxYBeyeD0vv1Xb2Y9/3gvzmj2UDt
         UcUA==
X-Google-Smtp-Source: AHgI3Iapx0tr5JpcSl3beD3Dn/WO+prh6r5/nue3Y9ihM/L9HBZVhKwpUmEo2uBYt/lL5VQLll16dg==
X-Received: by 2002:a62:5687:: with SMTP id h7mr12072726pfj.198.1550270647308;
        Fri, 15 Feb 2019 14:44:07 -0800 (PST)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id y21sm11474272pfi.150.2019.02.15.14.44.06
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:44:06 -0800 (PST)
Subject: [net PATCH 0/2] Address recent issues found in netdev
 page_frag_alloc usage
From: Alexander Duyck <alexander.duyck@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jannh@google.com
Date: Fri, 15 Feb 2019 14:44:05 -0800
Message-ID: <20190215223741.16881.84864.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch set addresses a couple of issues that I had pointed out to Jann
Horn in response to a recent patch submission.

The first issue is that I wanted to avoid the need to read/modify/write the
size value in order to generate the value for pagecnt_bias. Instead we can
just use a fixed constant which reduces the need for memory read operations
and the overall number of instructions to update the pagecnt bias values.

The other, and more important issue is, that apparently we were letting tun
access the napi_alloc_cache indirectly through netdev_alloc_frag and as a
result letting it create unaligned accesses via unaligned allocations. In
order to prevent this I have added a call to SKB_DATA_ALIGN for the fragsz
field so that we will keep the offset in the napi_alloc_cache
SMP_CACHE_BYTES aligned.

---

Alexander Duyck (2):
      mm: Use fixed constant in page_frag_alloc instead of size + 1
      net: Do not allocate page fragments that are not skb aligned


 mm/page_alloc.c   |    8 ++++----
 net/core/skbuff.c |    4 ++++
 2 files changed, 8 insertions(+), 4 deletions(-)

--

