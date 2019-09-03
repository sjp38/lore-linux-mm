Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A5A7C3A5A7
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 15:42:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2DF723774
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 15:42:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="EzcjS1ne"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2DF723774
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 68BAA6B0005; Tue,  3 Sep 2019 11:42:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63B7A6B0006; Tue,  3 Sep 2019 11:42:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5797C6B0007; Tue,  3 Sep 2019 11:42:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0185.hostedemail.com [216.40.44.185])
	by kanga.kvack.org (Postfix) with ESMTP id 3A5D26B0005
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 11:42:26 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id D12B4180AD802
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 15:42:25 +0000 (UTC)
X-FDA: 75894026250.13.bait31_32417aba13f03
X-HE-Tag: bait31_32417aba13f03
X-Filterd-Recvd-Size: 4035
Received: from mail-qt1-f195.google.com (mail-qt1-f195.google.com [209.85.160.195])
	by imf13.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 15:42:25 +0000 (UTC)
Received: by mail-qt1-f195.google.com with SMTP id o12so8900816qtf.3
        for <linux-mm@kvack.org>; Tue, 03 Sep 2019 08:42:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=EHMZPUP68y2z5iguVqfzfNFlYo+Wg20UbTwXQGqtd0o=;
        b=EzcjS1ne4C9CO1P3CFCR3w0b95IZNPd6WLZr0ngkGQpYO3cX3IyLFr+dohcEyQLsns
         SwiDwwkeIYFf7VUVU35KLiQv93fjflQ44R93x0WULpKB+q7gsueMZiVGyxBXgsNmsQv9
         7sQsKdTDOxerv9Ll27PozXLJKKOuv0XM0eSXw0EGjeFTqH4pXSYcLealkPpszkzwHYW5
         2si2Cply4cTtIYbVZ9v8aAhWY50BSs1yApFvgqenwcn1hTxY30s5LcRLk2GsZwhaVqtp
         FzaGA+tBBm85RAOhG/PhDnSFMeq2OfGk7wzz0ZZ9iLycsN2ny7PDQd6MvO1im0waXF/f
         oH8w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=EHMZPUP68y2z5iguVqfzfNFlYo+Wg20UbTwXQGqtd0o=;
        b=OMAAn+QbaWgiJSNx5EFq6d/TQ1TKU/NrwCm7KO3ZIdXxDJySrEjyDy9b0DlDY2jp7u
         HSoxpzxRExN1eNCfM4WAlmXrzb94pcG5dx9yOqLlUPSyuQa9z5tJmFxZsRH8Z9+Sn6Nn
         cEPwUsyo9CiXJ3SdxIAN9u9dUpGkFaVxULSPp22M/aCOpjMWSqan6GPl/o/FQ/Mrb/Ad
         FSc5jHDrFE03qRe3+EpzbvAZE+UmcIcaEPJISNu5J7VMkNlx5vhQUuuRO/inVkDOzZA/
         rf+ZyN3oFPIZjM3Df5i08NexKUpfhQACqfYiC8rmbv1cLPUdtSDGhkpa4slAIkKf0NUR
         0vvA==
X-Gm-Message-State: APjAAAUr2MuUL5yL6jG1gCnO9XSDtBKYGkG/GMA+lbSv7x5YDp+Qgc7+
	ErjLHdgkBqNPCG0rPFP1mESm4B0N96c=
X-Google-Smtp-Source: APXvYqw+IwNKrHV+dGx3RobeKrDl8nlXyE0LPhn/oZzdxlaGBn0SEZqwK+nCGwY7RbgaekZ6W8Fyhg==
X-Received: by 2002:ac8:92d:: with SMTP id t42mr7369525qth.206.1567525344750;
        Tue, 03 Sep 2019 08:42:24 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id f83sm841590qke.80.2019.09.03.08.42.23
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Sep 2019 08:42:24 -0700 (PDT)
Message-ID: <1567525342.5576.60.camel@lca.pw>
Subject: Re: [PATCH] net/skbuff: silence warnings under memory pressure
From: Qian Cai <cai@lca.pw>
To: Michal Hocko <mhocko@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org
Date: Tue, 03 Sep 2019 11:42:22 -0400
In-Reply-To: <20190903132231.GC18939@dhcp22.suse.cz>
References: <1567177025-11016-1-git-send-email-cai@lca.pw>
	 <6109dab4-4061-8fee-96ac-320adf94e130@gmail.com>
	 <1567178728.5576.32.camel@lca.pw>
	 <229ebc3b-1c7e-474f-36f9-0fa603b889fb@gmail.com>
	 <20190903132231.GC18939@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-09-03 at 15:22 +0200, Michal Hocko wrote:
> On Fri 30-08-19 18:15:22, Eric Dumazet wrote:
> > If there is a risk of flooding the syslog, we should fix this generically
> > in mm layer, not adding hundred of __GFP_NOWARN all over the places.
> 
> We do already ratelimit in warn_alloc. If it isn't sufficient then we
> can think of a different parameters. Or maybe it is the ratelimiting
> which doesn't work here. Hard to tell and something to explore.

The time-based ratelimit won't work for skb_build() as when a system under
memory pressure, and the CPU is fast and IO is so slow, it could take a long
time to swap and trigger OOM.

I suppose what happens is those skb_build() allocations are from softirq, and
once one of them failed, it calls printk() which generates more interrupts.
Hence, the infinite loop.

