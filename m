Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7E30C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 22:00:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 799192190A
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 22:00:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="t33VxRIu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 799192190A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 131B06B0005; Fri, 22 Mar 2019 18:00:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E1CB6B0006; Fri, 22 Mar 2019 18:00:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F12BA6B0007; Fri, 22 Mar 2019 18:00:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id A2C666B0005
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 18:00:49 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id z9so844982wrn.21
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 15:00:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=z3kNb4x6nZaDJzrLCkv/8bMkNzuRCuubIRRX4PjKw9k=;
        b=YfhVG4hlfSHzvM80OqT2yVU6lxfeX6ADm6DCavRDtE95DEQy0gq4RQ3V6/ajtkjI0/
         KhOMLCPnDPJ76oZkQOa58d66onbZfdJZWskNulMZ9L0Vwr7FcnSX8zjhtLwJ8U9Dt2Oa
         Mn9QS8Urh5VgLydOlbRuupGmv2D7M6oQbfcuT/LTlKse/uppmAX+vBuDsKZkHRm+uAOQ
         pFUSSV8l4/vgVKrVaTY4KFn7W0pPv+KHkgHT9DxuPHOM8fq+tNUvSzWHTvHZh6FB0GXQ
         HcpD/OrcRGQJJUOcdDa3XvmNbmSMnCjdhxnN9JDqXbQNtOuvdNIGmTauSW9l7RVY9ATJ
         YAUA==
X-Gm-Message-State: APjAAAU3dQCXV7OIS/9h0EM8cXAHtn5jH2T2PWYSoYnx/UaDEGGEEyst
	Sc22MYWyHhwd2M7A20uwaFmZdY/XBO5mwW96BvgfvhdMxgbzfZm/grPSGhAdDUBbU5jv7X3KZW7
	AjsOXa8BnZNqgfg/tGUl+AVBA/ReWMa+nu0FDrialQkmTnrQYu9LnFtVs63wJaTpVLg==
X-Received: by 2002:a5d:414c:: with SMTP id c12mr8380144wrq.106.1553292049107;
        Fri, 22 Mar 2019 15:00:49 -0700 (PDT)
X-Received: by 2002:a5d:414c:: with SMTP id c12mr8380124wrq.106.1553292048377;
        Fri, 22 Mar 2019 15:00:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553292048; cv=none;
        d=google.com; s=arc-20160816;
        b=P4Ozqg2vP8OhsFeDt+UX6OGab+b64pPGxhmixXIuFcfpNzllme26awcyK6BEXrQJmY
         tOzUD1PboRXlPWNdzz2iAFLfi5FM2PWfU65ObS7Grnme2blvPOtKYzYaizAl/Fro2reI
         ck3p4tOjkJ5YTSbYebDvXyTWEeg0sZ85bdU62tNAIWNO4drjFn0BAAcZGNb6HhNGMWmz
         KIwTXZXWqnU/UqzbVQkpo6+Q2dSuZ294lHlVPj48dS5DEEsfkfMzFmUeIorC7LqBWzcm
         8Z4rgs12iVTe5RwW3spU2CZhjvag8n36vQ+p5Z4VbOjf90Qre4ts8tVjU7Q03z26mbzF
         clmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=z3kNb4x6nZaDJzrLCkv/8bMkNzuRCuubIRRX4PjKw9k=;
        b=GL15LeqZJXR1LFcVIOqkN4P+//I/FGPoKmXk5qsKt+OS5WwyCWUAin29qvydyD0alE
         h+ssPtC0eKqOylsIclOTERgMOvjgAIgPdE4T1Z10moEV9+juRUvaEin2cuzidQmCh6f0
         xJwOjEuw2TRkjGGLEWtZKSTzOeV6/uZQCFUJu9mBYz82TNA159vqxFdV7ZfPpmtT5xal
         bFFHrftxMXTFxn0e7eU8Yiob4pjYfo6bFrBDhM01IgRdCb5hs2v0k2ikFFeAtt57djwI
         kmOQQQSMA0ptOT4AViREjLlUw2nZWbbj225nSJftAqVTzjPiFja/uZfcuZxkhI314v/P
         JDkA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=t33VxRIu;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c1sor7252880wrr.3.2019.03.22.15.00.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Mar 2019 15:00:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=t33VxRIu;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=z3kNb4x6nZaDJzrLCkv/8bMkNzuRCuubIRRX4PjKw9k=;
        b=t33VxRIuRm3bprIjzdNlkZlPsKCoiKyBSPHzogx7bBAS/0Me5ORQuRWJPkoVAb30lf
         WWGBbCUiJE/BUNBvPVoeD/FvsAqwyOPJrFQNHfPKqCwFogqxeBdfod9IT8SeXk83lwBq
         U9Nu+yf0n+hoiMALOIPPIDxC2I56pXMvLTrQs=
X-Google-Smtp-Source: APXvYqy+28Y3POG72bfdj4XQtGplLT42sVDH12SaEUvGcCk2zH+sIkLmuKXHO/djaQJK+QEHIIdWfQ==
X-Received: by 2002:adf:ea81:: with SMTP id s1mr7629173wrm.277.1553292047861;
        Fri, 22 Mar 2019 15:00:47 -0700 (PDT)
Received: from localhost ([89.36.66.5])
        by smtp.gmail.com with ESMTPSA id 93sm18584487wrh.15.2019.03.22.15.00.46
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 22 Mar 2019 15:00:46 -0700 (PDT)
Date: Fri, 22 Mar 2019 22:00:46 +0000
From: Chris Down <chris@chrisdown.name>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
	Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>,
	Dennis Zhou <dennis@kernel.org>, linux-kernel@vger.kernel.org,
	cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH REBASED] mm, memcg: Make scan aggression always exclude
 protection
Message-ID: <20190322220046.GA7667@chrisdown.name>
References: <20190228213050.GA28211@chrisdown.name>
 <20190322160307.GA3316@chrisdown.name>
 <20190322131015.05edf9fac014f4cacf10dd2a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190322131015.05edf9fac014f4cacf10dd2a@linux-foundation.org>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000843, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton writes:
>Could you please provide more description of the effect this has upon 
>userspace?  Preferably in real-world cases.  What problems were being 
>observed and how does this improve things?

Sure! The previous patch's behaviour isn't so much problematic as it is just 
not as featureful as it could be.

This change doesn't change the experience for the user in the normal case too 
much. One benefit is that it replaces the (somewhat arbitrary) 100% cutoff with 
an indefinite slope, which makes it easier to ballpark a memory.low value.

As well as this, the old methodology doesn't quite apply generically to 
machines with varying amounts of physical memory. Let's say we have a top level 
cgroup, workload.slice, and another top level cgroup, system-management.slice.  
We want to roughly give 12G to system-management.slice, so on a 32GB machine we 
set memory.low to 20GB in workload.slice, and on a 64GB machine we set 
memory.low to 52GB. However, because these are relative amounts to the total 
machine size, while the amount of memory we want to generally be willing to 
yield to system.slice is absolute (12G), we end up putting more pressure on 
system.slice just because we have a larger machine and a larger workload to 
fill it, which seems fairly unintuitive. With this new behaviour, we don't end 
up with this unintended side effect.

