Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42C7BC10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 07:00:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ECBC420850
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 07:00:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PmlG1wAT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ECBC420850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 84A016B0005; Fri, 12 Apr 2019 03:00:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D0186B000C; Fri, 12 Apr 2019 03:00:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6BF766B0010; Fri, 12 Apr 2019 03:00:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 236216B000A
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 03:00:32 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id k4so6019719wrw.11
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 00:00:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=4Bbk35aBCZESEHG5RuZnD1QaHFZgpzC3BQiZIJk+H7A=;
        b=OTGdTQ0DKmn8GEgtO6GSUMyio3VwSGlXK1XENPMqJ1JYaGD/dLjWOEOpuRQqc8nSOQ
         uYV1R7paCng7x1rUebUHXINnkb5HUlk8qLAKxafxNfHZ83id86U4UnUhusgtf/pdbKB9
         Avg6IcyT3U3hChRR4u6QHsLQm+klYTRoAHMtYORZXFEgZR6pA2f0EZ1CKjM/t0sb1wcX
         omLI0wd5FHuu3DGLlJITLJJaM2QxRnrq0KZrO9mwpW5xwdjueRFoDezqn6LhvITnGo4S
         MRnR+x1y+/NlHNj+hENBCCyaNbQhmPvhxiwbcJl09yLz2NCp3T8ma/KtlL2IluIVGobI
         s14w==
X-Gm-Message-State: APjAAAUGsT/sMgPB6a0YQpto2u9Uj7+HrxRX5y06iV99M+xgMVp1Hgqd
	kiFi/EI3++kyW8ZIa0RSwwLMwYobPYhiRfINbm5nAokZiin7ZuSoKsabEKGUIztcooXJrtCdlpF
	dBUZQAljU/zex3Qkuhm4WAD5JjQces1jLwoSnOM1b6JfVZ84mjqCuFaheckMBYvY=
X-Received: by 2002:a5d:670b:: with SMTP id o11mr21593027wru.125.1555052431663;
        Fri, 12 Apr 2019 00:00:31 -0700 (PDT)
X-Received: by 2002:a5d:670b:: with SMTP id o11mr21592974wru.125.1555052430832;
        Fri, 12 Apr 2019 00:00:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555052430; cv=none;
        d=google.com; s=arc-20160816;
        b=f9+irD34YwFmMmUe/+pD3ccekLKjdJP1WV3eExJJzSpTpFKzjBVcB+C2RNxnPeGZm7
         97OGRsXe0lfZHL5jGEHiKE1xsIBCkyGDRki0mQVYNXyE7ihcuuMTEzfvnfhoqPCqGvQn
         FRhPBzjUdxSHFcB0IkBBx+L8u/WD3EtPM9agBcVkmw+72bbKKSl6KlaEweGAtRbQmv6h
         paCAkhpQQc+mY4lNU6juglTONxsQpAJ3sCLt5XWfjlTXYJdzjy5SGizU2wiGmpXkti12
         tge1LVhEFNavspJsSqaibLMPvQvIPj3U/AWYzMlnlMUZLtU2sjE3Meg+Uyszoy7Fd3IK
         M9Iw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=4Bbk35aBCZESEHG5RuZnD1QaHFZgpzC3BQiZIJk+H7A=;
        b=p2XfkF4wGzN1Ma1BkNqolOzu5gEPga2DkGlEKZDvNcnWwR3cRMnfEOU+mDT/Fy8qVe
         NqeVGo4FDgqfoK9EsAchJ3q5wWzvsMKsXA7ADWFEUp/93+YVcOVm+jCuw1SkuJvc4oMf
         mGN8slHFQJkhAo8sgJFYURtPNXOmxtRUSEx9+jTATMXFTHxwYpp277o7snLRufdDKm6c
         Mf1kgIOyUekPGGGM3PjN3u3j7DHuK7X8VoutIbEEZ3PVKiFU6Sl4Yqf4dhWhRhxTHqFc
         0TlbuGzXGHp2tcqZprcytk0fTz5pyrL1Qqy9fFmGwFFkYucwfhnd7MkQ5ZqhO5BTOxxE
         ESDg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=PmlG1wAT;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l26sor5364511wmg.26.2019.04.12.00.00.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Apr 2019 00:00:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=PmlG1wAT;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=4Bbk35aBCZESEHG5RuZnD1QaHFZgpzC3BQiZIJk+H7A=;
        b=PmlG1wATxN+yYRJGI5HrsADPBKacqPwGDNzYciIeJunLtv8rqYm9e0A2E0B7k4CcvF
         /h62GzJFu2wVaZmnPrE3zt7Zg4OW+CqUJC9Xdqxj2HAzq44uOCq/vsWYaMN7GMIU2rG3
         HzGHDnmDnQcbhp3VJHLHOqst6veeJ39jtWd3aMiSPEAy8HSfwuHrA2I9rQc76i8vuTrz
         jBt0NuXlXe5gtFJUlsdV5ll6sCDHqFbG0wmPrFWdxnpz+yt6Miebxo17xWBArl7JJMKR
         X6kfUmjGaPivonV/ItIuu0tKBP0Gf/pt0ODYWDGIoEHbSodZ6HL+t9K9Aivy9k6gEFke
         Uy9Q==
X-Google-Smtp-Source: APXvYqy7AAcYtxGhSgkFdnH8n+8rnMF9kvqttL6gxc+5XUNk3J1ebSQNRdh0sL1NtXBy6UNzvVdpvw==
X-Received: by 2002:a1c:cb0f:: with SMTP id b15mr9176981wmg.88.1555052430515;
        Fri, 12 Apr 2019 00:00:30 -0700 (PDT)
Received: from gmail.com (2E8B0CD5.catv.pool.telekom.hu. [46.139.12.213])
        by smtp.gmail.com with ESMTPSA id q24sm6481754wmj.26.2019.04.12.00.00.28
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 12 Apr 2019 00:00:29 -0700 (PDT)
Date: Fri, 12 Apr 2019 09:00:27 +0200
From: Ingo Molnar <mingo@kernel.org>
To: Chen Zhou <chenzhou10@huawei.com>
Cc: wangkefeng.wang@huawei.com, horms@verge.net.au,
	ard.biesheuvel@linaro.org, catalin.marinas@arm.com,
	will.deacon@arm.com, linux-kernel@vger.kernel.org,
	rppt@linux.ibm.com, linux-mm@kvack.org, takahiro.akashi@linaro.org,
	mingo@redhat.com, bp@alien8.de, ebiederm@xmission.com,
	kexec@lists.infradead.org, tglx@linutronix.de,
	akpm@linux-foundation.org, linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH v3 1/4] x86: kdump: move reserve_crashkernel_low() into
 kexec_core.c
Message-ID: <20190412070027.GB129493@gmail.com>
References: <20190409102819.121335-1-chenzhou10@huawei.com>
 <20190409102819.121335-2-chenzhou10@huawei.com>
 <20190410070914.GA10935@gmail.com>
 <31b41dcc-0d16-d1d0-bff9-dec3e77515c1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <31b41dcc-0d16-d1d0-bff9-dec3e77515c1@huawei.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


* Chen Zhou <chenzhou10@huawei.com> wrote:

> Hi Ingo,
> 
> On 2019/4/10 15:09, Ingo Molnar wrote:
> > 
> > * Chen Zhou <chenzhou10@huawei.com> wrote:
> > 
> >> In preparation for supporting more than one crash kernel regions
> >> in arm64 as x86_64 does, move reserve_crashkernel_low() into
> >> kexec/kexec_core.c.
> >>
> >> Signed-off-by: Chen Zhou <chenzhou10@huawei.com>
> >> ---
> >>  arch/x86/include/asm/kexec.h |  3 ++
> >>  arch/x86/kernel/setup.c      | 66 +++++---------------------------------------
> >>  include/linux/kexec.h        |  1 +
> >>  kernel/kexec_core.c          | 53 +++++++++++++++++++++++++++++++++++
> >>  4 files changed, 64 insertions(+), 59 deletions(-)
> > 
> > No objections for this to be merged via the ARM tree, as long as x86 
> > functionality is kept intact.
> 
> This patch has no affect on x86.

In *principle*.

In practice the series does change x86 code:

> >>  arch/x86/kernel/setup.c      | 66 +++++---------------------------------------
> >>  include/linux/kexec.h        |  1 +
> >>  kernel/kexec_core.c          | 53 +++++++++++++++++++++++++++++++++++

which is, *hopefully*, an identity transformation. :-)

I.e. Ack, but only if it doesn't break anything. :-)

Thanks,

	Ingo

