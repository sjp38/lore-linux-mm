Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0F2DC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 10:30:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91D6E206B6
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 10:30:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91D6E206B6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D36A6B0003; Thu, 28 Mar 2019 06:30:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A7206B0006; Thu, 28 Mar 2019 06:30:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EFEC96B0007; Thu, 28 Mar 2019 06:30:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 999826B0003
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 06:30:28 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id p5so7909702edh.2
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 03:30:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=0tN6E6/at6hVDKW/CRFmlOCD7fEuO3l9mz62aHzChc0=;
        b=a0bdlMGRDXguehyUh8BKqYDAAA0TAqPssOW+NnL3xFpudPuzHJjHJ8MwAQ/xWgJxMG
         fK199sXxrV570nuY9xVrU6IXiBppafeJIfmx/JbGi6EfSvF+lFVSMx6RzWU8AOMoe8tx
         zklwKzJxNmkI2RUEmg0pauDg7TF/WQqZ/bDO+DYBAZegIKDaEX5Vn45Tme7fz1lyF9mO
         wbK9tslbCKHWOhMFYjI4VqQNf38DB20H6z3wAtaU3uCbINBEV23EpmJR0rRoWsF/W+NS
         OY9ULC0olL/3MlYEDxh5DKXfoQlHs2QIKB+zIqOip/8mqvCUA3KxroBeQyXajL/XcpI9
         ImSA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAXDHhpd9yAvxYprUzlnpXG3aJZV7GRV+wwRWSDz4EJHu/VsyE93
	ukkcr/y9lPMImnKs4JuFNH+lP+E5WI7rJr+X4Y8hZmg1k2cZNUTXrz6XBMcmEMZ/8CjUTfRiNSm
	qqh2jnePp12kUqGI4C3GNZWPAQzvbkKk7h2V7+UcO3nAjaqK+G+Vj6oOfiwobRDQ3/Q==
X-Received: by 2002:a17:906:3612:: with SMTP id q18mr20179081ejb.147.1553769028187;
        Thu, 28 Mar 2019 03:30:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyeffQ71D71D73rrlOpRKe1wtIJmkna0/aKC3siQoUiRpqkyxBh8T1ANjvSlpHef2A16eas
X-Received: by 2002:a17:906:3612:: with SMTP id q18mr20179040ejb.147.1553769027163;
        Thu, 28 Mar 2019 03:30:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553769027; cv=none;
        d=google.com; s=arc-20160816;
        b=a8HE/vo6ZwZStYaDv4RJG1F72I1eckpg4+K9uxvXKs38UdyoAnJz+eCyN4JU6DsJAP
         2m/NE9V8CWvp2ujQOC/ejvyHo4vviXcjz4uRPO4czTqKmVvsexaYBPW8DL/IniVzfafb
         EgPuHpBdbvVhMh2yUFu6AFToftdbpdMyJUfUC8wwYhyxixTm4A9RFsxZj8VU13Q7WgmN
         YqA9Zos6+PvgVp5sE+BEP5vqEFSn8qn+90x7vinaKVSRnv5QaH6UcBDmhxSH5nyHwTLi
         pVAN6YULf7MTOWS2aEBVFmmwYNq59ZtGELnbV1zESnnANBXAY8eq0ahxAqPRZGlJQBVC
         UY1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=0tN6E6/at6hVDKW/CRFmlOCD7fEuO3l9mz62aHzChc0=;
        b=KYBpkfJwKfyJXZZErLCChVyMZQHo5/ctEMiUIHmtV4ThddYvUcypvS1mITNRYPBki7
         B9likRxjRcFh+ld8AQO7Q7OF/sB2UiWueDYIa2jKd3UmF/ilG0dQUJ7z5aNqeryPrdZW
         w3v5083bdB+8O0SOBfZxdGANX0mroLBfemPrQPaUNlhwIS7sKvf+mv8vZjqbZ0qaVvBm
         Kwayl35i19D26heKAblG8Or0A3UeSW0jRV9AwWcFERv/M+DJnsLryuiqIIobtXfzASBA
         ectjPb9YZ/Y9JhBqO5Z3rEUWYmOnjLz3qBx4vTnWaFAdmU+L+G+mL32hM+tnrdkfemhG
         ZGRw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f25si1271660ejf.32.2019.03.28.03.30.26
        for <linux-mm@kvack.org>;
        Thu, 28 Mar 2019 03:30:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 16F7F15AB;
	Thu, 28 Mar 2019 03:30:26 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 03B863F59C;
	Thu, 28 Mar 2019 03:30:23 -0700 (PDT)
Date: Thu, 28 Mar 2019 10:30:21 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Pekka Enberg <penberg@iki.fi>
Cc: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org, cl@linux.com,
	mhocko@kernel.org, willy@infradead.org, penberg@kernel.org,
	rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v4] kmemleak: survive in a low-memory situation
Message-ID: <20190328103020.GA10283@arrakis.emea.arm.com>
References: <20190327005948.24263-1-cai@lca.pw>
 <c49208bf-b658-1d4e-a57e-8ca58c69afb1@iki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c49208bf-b658-1d4e-a57e-8ca58c69afb1@iki.fi>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 08:05:31AM +0200, Pekka Enberg wrote:
> On 27/03/2019 2.59, Qian Cai wrote:
> > Unless there is a brave soul to reimplement the kmemleak to embed it's
> > metadata into the tracked memory itself in a foreseeable future, this
> > provides a good balance between enabling kmemleak in a low-memory
> > situation and not introducing too much hackiness into the existing
> > code for now.
> 
> Unfortunately I am not that brave soul, but I'm wondering what the
> complication here is? It shouldn't be too hard to teach calculate_sizes() in
> SLUB about a new SLAB_KMEMLEAK flag that reserves spaces for the metadata.

I don't think it's the calculate_sizes() that's the hard part. The way
kmemleak is designed assumes that the metadata has a longer lifespan
than the slab object it is tracking (and refcounted via
get_object/put_object()). We'd have to replace some of the
rcu_read_(un)lock() regions with a full kmemleak_lock together with a
few more tweaks to allow the release of kmemleak_lock during memory
scanning (which can take minutes; so it needs to be safe w.r.t. metadata
freeing, currently relying on a deferred RCU freeing).

Anyway, I think it is possible, just not straight forward.

-- 
Catalin

