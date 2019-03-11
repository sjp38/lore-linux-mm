Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F402AC4360F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 17:58:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2A59206DF
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 17:58:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2A59206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kerneltoast.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4333B8E0004; Mon, 11 Mar 2019 13:58:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E41C8E0002; Mon, 11 Mar 2019 13:58:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2AA2E8E0004; Mon, 11 Mar 2019 13:58:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id EBF438E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 13:58:06 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id i67so2724044oia.22
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 10:58:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=aOZ8uHt6bncKFLR0pCiPe6i6BuhLZtI6G9d8bKnXFfo=;
        b=QMKB9e6bIX65mO4+g3NFQmVqNNugepz3+gyUpS4f0woILZt7xxP0FbaDrT5zlP+BP6
         qyC2jt7+0IuSLdlp31nKE5XNqXUXkMOI8jVdNlc7fVoj0fqjSEdQ+B0eKRXNxn0omm1+
         4NIj7/lQGvZ4XQeCcrNMiCBivf2zd7jhitX5I76bzSLeLRMx7ZpWDaCrgLRe/BVwBMd1
         ku/Qck1v73+HMASPl2OXnAvWGgGajny6oW1cJmkAhnAMT+nuL2moqDbeBrnmGj1xGJFn
         fmeIYfHKgW+AUECdQuflCpHK1Gj8hYowTerJ67qmZTUf7eT7741hWTqHiSIC5WASiRol
         PcaA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Gm-Message-State: APjAAAVxTZfa0qEZtV4gTPDwq+I2kWFAiNs1pdPa91ctQCsx6x6nv2dB
	mvenzc4syc7gwispSdlwXa1LeGipCgOhdA1fZEyz++WjTHyQlnqIX39Wp3xVz8BPtSCChXUKuQW
	SrM/cKmifEC4CNWWAw+hbxzzrxWuNCU/UQ51znWrYrfsQNLIfkB6mmdfxpLl1gk8=
X-Received: by 2002:aca:5782:: with SMTP id l124mr24298oib.66.1552327086571;
        Mon, 11 Mar 2019 10:58:06 -0700 (PDT)
X-Received: by 2002:aca:5782:: with SMTP id l124mr24259oib.66.1552327085703;
        Mon, 11 Mar 2019 10:58:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552327085; cv=none;
        d=google.com; s=arc-20160816;
        b=sUiRoVmnqBAO5hPujhkN5U1T9sHiTtzLmK1+NhZA4zOwTz3bzsca7u9OeOcouFzcrP
         xMSNit7Ls5Sjm1jfv6eZNxWlENdAwE50a/SNX+U92nWEHDFR/6Boi+uc/yYiwxuBTo9w
         txDx1QkkEuUyrJJKFlZ7qxbXYyLACZcb6Bu3vYanzmUQWF8V+4tKIPbPg7SIhqWIL2IV
         j+U32KVH7ctcq4cIr8MkuR3G0shKah+1XeuRohzC/9IAakYOPx61klI7RTcuafb2QZAW
         zj4QNaY5S1XvFaHb+ME8NexbMHddFY6GMmf9ksVujj45mSbMQ3Tg6FOOp04AUScgSbZE
         AfsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=aOZ8uHt6bncKFLR0pCiPe6i6BuhLZtI6G9d8bKnXFfo=;
        b=IN3Z+LHx/1KDhOmIsooRMomKOpCx9EOlshnXcwzMjNIW80c9BwiICXKgyVH5QukGEM
         IOvKrrLPg9Ei0+/Sms5mi9L2gCGu5xlQ9yKVKa73uet4wCLW48swdmBSCxjWWRfu8NYt
         XIJ1Hn3QhQUCpGD+1J0romtaNM7TXRrRK3ZuweHqzPYrP0Qip5m7VEO0N+W+d/O66pph
         kGsKPtDXmfcLKaNblXdJqaIv1bcS6X/NAsffIyv3jl4U+PdITIwc8ezdr0s+LMbzElJP
         ELiv5nQIERhDiHsv+JWsjgkM1RylTx4Ivae83afRQE7bYZ9ySv5EGFxxUCURoTH8GZMf
         1neQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b5sor3745547otf.131.2019.03.11.10.58.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 10:58:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Google-Smtp-Source: APXvYqxp5i+a1trQda4sLOjRTInRPRbCvFL/JMn9u2saDcEd/Yr+cSegABrd84KRU9OwYj5rNlksQw==
X-Received: by 2002:a9d:7841:: with SMTP id c1mr21854509otm.354.1552327085287;
        Mon, 11 Mar 2019 10:58:05 -0700 (PDT)
Received: from sultan-box.localdomain ([107.193.118.89])
        by smtp.gmail.com with ESMTPSA id r9sm2522935otp.81.2019.03.11.10.58.03
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Mar 2019 10:58:04 -0700 (PDT)
Date: Mon, 11 Mar 2019 10:58:00 -0700
From: Sultan Alsawaf <sultan@kerneltoast.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Christian Brauner <christian@brauner.io>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org,
	devel@driverdev.osuosl.org, linux-mm@kvack.org,
	Suren Baghdasaryan <surenb@google.com>,
	Tim Murray <timmurray@google.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190311175800.GA5522@sultan-box.localdomain>
References: <20190310203403.27915-1-sultan@kerneltoast.com>
 <20190311174320.GC5721@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190311174320.GC5721@dhcp22.suse.cz>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 06:43:20PM +0100, Michal Hocko wrote:
> I am sorry but we are not going to maintain two different OOM
> implementations in the kernel. From a quick look the implementation is
> quite a hack which is not really suitable for anything but a very
> specific usecase. E.g. reusing a freed page for a waiting allocation
> sounds like an interesting idea but it doesn't really work for many
> reasons. E.g. any NUMA affinity is broken, zone protection doesn't work
> either. Not to mention how the code hooks into the allocator hot paths.
> This is simply no no.
> 
> Last but not least people have worked really hard to provide means (PSI)
> to do what you need in the userspace.

Hi Michal,

Thanks for the feedback. I had no doubt that this would be vehemently rejected
on the mailing list, but I wanted feedback/opinions on it and thus sent it as anRFC. At best I thought perhaps the mechanisms I've employed might serve as
inspiration for LMKD improvements in Android, since this hacky OOM killer I've
devised does work quite well for the very specific usecase it is set out to
address. The NUMA affinity and zone protection bits are helpful insights too.

I'll take a look at PSI which Joel mentioned as well.

Thanks,
Sultan Alsawaf

