Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D509C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 17:00:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49BB8217D9
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 17:00:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="kayr7AB1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49BB8217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D964F8E0003; Tue, 12 Feb 2019 12:00:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D47F08E0001; Tue, 12 Feb 2019 12:00:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C5DAC8E0003; Tue, 12 Feb 2019 12:00:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 93A608E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 12:00:15 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 75so2874942pfq.8
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 09:00:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=lBpKb/wbbXQeVoDwcKIY1DcbF2frsZ0l73LEA0sVM7M=;
        b=r2awcdfjauZ6ImV31BtJu57gFOyzYywxaePIqHpZaeOspV0w96T9lfQNUSO9pf7D2f
         g5N+w4NOF9Hj1pFmvO5401MNGvaYdPJmWGPlrPgEbsr2u6+7FElgfX3fklL0eQLTAilR
         y7A0TRTpgjnCloLKKuOSBVh4Ko/orqO+Juq3nFKmD4gQ4NruUldZifQwiJCzQbPpjeuk
         Pr/Q/c7uV6XfuRBxUUVJZ5tNqCgRavnmC0Q8oVOOkKjsuH58efljcPv60XuJhLac7AoA
         xenGKVElAn+WvoV5SEV0+CQr5StzK9LZU9E+ZKu5eMyma1wB6v7Qo8JP10hzwnfVBpMR
         Kg4w==
X-Gm-Message-State: AHQUAuaptiH0qi7QSN9jFdSMXJxInxHX6BPOXbUkwqi1p6TmxqYqN8DY
	YXaTwPpucypl/pAePujSn24kCytUgfNXGUb+SlZKhi4HqmVgTyZ77gnCAsuFHPPLyjLz+WxZnv6
	rugRj3J+BILgaq8jRy+4fPm6ICymH2mtmnITYLhAefPsPRS0diHiGM27LRlYXUYR49A==
X-Received: by 2002:a63:d842:: with SMTP id k2mr4358010pgj.8.1549990815224;
        Tue, 12 Feb 2019 09:00:15 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZuUrE/eP5SBonwWfwE90EYrJijxQs9z38LtmUsDm+rHmK8ckZG5gqekqVwnFMaQYWi+MIT
X-Received: by 2002:a63:d842:: with SMTP id k2mr4357967pgj.8.1549990814533;
        Tue, 12 Feb 2019 09:00:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549990814; cv=none;
        d=google.com; s=arc-20160816;
        b=DCHKCqH3REC9tDNvaCbJOGmr7hPUyzvdK6dxBCSwv1xCg4SKPzzQNrWVvxTsI3eHZn
         gOzA95SLXhJDDKGYdXu+4Kkjd+WZqpegKSdzR+1ER4OTKULHMWsEXKhBMliqBdOKhbRr
         fhd5Ol2c+ujDegKsHjCVEEtexB4HQg+srgniyM7kG9D1/W/wfBReeo0qNdoHhXghqil0
         HOENSG479xh3yoIvSMHA/vwYRknLMJ4G6GgY4LaL2hPsbqr8w8cEOZuovCtTFQDTk5WA
         Ydr/n14cMddgHg0q6KlRqYHBNb/g4wgjuRosuNXPckJtaBR23F3NNprNnsERSSWqk6DZ
         oF2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=lBpKb/wbbXQeVoDwcKIY1DcbF2frsZ0l73LEA0sVM7M=;
        b=XGMCsRUhAgaYtU+H1nMuKnmZ4eH96KzzofYFxBkmm09JjjpR6ajkE1Q4htudTUoT38
         0ftQAnKOCOqUEaL+Y3ewA0tyEHiwgAbV6qENYAEFasyRYmTdTIDTHDSO8yjJJP/eUqa5
         vADLsX77GKzLzcsWjrZvsCQreiC4032uOoAX3nLmcqMvQ08KjuwbC2yrEbXTkZKStx1W
         jLITSIUWMI+GjFgN9Hqrm8H8dAOSg7G+gPSgTJU1B69NaQNiFFmPahP0pQ15wiBFyqx2
         G7Q4r72TiId2mlImgfd7J6UyMJowDH30grPsYY2ZiaWWm8Xt0q7iD4y3vkzRyUVkPJ0y
         AxQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=kayr7AB1;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q6si2892898pgq.442.2019.02.12.09.00.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 09:00:14 -0800 (PST)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=kayr7AB1;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E82F3206A3;
	Tue, 12 Feb 2019 17:00:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1549990814;
	bh=lBpKb/wbbXQeVoDwcKIY1DcbF2frsZ0l73LEA0sVM7M=;
	h=Date:From:To:Cc:Subject:From;
	b=kayr7AB1SjalDDD5c/bKDcSDgEAkbNv0RHCVudc+pGFp49+yJ7LF+GqkGZ8MuDPqB
	 Eodtt30H80uBcRT7CzXsQHVyW1muygiKft0PTj36ZxPGkoj3YI9fln6WfoYC/Wb2Xq
	 oE6XWCnus4JGxAmHpySrpuqHNM+9kPyzPC6ivJUw=
Date: Tue, 12 Feb 2019 12:00:12 -0500
From: Sasha Levin <sashal@kernel.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [LSF/MM TOPIC] FS, MM, and stable trees
Message-ID: <20190212170012.GF69686@sasha-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

I'd like to propose a discussion about the workflow of the stable trees
when it comes to fs/ and mm/. In the past year we had some friction with
regards to the policies and the procedures around picking patches for
stable tree, and I feel it would be very useful to establish better flow
with the folks who might be attending LSF/MM.

I feel that fs/ and mm/ are in very different places with regards to
which patches go in -stable, what tests are expected, and the timeline
of patches from the point they are proposed on a mailing list to the
point they are released in a stable tree. Therefore, I'd like to propose
two different sessions on this (one for fs/ and one for mm/), as a
common session might be less conductive to agreeing on a path forward as
the starting point for both subsystems are somewhat different.

We can go through the existing processes, automation, and testing
mechanisms we employ when building stable trees, and see how we can
improve these to address the concerns of fs/ and mm/ folks.

--
Thanks,
Sasha

