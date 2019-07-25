Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9E47C76191
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 13:17:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7ABE2229F3
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 13:17:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7ABE2229F3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=profihost.ag
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE4328E0074; Thu, 25 Jul 2019 09:17:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E962E8E0059; Thu, 25 Jul 2019 09:17:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D65C48E0074; Thu, 25 Jul 2019 09:17:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 894378E0059
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 09:17:19 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id i6so23909927wre.1
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 06:17:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc:from
         :subject:message-id:date:user-agent:mime-version:content-language
         :content-transfer-encoding;
        bh=o5nGdpg6eOW81aAsAVC1e2L0osQd/mHqHqxtBXM9D6c=;
        b=LRP+hN5VYaaP7rFAGQ0vEtpMdszPixzxPGgYzmW0/Syy+zg9LW/vgABVeFSpY7k0eq
         rVZCJAO2YWiw0HYLBq0RY9cuNgT+SevZ2sBJNr9QXXKeJ9fzsxI+e2Ykll14uv83pyjv
         I79PRPhejxC1cttmmta8/kV7mgqV/P872JJ9SXQW+sn/lol3jytaxhRUuuXV/hMCJ3Uh
         ZqUtXd2lhRUvtUnLh1g2/sz92Tnen4rqz6D1Wzsv1J7pvgMqk5JevGLeHq1K8PydGcTg
         w9zGBr0/dkld8y6lz+xtLyrk4CsQ+y/BWBMuD9tIhN/AYdWeS3xomkLI5MYyz7dVGWLJ
         cgvw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) smtp.mailfrom=s.priebe@profihost.ag
X-Gm-Message-State: APjAAAVafDviyRVCJW9EzsSS2BL+4S3LbBsSjKemoHmpNoWfoWvejQJy
	sYl8+N7TcblVVzF2V3VKOlOEbGKwT+SMRapfLbQbsFQAxHHSe2VDbL+A67PWr4JVAP82bNCnoZ9
	JdcZL62enjIvR4Rrmu1ts5RzAbDMqXg9l3EzPT6tae1Ev3LSYZOaweYASPNTY+f0=
X-Received: by 2002:a1c:6686:: with SMTP id a128mr79599084wmc.149.1564060639074;
        Thu, 25 Jul 2019 06:17:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxaSRBQRBP4Y/60V1vYd/rsqlUpirwTPIF+IKnhAgVijAMzT3TswhQMSygcjW7xbZROWau1
X-Received: by 2002:a1c:6686:: with SMTP id a128mr79598950wmc.149.1564060638144;
        Thu, 25 Jul 2019 06:17:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564060638; cv=none;
        d=google.com; s=arc-20160816;
        b=Aq8tTgEQpTsx8QA8qmmHzmG/1Nvw9GLZiOxzc3fAdQZsOsL4f53xnHsGYWTzlwJPDu
         VjmzWW6MfVJQ06/8ep8P9/zh7kKOmkR8gE+jkxZwhtp0EYGrei/2TN4ahue/Oa1fKaRs
         91vuQn3pRg9tdm0vg+kb9rkgiYreo6ZlBhI5zVKnbhtS7LnOw8jU7Qg//XfITe7e0y2E
         mpMrSE4pKHdqzX7Ccr60uOL8kk/BqBMCBRdR6khllkqOW2K/zPPmfuhbLdP5TEDORlmi
         V4jai5Ibf2eEVhoiCwcinWROtJWEE0ziJ14I/Zgt/uhgA0sOaSeZxLJVtG5y5JKSgZsT
         UN6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:mime-version:user-agent
         :date:message-id:subject:from:cc:to;
        bh=o5nGdpg6eOW81aAsAVC1e2L0osQd/mHqHqxtBXM9D6c=;
        b=BAxMEJhDIncC9qsBJDM1MQ9h9PXN9K17iO+vZr2Y8xDHkOGclxnXrdrbjZ3qMPnxY8
         Bl9+RQEuz0S+aWNqdKLPRIeDD5pC3kzGL9kVIOoAMcnxq5MMUDS9AuPiPr2NH0gnANW6
         lwhrNKHFeD6Xi+qAJ0NMgpCFIxucpgBilXtsWz/7p8DHqsuk8pLhkm7OTLgGrQVQYN8t
         QqAobJPInWZe84kbWX7iMDLA4kr8U0qy/FCQy67puQj5ZoU7cB2LCP1eaQzItIM6CoNf
         TDozOeVD/3o/txIt6OvJ1UtooCl/RpiK1gWnpv9KB9NQjdOm+3IEFinp5K4xML0L9c+Z
         2Ryg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) smtp.mailfrom=s.priebe@profihost.ag
Received: from cloud1-vm154.de-nserver.de (cloud1-vm154.de-nserver.de. [178.250.10.56])
        by mx.google.com with ESMTPS id w9si38176618wmd.47.2019.07.25.06.17.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 25 Jul 2019 06:17:18 -0700 (PDT)
Received-SPF: neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) client-ip=178.250.10.56;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) smtp.mailfrom=s.priebe@profihost.ag
Received: (qmail 24877 invoked from network); 25 Jul 2019 15:17:17 +0200
X-Fcrdns: No
Received: from phoffice.de-nserver.de (HELO [10.11.11.165]) (185.39.223.5)
  (smtp-auth username hostmaster@profihost.com, mechanism plain)
  by cloud1-vm154.de-nserver.de (qpsmtpd/0.92) with (ECDHE-RSA-AES256-GCM-SHA384 encrypted) ESMTPSA; Thu, 25 Jul 2019 15:17:17 +0200
To: cgroups@vger.kernel.org
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
 Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
 "n.fahldieck@profihost.ag" <n.fahldieck@profihost.ag>,
 Daniel Aberger - Profihost AG <d.aberger@profihost.ag>, p.kramme@profihost.ag
From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: No memory reclaim while reaching MemoryHigh
Message-ID: <496dd106-abdd-3fca-06ad-ff7abaf41475@profihost.ag>
Date: Thu, 25 Jul 2019 15:17:17 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
X-User-Auth: Auth by hostmaster@profihost.com through 185.39.223.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello all,

i hope i added the right list and people - if i missed someone i would
be happy to know.

While using kernel 4.19.55 and cgroupv2 i set a MemoryHigh value for a
varnish service.

It happens that the varnish.service cgroup reaches it's MemoryHigh value
and stops working due to throttling.

But i don't understand is that the process itself only consumes 40% of
it's cgroup usage.

So the other 60% is dirty dentries and inode cache. If i issue an
echo 3 > /proc/sys/vm/drop_caches

the varnish cgroup memory usage drops to the 50% of the pure process.

I thought that the kernel would trigger automatic memory reclaim if a
cgroup reaches is memory high value to drop caches.

Isn't it? does it needs a special flag or tuning? Is this expected?

Before drop caches:
   Memory: 13.1G (high: 13.0G)

After drop caches:
   Memory: 5.8G (high: 13.0G)

Greets,
Stefan

