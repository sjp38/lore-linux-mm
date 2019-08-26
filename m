Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF1B9C3A59E
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 04:52:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A2D37217F4
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 04:52:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="KTFRpban";
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="KTFRpban"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A2D37217F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 40C8E6B0521; Mon, 26 Aug 2019 00:52:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3BD8C6B0523; Mon, 26 Aug 2019 00:52:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2AAE66B0524; Mon, 26 Aug 2019 00:52:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0145.hostedemail.com [216.40.44.145])
	by kanga.kvack.org (Postfix) with ESMTP id 0367C6B0521
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 00:52:05 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 9775021FA
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 04:52:05 +0000 (UTC)
X-FDA: 75863357010.06.sort71_12298b58bea0a
X-HE-Tag: sort71_12298b58bea0a
X-Filterd-Recvd-Size: 3570
Received: from smtp.codeaurora.org (smtp.codeaurora.org [198.145.29.96])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 04:52:04 +0000 (UTC)
Received: by smtp.codeaurora.org (Postfix, from userid 1000)
	id A17FB60115; Mon, 26 Aug 2019 04:52:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1566795123;
	bh=EpH1raMLzAABWNAfNazEPaAR7fHDNze7+j9ECgklBE4=;
	h=From:Subject:To:Date:From;
	b=KTFRpbancYHhGYrs0vHTicqN979wh0V4lIEu05RuSvTruwsMNteLPIcijuxw6HSiu
	 RBRTVrQ49eXtD4o03AvRwtEJLYf9Yi91QQCGMff13a9nAaYDlgzeRcDpPu1715JuS+
	 +JF7yljOCZni/J6huSnVxjsdLyjcOL3QO7z7v6pE=
Received: from [10.204.83.131] (blr-c-bdr-fw-01_globalnat_allzones-outside.qualcomm.com [103.229.19.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: vinmenon@smtp.codeaurora.org)
	by smtp.codeaurora.org (Postfix) with ESMTPSA id 715B360115;
	Mon, 26 Aug 2019 04:52:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1566795123;
	bh=EpH1raMLzAABWNAfNazEPaAR7fHDNze7+j9ECgklBE4=;
	h=From:Subject:To:Date:From;
	b=KTFRpbancYHhGYrs0vHTicqN979wh0V4lIEu05RuSvTruwsMNteLPIcijuxw6HSiu
	 RBRTVrQ49eXtD4o03AvRwtEJLYf9Yi91QQCGMff13a9nAaYDlgzeRcDpPu1715JuS+
	 +JF7yljOCZni/J6huSnVxjsdLyjcOL3QO7z7v6pE=
DMARC-Filter: OpenDMARC Filter v1.3.2 smtp.codeaurora.org 715B360115
Authentication-Results: pdx-caf-mail.web.codeaurora.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: pdx-caf-mail.web.codeaurora.org; spf=none smtp.mailfrom=vinmenon@codeaurora.org
From: Vinayak Menon <vinmenon@codeaurora.org>
Subject: Page corruption with SWP_SYNCHRONOUS_IO
To: linux-mm@kvack.org, minchan@kernel.org
Message-ID: <63cc70b0-a1d9-1f6e-b264-8b31ea9b9087@codeaurora.org>
Date: Mon, 26 Aug 2019 10:21:59 +0530
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 4.14 kernel with SWP_SYNCHRONOUS_IO patches ported, we are seeing an issue which is not reproducible
with SWP_SYNCHRONOUS_IO for zram is disabled. Its arm64 system with 3GB of RAM. Note that zram writeback
is not enabled and backing_dev is not set. The issue is very hard to reproduce and requires low memory
situation to the level of thrashing.

Observations

1) Android zygote crash due to NULL pointer dereference. The page from which it picks the wrong pointer
is completely zeroed out. Since its always in zygote process context and probably points to role of fork
and pages shared between processes.

2) The issue always happens on anon pages.

3) The corrupted page is entirely filled with zero. Always. Never other pattern. And the page owner shows
that the page is read from zram in all cases (in most case its a write and thus followed by wp_page_copy).
Probably a case of fault finding a missing zram entry and zero filled page being returned by zram.

My attempts to write a test case to reproduce this is not successful yet. And I don't see a way to test this on latest kernel.

Thanks,

Vinayak


