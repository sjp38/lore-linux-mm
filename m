Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E26CC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 00:38:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C80D12184E
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 00:38:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C80D12184E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=davemloft.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 529C68E000B; Mon, 25 Feb 2019 19:38:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B2498E000A; Mon, 25 Feb 2019 19:38:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A1EC8E000B; Mon, 25 Feb 2019 19:38:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id DC3CD8E000A
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 19:38:01 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id z13so5559067wrp.5
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 16:38:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:to:cc:subject:from:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=yPWknpWPEV3LQhCdBLp7XXlD+V/VhvFd0jbFd3bu57I=;
        b=MfLZ8XizClwHDQBaZBs4fv1C9a7WDXNVlsVcg2MmLAngpPUMJPBu4PFLEe0ZPIzzlU
         fpP2/92WHwpS1qC/H/RXcr0/RiHueRDYYM4E6FmHlf18qHbP0QXmkznWAk2mExZCrIjx
         4FDx6+INF/dVJyKL8DKK3UF8/584UtEe0qXNaUa0Q58UHLWC15M/17ljvxrc8tyO5IK2
         R0UaKpBbCsoP7yefLNkxP2A9ioR/4lla7AHxr1frPWsd5YrVl8100Z1o2CKur1AAgP47
         L7OX4wjdIFzfLdgPfMT5rVtwdc8jS4hVFfG20YsiK8c4woysOK0arVyJxOOcYJjVUoA+
         P9sQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
X-Gm-Message-State: AHQUAuaXJYRuhjLbv37inqZiL6ewK/2CCET5TyAY3E9CGQ0huWiaaxPH
	wiI1ux0lmuoNcqbrIIW9N1IPKvft27QBxv9ASBl4ishAQQV20BdLkE2jHNAS7GyjNIQcD30RHcz
	aC/xsUZ6mW+gLgobOZVzGUOM9tV0MlEvvSlR2pvbQXb9uj6g5U1ugJqme3cO9uRo=
X-Received: by 2002:a5d:694d:: with SMTP id r13mr14131742wrw.38.1551141481375;
        Mon, 25 Feb 2019 16:38:01 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib9MfeBD0GV97VXjMdRxOIOC0mLbYyufApksVeRnX8W5poGsBJeDqIOm+4Wdm2QOe1C7C1t
X-Received: by 2002:a5d:694d:: with SMTP id r13mr14131701wrw.38.1551141480383;
        Mon, 25 Feb 2019 16:38:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551141480; cv=none;
        d=google.com; s=arc-20160816;
        b=wOQ6L6MCBl9NBxN15j+EzFSCyF1qc3XbWH3/5LHm0MB2D4IUFL+/ATC85M1LiH+Oum
         iRezvs/STahgrozKWB/d9pyzQq65187XAlw+7vxGRPL9KYwI4vn0UMocM06VVc6br4SL
         agCr3NT/VTMrd11zaXNS34szekc6rRIKwmtcKhwoND4P3lyTb+vsxdXy6/ULjOenHc46
         WeDgaXER0Vp//kPR0dcFjHj6SBjNiJ09wnvrVqpyNwOdHtl0PPE7tHGjR5gYD+x62CMg
         3wk5Yvjw9SWHMLzEV1z1o6TH38/D0nxJnh9/eTxAJPsdnTpLfVXDis0ymtfYRy9LRIA2
         YsPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:from
         :subject:cc:to:message-id:date;
        bh=yPWknpWPEV3LQhCdBLp7XXlD+V/VhvFd0jbFd3bu57I=;
        b=grXK6mTWZsxoGCsn2yA63voU8HIt1fQR7BftMj/bFPQQ9+F19mPCeOCnMRiK7TlMIq
         gOgK5SMtJKJ2qMGrX5w2hWhdfiJmN9VUZSJtIfGTieRtXCDHBj8IkvwKh9lcs93M6m76
         QuZEiNAnCtRMKqo2ete+OPDzTYMx/K+8RVfGEqdfwc3KtfnDzI5FtrItvMRRMVHdMzzT
         LOHgu5io/B3mwhWwZOofXeKdQlvOIU2TIcvWIWO9olQuFDWjUagBrD04ZEFfWp21/Aee
         AiViIfK7mnXfuRx/BxpGI22rKxmzKDdY96GzMyvwI9AjPJuhE55d9WBU+m3x2bke3LR7
         EXmw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2620:137:e000::1:9])
        by mx.google.com with ESMTPS id h62si6198180wmf.53.2019.02.25.16.37.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 16:38:00 -0800 (PST)
Received-SPF: neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) client-ip=2620:137:e000::1:9;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from localhost (unknown [IPv6:2601:601:9f80:35cd::bf5])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id BCE6914F00475;
	Mon, 25 Feb 2019 16:37:57 -0800 (PST)
Date: Mon, 25 Feb 2019 16:37:57 -0800 (PST)
Message-Id: <20190225.163757.2236483713935804670.davem@davemloft.net>
To: rppt@linux.ibm.com
Cc: linux-mm@kvack.org, sparclinux@vger.kernel.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH] sparc64: simplify reduce_memory() function
From: David Miller <davem@davemloft.net>
In-Reply-To: <20190225212144.GH10454@rapoport-lnx>
References: <20190217082816.GB1176@rapoport-lnx>
	<20190217.101532.1280291105433517556.davem@davemloft.net>
	<20190225212144.GH10454@rapoport-lnx>
X-Mailer: Mew version 6.8 on Emacs 26.1
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.5.12 (shards.monkeyblade.net [149.20.54.216]); Mon, 25 Feb 2019 16:37:57 -0800 (PST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Mike Rapoport <rppt@linux.ibm.com>
Date: Mon, 25 Feb 2019 23:21:45 +0200

> On Sun, Feb 17, 2019 at 10:15:32AM -0800, David Miller wrote:
>> From: Mike Rapoport <rppt@linux.ibm.com>
>> Date: Sun, 17 Feb 2019 10:28:17 +0200
>> 
>> > Any comments on this?
>> 
>> Acked-by: David S. Miller <davem@davemloft.net>
> 
> Can you please take it via sparc tree? 

Sure, applied.

