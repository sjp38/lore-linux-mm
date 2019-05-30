Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AEAE3C28CC2
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 17:14:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7413425E24
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 17:14:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="aCW4rmAy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7413425E24
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D0A96B000D; Thu, 30 May 2019 13:14:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 081876B000E; Thu, 30 May 2019 13:14:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB2496B026E; Thu, 30 May 2019 13:14:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id BE3416B000D
	for <linux-mm@kvack.org>; Thu, 30 May 2019 13:14:00 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id u7so5033786pfh.17
        for <linux-mm@kvack.org>; Thu, 30 May 2019 10:14:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=QXNL9kos3vvhr0YBbrXLE6785Sr0j7K/kyJsGRxCWZo=;
        b=qqyRk3HVmgRrPXjHPKXWDJn4yS7R9CHC3YKuFdBaPJLGII1ZJ/Wei/HvAmNuHP7+wU
         s7xJoSflIpAg5E2EoCrD/SS80M2NCNIN5jBMAFUee6eZZFWYrJ5ZDcIinu36Jf96PCME
         QtbiVie1HViOyX9HhUeCaEyTMtDbEEBPRAdyW1Twzkdzq2VXxWMotsnakgtw4KStNPkO
         7AZBAV04R4bt3j2lMLGVXEhHYjLUB8ZasnI2GG5IhmNqCqUALhwhdsc5tpfAhVKnFE9l
         G7p4B7zMakqhWty5i7ITahgNnUnkKqHHmYgtIVkJw1ijHrE3y9YZnjN7I1t88BGIB3JA
         rM2Q==
X-Gm-Message-State: APjAAAXrpn0cuUbgqaZE0wRu+uPLr/ZMq9U7FW0mKbQSydc+st8aT8WB
	gel6PCPvGyHm7rp384rsaJMejVGX2H7uzl8b91mX7oyQMLp33IrDxdzXPqRkuF3J5VxmBP+8tK+
	LgpNuALkM2EpIiAVZ35Q+H+f+z4Zq+tQ30suNptVuQYaHTWO+qQn+LdV5uMZezaXvtQ==
X-Received: by 2002:a62:81c1:: with SMTP id t184mr4531484pfd.221.1559236440354;
        Thu, 30 May 2019 10:14:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzpq9xgalAAtXCoR/jzcq6jBDCtZ5smo5uvWiXtV0ROdSmSTkm6/seTNEyoO4rleNf3gn+C
X-Received: by 2002:a62:81c1:: with SMTP id t184mr4531395pfd.221.1559236439149;
        Thu, 30 May 2019 10:13:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559236439; cv=none;
        d=google.com; s=arc-20160816;
        b=H/f+gqu51cifAxhTjntoE7+UEOWn9SLwZ9BWmIGCF0m4wwgFWGT73Ib2sgYdSb5mJS
         x0nR2nHqFXC2seN2c87heVc46qt6JPy6KqSQk+Z21Gw2ZA6DtrMu3+pS18xYwYBpDXZb
         3CScSx6zbR0gv7ihtPUgZOHA7AmvT9wAoAfypxQk237lYoWbZXADQL42lSlLY99Kx1cn
         ItdOaWYHdjoaJbZr9WjcUfybnp69F/fKHRMMOv2un5NNBfKlTK2+sAV9tGYAXGNvJFnT
         fKmL+Sh5hpJi3FbdW0EUGXi2R8xNQaR4+Z8Udg/Nc2yfRaWdoc4QE/xlLJcjjrelGW46
         PKcg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=QXNL9kos3vvhr0YBbrXLE6785Sr0j7K/kyJsGRxCWZo=;
        b=yNvmPhT7K3BlZibNW52Fr85AtRxVB68ivwQoLGZnR7D1hcQCHi3VVlaq6sVt9RYCZY
         q2NTYM6pij8IOrxeNawH+DeJpOTEcEZqMhD8MT6dlo+h+/XwoXIzaDqzkWjxOah0MxKU
         S8goM2XP0CIbRjEhzONCcGJNNPP/zqzC8TEeofuBUl74gJTG/F+fgAvcuavtS2p0dWx/
         bMJynfMwuKBWaHbtPo22XfCuWJW2/esfFj+R757IOVesKTCwLOyRI5LsQYjWxl1BGDvp
         uqX1d88DLxrHAWTpwKahDgRZs3tr2T4tUfP3jpxFPZqNkcSDPxLy7n/MFpzdbi1RXwBC
         ioTw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=aCW4rmAy;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e189si4028881pfe.54.2019.05.30.10.13.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 30 May 2019 10:13:59 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=aCW4rmAy;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=QXNL9kos3vvhr0YBbrXLE6785Sr0j7K/kyJsGRxCWZo=; b=aCW4rmAy7Pfqx+sC1ow5UzLj5
	S3cVvA1W0r84fyjvp6WDkz705BtgL4tr8bA4RNheok9Z87NBGbO6IxB8x3gy7psxD5OrdO2Fr0Dr3
	BzgQNIlDoeNoC0txb++rY4wo7shwMCprqrJdGMvJ0gKfOVWGdfaC3LP8AhGvLZUfpUzJ8vM2Q722l
	G44gEhQemLG44xdWe2W7d1eUtjnz0TIlF1JHnZOBc4DEJfGBJIVY2E8zqSoJq72uluhFxnEiWwMcx
	5mSIzsVzkijJCx1iiqp0lGzjaxU6+Ye0COktFH1ahbrAL5COgyMbYYt6K6oPY1l7wpncviyxbSSVc
	DkWVPJ30Q==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hWOcn-0005ZU-0N; Thu, 30 May 2019 17:13:57 +0000
Date: Thu, 30 May 2019 10:13:56 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: Re: [PATCH] mm: fix page cache convergence regression
Message-ID: <20190530171356.GA19630@bombadil.infradead.org>
References: <20190524153148.18481-1-hannes@cmpxchg.org>
 <20190524160417.GB1075@bombadil.infradead.org>
 <20190524173900.GA11702@cmpxchg.org>
 <20190530161548.GA8415@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190530161548.GA8415@cmpxchg.org>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 30, 2019 at 12:15:48PM -0400, Johannes Weiner wrote:
> Are there any objections or feedback on the proposed fix below? This
> is kind of a serious regression.

I'll drop it into the xarray tree for merging in a week, if that's ok
with you?

