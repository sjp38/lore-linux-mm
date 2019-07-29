Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0AAD2C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 05:34:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD3D22070D
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 05:34:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD3D22070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=profihost.ag
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D9378E0003; Mon, 29 Jul 2019 01:34:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 68B588E0002; Mon, 29 Jul 2019 01:34:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5786E8E0003; Mon, 29 Jul 2019 01:34:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0AE5F8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 01:34:15 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id u13so11448548wmm.2
        for <linux-mm@kvack.org>; Sun, 28 Jul 2019 22:34:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=uO2fx80ZsdLhQT97m5N82DKj8wQ6mEbl3xbEyWF27ik=;
        b=rwMfFcY0SAzjQ2pXoIBpleem+Ed6IrVYvb9kWAvnRZxtg+XdJDGA1w1E9gBOPy3QVv
         /r7YdPDcIEywO/yaBC2knwd12EXgyQCoPIUjJmiflr61XtJldyYLUKDe5rIU/6mmNSXN
         pGiK9w1MU0xlNLHdWCazYZNfGTpfZ/x5GKEQhZWy+24WCIwlUwkwGi3VYiZF1KpIYuR6
         izR39MnzX4UxejkJIhu8yioH0OAtiVTeEzq7Em379cnFXiSUbVj387P5yVo2fwefkIsV
         V2ER2gkohgxKOGQu1wVkQoBaEFNWcg0LcdcYsvjRt1+MsOKxuM7SUdX8KtJumc1dnPsI
         2tZA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) smtp.mailfrom=s.priebe@profihost.ag
X-Gm-Message-State: APjAAAUMp3MqEY2EjL37n02qF/oBhwp/kItu7csLcDtGmWfyzfqiAIXd
	6Oq1vdgkByGoy1R4SZPsmOa7WF1XujPUOlR2Cj+O4QmB/IehJEf+cYBh2ZG18kQCENsWmEkQYLB
	0kgDcS+A1Nl2196MQhrU0D4xkRJOKDG0qg1qsOSoJPLR+M71YzozorIq75diaC9c=
X-Received: by 2002:a5d:668e:: with SMTP id l14mr60059052wru.156.1564378454579;
        Sun, 28 Jul 2019 22:34:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqypJ4qsyq5lxJOHnbibiyEonYVSkjKG8dh35y9gAOn5ZNhOdoHC4M0nFdqGrDzr+bw+mO71
X-Received: by 2002:a5d:668e:: with SMTP id l14mr60058968wru.156.1564378453904;
        Sun, 28 Jul 2019 22:34:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564378453; cv=none;
        d=google.com; s=arc-20160816;
        b=HOfLx20CpPfKCPkl6mlT/bfEmwfsqbJM5PIPvK14WHpGaGZcSXUVaunNRJypVOeW2R
         hwEdlPOWuJcpIReK08l5ZeaBj2i8QeTE6jfDyrtHUDHH/RUvcCmmr9i67dO+Gro3y6rb
         YYuSw2zGcjyENiYDXFxWYY8EnLm5iDl1IeNZa7Tqt1Rp/U+iMvPTLCpsSrqGxQ9Q3EJF
         xeuLRqe8Cq+XL6j29ljC8nxjVKBWEvCvvMCVh/tfCjfu/ASDsvZb/Bkzm3qMi8uDY4xu
         xzRUny3RpKCbj/tGx9ElfAFgyyQ99fcu0llPBVSPA64Z3iwNiBL3naIqV7GYCqoCv5cx
         ANuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=uO2fx80ZsdLhQT97m5N82DKj8wQ6mEbl3xbEyWF27ik=;
        b=vknvQ5rPHsYD1VDV/Gl/MbKpwJlhqpYmk+3hZfl/MrDTYlBrSO0nz+N1KZlIMt7/sc
         H2+PnY++H65Ukivi6L+LY+RyF4yEaJKznS1qE8CRZSmVZralFRuBSbeuTD4ibKgbtRZN
         bpMayN1BJgIBlLzSnZzUCjUrdN4wFFmKpFs5/L1ur2ZmvQS9kHBef+CJKpZJmC5muZ+h
         Hcd02qvUOXq3u9BE9DfmjQdqjfGNYz4jvZfN2zs3Xv/ul855G8oQdsAmPZDapP4y17JA
         zYFTZqlQauC5kuTERaNfW6swKOA+ojojdn1G4w+w4hEinTmVgNcdnCWYUlabPtKGq2lP
         9sGA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) smtp.mailfrom=s.priebe@profihost.ag
Received: from cloud1-vm154.de-nserver.de (cloud1-vm154.de-nserver.de. [178.250.10.56])
        by mx.google.com with ESMTPS id b12si57876018wrt.117.2019.07.28.22.34.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 28 Jul 2019 22:34:13 -0700 (PDT)
Received-SPF: neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) client-ip=178.250.10.56;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) smtp.mailfrom=s.priebe@profihost.ag
Received: (qmail 19911 invoked from network); 29 Jul 2019 07:34:13 +0200
X-Fcrdns: No
Received: from phoffice.de-nserver.de (HELO [10.11.11.165]) (185.39.223.5)
  (smtp-auth username hostmaster@profihost.com, mechanism plain)
  by cloud1-vm154.de-nserver.de (qpsmtpd/0.92) with (ECDHE-RSA-AES256-GCM-SHA384 encrypted) ESMTPSA; Mon, 29 Jul 2019 07:34:13 +0200
Subject: Re: No memory reclaim while reaching MemoryHigh
To: Chris Down <chris@chrisdown.name>
Cc: Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 Johannes Weiner <hannes@cmpxchg.org>,
 "n.fahldieck@profihost.ag" <n.fahldieck@profihost.ag>,
 Daniel Aberger - Profihost AG <d.aberger@profihost.ag>, p.kramme@profihost.ag
References: <496dd106-abdd-3fca-06ad-ff7abaf41475@profihost.ag>
 <20190725140117.GC3582@dhcp22.suse.cz>
 <028ff462-b547-b9a5-bdb0-e0de3a884afd@profihost.ag>
 <20190726074557.GF6142@dhcp22.suse.cz>
 <d205c7a1-30c4-e26c-7e9c-debc431b5ada@profihost.ag>
 <9eb7d70a-40b1-b452-a0cf-24418fa6254c@profihost.ag>
 <20190728213910.GA138427@chrisdown.name>
From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Message-ID: <2444c2d9-4c56-557a-5a25-c8ca25f94423@profihost.ag>
Date: Mon, 29 Jul 2019 07:34:13 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190728213910.GA138427@chrisdown.name>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
X-User-Auth: Auth by hostmaster@profihost.com through 185.39.223.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Chris,
Am 28.07.19 um 23:39 schrieb Chris Down:
> Hi Stefan,
> 
> Stefan Priebe - Profihost AG writes:
>> anon 8113229824
> 
> You mention this problem happens if you set memory.high to 6.5G, however
> in steady state your application is 8G.
This is a current memory.stat now i would test with memory.high set to
7.9 or 8G.

Last week it was at 6.5G

 What makes you think it (both
> its RSS and other shared resources like the page cache and other shared
> resources) can compress to 6.5G without memory thrashing?
If i issue echo 3 > drop_caches the usage always drops down to 5.8G


> I expect you're just setting memory.high so low that we end up having to
> constantly thrash the disk due to reclaim, from the evidence you presented.

This sounds interesting? How can i verify this? And what do you mean by
trashing the disk? swap is completely disabled.

I thought all memory which i can drop with drop_caches can be reclaimed?

Greets,
Stefan

