Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B391C3A59C
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:18:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E2943205F4
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:18:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tjAQYIIr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E2943205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 84C346B02E1; Thu, 15 Aug 2019 13:18:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FB966B02E2; Thu, 15 Aug 2019 13:18:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 739E76B02E3; Thu, 15 Aug 2019 13:18:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0172.hostedemail.com [216.40.44.172])
	by kanga.kvack.org (Postfix) with ESMTP id 516C66B02E1
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 13:18:44 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 01123181AC9AE
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:18:44 +0000 (UTC)
X-FDA: 75825321768.17.wine53_4c2f1ad6a6146
X-HE-Tag: wine53_4c2f1ad6a6146
X-Filterd-Recvd-Size: 4668
Received: from mail-pf1-f193.google.com (mail-pf1-f193.google.com [209.85.210.193])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:18:43 +0000 (UTC)
Received: by mail-pf1-f193.google.com with SMTP id q139so1616648pfc.13
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 10:18:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=O0iU9h/CgsDkbZj91TD8RQDyFQ2IpZ1Yt3QLDe5vqPg=;
        b=tjAQYIIro/DnauaXI3INnjRJ/TkqSKPI5VSGVznvGeeUcH0xKxwESp9IFecKpept4y
         +TKAvO8LFDVo2JSUms7f4AHRLykJ3aWjv//YwbFmTCtpmd1PuO44oXTGx27ZPYbp0tCG
         VHFtbXKcpvCkHkhJ7FmwnWvPHbRKal59zAKDeiIEh51J2Se0/B2fYl1qdhPdYKC+nNtC
         t+USv/D8HJg3gS+E2b1TsBmCsghRIleh5YAorwhmjPW5URMuroF8cwyorpGyHFwaQPxA
         9YlgiSCiQOgTwIpD5QzJNmHSKLV1u0SinXcon/R22PEBoOuozKKr1wutxKfgWL+EU/rE
         i42Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=O0iU9h/CgsDkbZj91TD8RQDyFQ2IpZ1Yt3QLDe5vqPg=;
        b=VMAAdJIQ0iagO3DNx7sCVepGioodKD4BUJw1CdR8RWOPpZHj992fpqJy6358uB4dGb
         s7XvuWbwp0DN+fBbuaz0RC+dgbfh0V34cAe8DrO0em6wTudmE8kP5YIgPIc0xvo7FP3Q
         0yZW5sI+yrcE/5I0uqI1xuIvb1gdnHQ1nouzZPbvUdpD1HHhT+dTns1rEmNyHI4AHdHV
         5JeuXnaGZM5yMWE8mVvK0k9mQc53TNY0LZztpJX73th8770w+bHOoVeXOcYe6EOk0yM9
         7VXuR3uhUZFNW+la6G8jbfhj/zXx0uu6YXkMBzFjpb+9OPMwIGbzsTNj/ToQ3qO9qTyo
         el1Q==
X-Gm-Message-State: APjAAAV+cZnIQ0F+9XKZUNS+p1bAymUDirNkMWgAUCwgEGZsun6oZtG6
	6+TscDOGyK3GRg0fWrCoZss=
X-Google-Smtp-Source: APXvYqy7W7kXMKmt5qV1vz6zH8QBZDpT0zmtLNiJOWrKRdx4CqeHfrqqlOkAd7IoFjwEYuU4TVZlEA==
X-Received: by 2002:aa7:8f2e:: with SMTP id y14mr6509394pfr.113.1565889522309;
        Thu, 15 Aug 2019 10:18:42 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.34])
        by smtp.gmail.com with ESMTPSA id d129sm3343983pfc.168.2019.08.15.10.18.38
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Aug 2019 10:18:41 -0700 (PDT)
Date: Thu, 15 Aug 2019 22:48:35 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: rkrcmar@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, khalid.aziz@oracle.com
Subject: Re: [Question-kvm] Can hva_to_pfn_fast be executed in interrupt
 context?
Message-ID: <20190815171834.GA14342@bharath12345-Inspiron-5559>
References: <20190813191435.GB10228@bharath12345-Inspiron-5559>
 <54182261-88a4-9970-1c3c-8402e130dcda@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54182261-88a4-9970-1c3c-8402e130dcda@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 10:17:09PM +0200, Paolo Bonzini wrote:
> On 13/08/19 21:14, Bharath Vedartham wrote:
> > Hi all,
> > 
> > I was looking at the function hva_to_pfn_fast(in virt/kvm/kvm_main) which is 
> > executed in an atomic context(even in non-atomic context, since
> > hva_to_pfn_fast is much faster than hva_to_pfn_slow).
> > 
> > My question is can this be executed in an interrupt context? 
> 
> No, it cannot for the reason you mention below.
> 
> Paolo
hmm.. Well I expected the answer to be kvm specific. 
Because I observed a similar use-case for a driver (sgi-gru) where 
we want to retrive the physical address of a virtual address. This was
done in atomic and non-atomic context similar to hva_to_pfn_fast and
hva_to_pfn_slow. __get_user_pages_fast(for atomic case) 
would not work as the driver could execute in interrupt context.

The driver manually walked the page tables to handle this issue.

Since kvm is a widely used piece of code, I asked this question to know
how kvm handled this issue. 

Thank you for your time.

Thank you
Bharath
> > The motivation for this question is that in an interrupt context, we cannot
> > assume "current" to be the task_struct of the process of interest.
> > __get_user_pages_fast assume current->mm when walking the process page
> > tables. 
> > 
> > So if this function hva_to_pfn_fast can be executed in an
> > interrupt context, it would not be safe to retrive the pfn with
> > __get_user_pages_fast. 
> > 
> > Thoughts on this?
> > 
> > Thank you
> > Bharath
> > 
> 

