Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5139EC04AB7
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 12:23:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12D1F208CA
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 12:23:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Ebg+AHk1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12D1F208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A6AA26B0003; Tue, 14 May 2019 08:23:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A1C0E6B0006; Tue, 14 May 2019 08:23:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 90AD96B0007; Tue, 14 May 2019 08:23:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6886C6B0003
	for <linux-mm@kvack.org>; Tue, 14 May 2019 08:23:26 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d9so2610585pfo.13
        for <linux-mm@kvack.org>; Tue, 14 May 2019 05:23:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=ovaUcWCRrSIqpnGvgTJrI7a7teTV+2l9ZYOtBT+OmF4=;
        b=IUHXY/sEn6bQ/sRItqD2au8lm3XwJch/53mKIpOT2SMcwMnh3ciBmcTHHHstVR7wXY
         Qgl5/yETzzspCjDwmBBiqu4uncjCdptC6sVJVA9OKhXIv5YZpAX6JTFOK5q6O+wSts9J
         yrkRqDLU03xSETp52Mk//kUu+57j4OKhccMAurAgoBckJ7pqSj6JiAuHjMs3REb1up2T
         +rGzSzviCJita4MG7jurxLvMitvXM+K4fXlxZgqoo9xR1dAp1juv3o74DpXv5QI7xohk
         f+UGVNgREq4Vsj4CTYHsbB3mO0O6UIF76KiUYm1JubkP3ha89//UgFQWi7AGUtzg/BvG
         U23Q==
X-Gm-Message-State: APjAAAXrU2vWaz7u7JDEmUeSOB3kuDLLwtT1fJWlWaI2twEPWWnju5Vw
	1VN2k/4163rz/TztEghNlrkn4CJdffMQd8w7AqPULB58qFgfIhCt955AmHTzuw6WuLaP0GF3Fj8
	zRS68JTY7IeOFB0vn/6lTh7W4/n9iKISaZQkGyE4jAcFHw5XORtbs/lkqN1rdbqiL8Q==
X-Received: by 2002:aa7:8e59:: with SMTP id d25mr39571512pfr.24.1557836605998;
        Tue, 14 May 2019 05:23:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwcDu1/q9iB8Bh5RYqQm8AM3OmeIu7Oq9953IpkyboD3Ltq9e7tNbEN97EzUCT5TpmRuMMr
X-Received: by 2002:aa7:8e59:: with SMTP id d25mr39571450pfr.24.1557836604958;
        Tue, 14 May 2019 05:23:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557836604; cv=none;
        d=google.com; s=arc-20160816;
        b=FH2UFu3iwFyFBJKQAfw0uXhogsEYOoBSGl5WAw3yLWn5BSYyGCvBNq3LNZGhUYpZYJ
         9RuPBw2rhzjhAg633JqbEv/8QePFvcYFcpsK9k4iw4RWcxYPbAOvLZbfBlX7akiG0rsY
         uKrlNfJLbzfb0sabqYKlkeorxz3LJvJia1b7YW+V4QD/SCl/puBrQs87B2DtDWLmPz/G
         z647LFZO9tbCvUKZuVzsXDFHEL90q2a4V85aSUBH2KPo2qJ7tMfZl+TFiVMQRoyRN32e
         yfS8fpwqIiehvVwkTcIeTW6huXQ8W7pqrYeObuBtxatYemMem8sAFokwrrnGSuhDngF+
         X/jw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=ovaUcWCRrSIqpnGvgTJrI7a7teTV+2l9ZYOtBT+OmF4=;
        b=eGX0X4DlsrbzEVBee7NB+e5Iy1/i2N2PNE4WdDaWDkqfm+2hah7B6yUPH1ybe2Hl40
         LhQGBC0MeJJX1WHSisfSWCpE8jeRoL9XTI1yyC6oIFJzEinLgLrItXOaI68QwsOLAdz3
         36lwuhWEEeVzf3brH5JhQH549bvAvEELBOBJ95tiTcyXDwQxzGagg0Si7LQKQakEuxkJ
         J6S1RVo38iryhek0WOlFjIUIbhHmLRrmOotNCMIRi++HTYzrIupENPvJ6qonxtzcDFQe
         X/NP26Z0T0Qho23vETBJo+ciWDHl/At2mDBeXvNE5cnBEo6TwylaFYi8jr/pqdceD/Ig
         dwrw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Ebg+AHk1;
       spf=pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=leon@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g11si18937108plt.35.2019.05.14.05.23.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 05:23:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Ebg+AHk1;
       spf=pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=leon@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [193.47.165.251])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 0699720850;
	Tue, 14 May 2019 12:23:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557836604;
	bh=ovaUcWCRrSIqpnGvgTJrI7a7teTV+2l9ZYOtBT+OmF4=;
	h=Date:From:To:Cc:Subject:From;
	b=Ebg+AHk11N2DV0tHSlNQqwSdCHRCKZ5TEkK09AKWwyElKUZNDZMVyGyyuOA2SIVLB
	 TGhdMkHrxAXYP+0BgVJFy/foHuBo1XUQzLkqt4uN09VwqbgWPVq6T3X4/0XTAAzBjy
	 2E3fppiJ0/ohbf/TTINeM6rBiCDvZYqCaLz5fHks=
Date: Tue, 14 May 2019 15:23:21 +0300
From: Leon Romanovsky <leon@kernel.org>
To: RDMA mailing list <linux-rdma@vger.kernel.org>
Cc: linux-netdev <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Jason Gunthorpe <jgg@ziepe.ca>, Doug Ledford <dledford@redhat.com>
Subject: CFP: 4th RDMA Mini-Summit at LPC 2019
Message-ID: <20190514122321.GH6425@mtr-leonro.mtl.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.004258, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a call for proposals for the 4th RDMA mini-summit at the Linux
Plumbers Conference in Lisbon, Portugal, which will be happening on
September 9-11h, 2019.

We are looking for topics with focus on active audience discussions
and problem solving. The preferable topic is up to 30 minutes with
3-5 slides maximum.

This year, the LPC will include netdev track too and it is
collocated with Kernel Summit, such timing makes an excellent
opportunity to drive cross-tree solutions.

BTW, RDMA is not accepted yet as a track in LPC, but let's think
positive and start collect topics.

Thanks

