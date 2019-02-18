Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6220CC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 09:49:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 26E31218AD
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 09:49:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26E31218AD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B87B08E0003; Mon, 18 Feb 2019 04:49:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B10AE8E0002; Mon, 18 Feb 2019 04:49:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D7EE8E0003; Mon, 18 Feb 2019 04:49:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5803E8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 04:49:50 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id e18so3885646wrw.10
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 01:49:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=MOF63q3vfU6dggOXVMgMFG4vwES+iJS9xSLXWGcyg8k=;
        b=cFwzNB1eDU4spEJkllpp2bQoUtwDOfgXxjo3wyN74diR7hMY4akKEsgotVTwwCTPUC
         uV4lP2VXUk5zHUb4olCQwI5wbOvWgkCJKI4ZFJBcf3BYLY6bE/0jFQhOd2WVydPp5bkW
         9Hl+kkDiHjc564rG+63NiCKLf4bPsL+YQaXCSXuYg/YGdHugcgVzmmEDFmuTPRU1Siso
         tfvAJCj3ThJwGjINqkIAqPlYMDX1mXsq8+3Mb9YxmXo6EbgJW1XLOxbWRh9Zm+vbVOB9
         gNHfTdEKtAn742x8qKre4IDOznbFtE1nQ3GqUWdbw1ADTD74hFh5pHM4tfinBaJBjKnV
         JdjQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: AHQUAuYrLx9q9q2VlnYdoZYObfodgwWkVTUbKgnnWNUFA0v3d1Yzxrd+
	8McNgnCeA2pe3KSImJc+pYPKpIhioRTc42HFynfg0qCFp0NB4RhfwHpTIfCC/kUJYuMwpoYwhbi
	6jtxoXQaI7ML6HJm5KEH90MOoJtPVXUE5GCRbB65LivJJwQcAviZHIk92Gsy713/JNg==
X-Received: by 2002:a1c:7d8c:: with SMTP id y134mr15960796wmc.102.1550483389874;
        Mon, 18 Feb 2019 01:49:49 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYX5bQC1qJWoOjzc8Pgd2Y4o/Nad2FU7/3DUmoXb7lqA1m4UtM8snNtDmBVcVXGjWGI1qdD
X-Received: by 2002:a1c:7d8c:: with SMTP id y134mr15960751wmc.102.1550483389099;
        Mon, 18 Feb 2019 01:49:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550483389; cv=none;
        d=google.com; s=arc-20160816;
        b=e0RrgNZo+E1JVYDSHWYdbTNJMNjYgOMoFpv1KPvG+tmipHenPgQI05qqo/gZBV7Ezt
         CcrXMqiiFH1Zpr22U95Im0dnwuU1y9fJ+SxWktH8bcMm27yvn7rjSF8CacS04LB+Wf3L
         i+uTQx7nSUyAXUP2pOfs5lT1h1ZVBt2yTm07T411fvGheu+VwlTRrJUje624EM0UdbVX
         J2JFADO0SDRdbmyu1n3IYixDDKTUKAEbnh6m9XzziqcWPv284QbJ9VhpnSSsq14pOQtc
         E7nGfOjTbUCsR0J84xXmTG0PeIIxNHadg4JdXL2OZPHLzYPyKIRGXP6iyrJC0IXFl7fA
         3tww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=MOF63q3vfU6dggOXVMgMFG4vwES+iJS9xSLXWGcyg8k=;
        b=0L3muEQCyodhYyYfiVyGa9YPAC2rK8qviSCRb0W7edTtUFZKamNlmbBySq0sn/9emg
         Z/nnuT2Or9ntekFIzCEqVl/PmAMVPxycppCDUyvfO1rx2eyPiHxg4UbZ9hZcuWkglwf9
         65eUapByFyXNQcUNiT4tHjyb0b2CDi3cOyJ8FA6Ru2ReJXWrD/0fr2fUs9VZxll889Ph
         8kAmby+dNQEz5l1usxB+bquOgZgUdrmlJMv+pbpC0D0rsX25kGbwmEJMMI0oOTGkGtuA
         Z/sRPP7uRG9u+oCnAzzYYwAd7ygS2BnomSusZgA/nSoiS6LMKElPYU+5QV3qit4CoxSw
         SwKw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id f12si8415106wrr.238.2019.02.18.01.49.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 01:49:49 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 64A3B68D93; Mon, 18 Feb 2019 10:49:48 +0100 (CET)
Date: Mon, 18 Feb 2019 10:49:48 +0100
From: Christoph Hellwig <hch@lst.de>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Christoph Hellwig <hch@lst.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Richard Kuo <rkuo@codeaurora.org>, linux-arch@vger.kernel.org,
	linux-hexagon@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-riscv@lists.infradead.org
Subject: Re: [PATCH 0/4] provide a generic free_initmem implementation
Message-ID: <20190218094948.GA5892@lst.de>
References: <1550159977-8949-1-git-send-email-rppt@linux.ibm.com> <20190214170416.GA32441@lst.de> <20190214183854.GA10795@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190214183854.GA10795@rapoport-lnx>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000023, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 08:38:55PM +0200, Mike Rapoport wrote:
> On Thu, Feb 14, 2019 at 06:04:16PM +0100, Christoph Hellwig wrote:
> > This look fine to me, but I'm a little worried that as-is this will
> > just create conflicts with my series..
> 
> I'll rebase on top of your patches once they are in. Or I can send both
> series as a single set.
> Preferences? 

So far there wasn't really much a reason to rebase my series, hope
this gets picked up either by Andrew or Al (not sure what the right
place is).  I think for now just rebase your series on top, we can
then figure out how to proceed.

