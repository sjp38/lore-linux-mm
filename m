Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 576BDC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 14:20:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 22ABC21901
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 14:20:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 22ABC21901
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9783C6B0006; Wed, 24 Apr 2019 10:20:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9273F6B0007; Wed, 24 Apr 2019 10:20:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 816396B0008; Wed, 24 Apr 2019 10:20:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 34D716B0006
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 10:20:41 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r8so916256edd.21
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 07:20:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=teq7UCa9Dfh3lENQ4jCacwuC0q8HiMfiDBZl97UHR0k=;
        b=O1mUDNZiqHNN1JWcAiHhQM09bXepU2AusXTQ23JEj18mGHv/AbZPnBQIwjfH+4QmxH
         MzwRW6fH76c72VdBZXGMgPpFTRSzL/ebTyKkdIuZc1up/d9DP/XrZHOt8w3DzzB6lkeT
         N1ObWyic4t/hqT0Kj0XQT3eOtczF9m8kARVUM1AxG+PAO9prt5GpRu1dCLy/RyYdAfKS
         qNR98PTjnnBHm1kUjcJcf+JHsxa0S+fK9KcuR/eNCw/B48OdSZySR8ZX2ihF2ZxZWRbS
         +Mxpketayf+gRsXEqA5gyVA/6+2SiR2E3fJHbi7gTD+RSZKBIl8QI0p5fTcQ+qTHhUfr
         aUuw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAVTpNM+Pnw1Co4gqqauoe6luTdW3bnyrOIIX4hc8mS2FyqU5EGK
	Ta153HzpZUz08TymtXT8vihSvMRdq+++OP/IR+Ap+T7wHfBBasYEjytg6dQqckl9Gd+ZU6iO8RX
	xfVmISbTskmXtKgNhkKLcZW9DDnAfjEVEEVVws+/Q5gExQi5xjQxBepwggcVfgNyNYg==
X-Received: by 2002:a17:906:660f:: with SMTP id b15mr16135079ejp.13.1556115640786;
        Wed, 24 Apr 2019 07:20:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqypIQSxhgvRB/XSaKFkal29dUO08WoDywhu+p3biBhXdgUb8Y/Wfrpp+qnEN2YF0h/0wgxV
X-Received: by 2002:a17:906:660f:: with SMTP id b15mr16135050ejp.13.1556115640099;
        Wed, 24 Apr 2019 07:20:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556115640; cv=none;
        d=google.com; s=arc-20160816;
        b=WLpJo6c0xYj6xEpK+dqrJm0z+wyQDlUgCJKwwEGKLlRpfR1CvObacT4I6xZlZZQ3A0
         FNOjv7pYUbo/fuwKb3uh12xCe3jRk38D4SK8eHqiZA0IU1Lne4VkMFgNFTBjvPGn7Dcn
         Uaz3xjDK4/yc9lPLQa4y2uez76IPG7Hs8NmGhgqNeIJ10gYTat+gHx6mLip3iTQiFnCU
         NgWVwS11s4qzbtnftxxJDlwGWki8QKK/oFGRASlhZv7IbXlNlalpn5cN+dw8cPcn/OPQ
         0K+7iBqiFU+UkhPIdJhgOtf5l1OdIUcx2TyUvIxMNGuPkENKcfruNeL/lUwfWEcAfYiY
         2aDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=teq7UCa9Dfh3lENQ4jCacwuC0q8HiMfiDBZl97UHR0k=;
        b=d+35ioW5REHdChiwYdjLbOkHKL7VUbYTi3lFl+o6F1OuantndcR3y0/cX/BS54Umxv
         ZYi55IHZU7tdkTXTq/Mq0jDzBcMvoht4hqG5Y3bbXQCXcjuHmmW9pnG0UXtrWpTJKkvY
         AYjo7u3av0QU0OoHxdo+Vy/0fuXSUhu8Ls9+LwRWDxgeTmwEiFFCthhYz70A5Fv7pFOx
         Ebpid1uFhl79+ry+ceL5MfIc73W2FpoE+PZHvk1f0e+b6s6MZh7ZyyliXpIlWP4bYCtt
         GYYjcwo+HEUgU/y6u9KpmGPGjgz6HFztdI3llZsKnrKAaUbUO8ZB8S+569sJVpfKO+mc
         XLCA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp16.blacknight.com (outbound-smtp16.blacknight.com. [46.22.139.233])
        by mx.google.com with ESMTPS id j3si3220811ejs.316.2019.04.24.07.20.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 07:20:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) client-ip=46.22.139.233;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp16.blacknight.com (Postfix) with ESMTPS id 894251C1FD2
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 15:20:39 +0100 (IST)
Received: (qmail 25928 invoked from network); 24 Apr 2019 14:20:38 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 24 Apr 2019 14:20:38 -0000
Date: Wed, 24 Apr 2019 15:20:37 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Christoph Hellwig <hch@infradead.org>,
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] x86/Kconfig: deprecate DISCONTIGMEM support for
 32-bit
Message-ID: <20190424142037.GV18914@techsingularity.net>
References: <1556112252-9339-1-git-send-email-rppt@linux.ibm.com>
 <1556112252-9339-3-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1556112252-9339-3-git-send-email-rppt@linux.ibm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 24, 2019 at 04:24:12PM +0300, Mike Rapoport wrote:
> Mel Gorman says:
>   32-bit NUMA systems should be non-existent in practice.  The last NUMA
>   system I'm aware of that was both NUMA and 32-bit only died somewhere
>   between 2004 and 2007. If someone is running a 64-bit capable system in
>   32-bit mode with NUMA, they really are just punishing themselves for fun.
> 
> Mark DISCONTIGMEM broken for now and remove it in a couple of releases.
> 
> Suggested-by: Christoph Hellwig <hch@infradead.org>
> Suggested-by: Mel Gorman <mgorman@techsingularity.net>
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>

It was really Christoph that suggested marking it broken but I do agree
that it should be marked broken to see if anyone complains and if not,
there is no real reason to keep discontig available on x86.

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

