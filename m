Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F5C4C3A5A5
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 11:27:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 181372070C
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 11:27:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 181372070C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=profihost.ag
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8EC5C6B028D; Thu,  5 Sep 2019 07:27:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 89CBD6B028E; Thu,  5 Sep 2019 07:27:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B2EA6B028F; Thu,  5 Sep 2019 07:27:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0022.hostedemail.com [216.40.44.22])
	by kanga.kvack.org (Postfix) with ESMTP id 5B3846B028D
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 07:27:14 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 0C6EE180AD801
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 11:27:14 +0000 (UTC)
X-FDA: 75900640788.01.shape93_79447b2bc974c
X-HE-Tag: shape93_79447b2bc974c
X-Filterd-Recvd-Size: 1769
Received: from cloud1-vm154.de-nserver.de (cloud1-vm154.de-nserver.de [178.250.10.56])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 11:27:13 +0000 (UTC)
Received: (qmail 11436 invoked from network); 5 Sep 2019 13:27:11 +0200
X-Fcrdns: No
Received: from phoffice.de-nserver.de (HELO [10.242.2.4]) (185.39.223.5)
  (smtp-auth username hostmaster@profihost.com, mechanism plain)
  by cloud1-vm154.de-nserver.de (qpsmtpd/0.92) with (ECDHE-RSA-AES256-GCM-SHA384 encrypted) ESMTPSA; Thu, 05 Sep 2019 13:27:11 +0200
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: l.roehrs@profihost.ag, cgroups@vger.kernel.org,
 Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>
From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: lot of MemAvailable but falling cache and raising PSI
Message-ID: <4b4ba042-3741-7b16-2292-198c569da2aa@profihost.ag>
Date: Thu, 5 Sep 2019 13:27:10 +0200
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

i hope you can help me again to understand the current MemAvailable
value in the linux kernel. I'm running a 4.19.52 kernel + psi patches in
this case.

I'm seeing the following behaviour i don't understand and ask for help.

While MemAvailable shows 5G the kernel starts to drop cache from 4G down
to 1G while the apache spawns some PHP processes. After that the PSI
mem.some value rises and the kernel tries to reclaim memory but
MemAvailable stays at 5G.

Any ideas?

Thanks!

Greets,
Stefan


