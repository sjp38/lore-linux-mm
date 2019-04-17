Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24490C10F12
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 09:37:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D88702173C
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 09:37:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D88702173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 756476B026B; Wed, 17 Apr 2019 05:37:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6DCD76B026C; Wed, 17 Apr 2019 05:37:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 57DA46B026D; Wed, 17 Apr 2019 05:37:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1A88B6B026B
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 05:37:11 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id h13so1903324wmb.6
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 02:37:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=p3+WMJsX06hz3AZkgUwoaN8ttHZXOzN1uuAd9oTZKXA=;
        b=LxHwZeiJk8tKziVuQ83/KTa3eyMSRJkP5aZBx66m/3HkrQd8Aq+epcwyCVdrt38bM+
         iPgdBPwObtPj7rP1DYK0y9wHu8zg0h11gGl+cd1uhtkdikPoiwR4SyMRk4Ps2lcGwpRd
         o13XeaJkza8KmliM5CjAElExVeIdsvUnTGEohS6UyK3QIbzPSfCK0UPOZaf/HmXMaIVt
         FU40DHiQdM9NEdf3awjUX2ILwnmJfwUi+ejf64t8MOmO0tRrL1YuBEnmJhz7LGRP9Rbp
         lebaKeTffW7b4HsZBHxIS8S/2rUXVGuHGiUFEwVreEg/8l8pF1JzqWzwsuey275gZBjH
         FnKw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVMVHe/8/gUsbbP5qDDAAuKeaqu2IUjIey4ZDO+nKRHcJG/OBFu
	cje0/dHMIjrFNxpynm2yDXAv46ndRgyDKQcGn/BdO3jjGsfsxq4L8NDy/jOYurGN9DPHz+Q1qjl
	C5r6C8jnM/kXNy4l85bKusWCadBVZKYyBEDbynxC8seuq/MW2J/qzOfR8zeWR0XrtiQ==
X-Received: by 2002:adf:db10:: with SMTP id s16mr55962166wri.181.1555493830632;
        Wed, 17 Apr 2019 02:37:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz3pndiLgcJ7DKIrArnY0lysgSOb8cFXViNbzklGtyAwKj5bfSLTvHF3qTs92N3RiNd/QJ8
X-Received: by 2002:adf:db10:: with SMTP id s16mr55962113wri.181.1555493829884;
        Wed, 17 Apr 2019 02:37:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555493829; cv=none;
        d=google.com; s=arc-20160816;
        b=s5XzzxVLRpM8NrnqaQutq5VzYw7UHw25d+/z3d9rzsMfdF98d8uOsh7JoZr+eZSHhE
         jDrn/bmjstltdXNbWkxWPoqqnkSuzlJ0az29MELMt3iyYhDkYY06R8lJU/hGMTHiXCJZ
         wOJUhs6qjG5sRKAQQkxNOlHruv5JaW1OWZ3F3IknZd3sSlZprKYNArLc0ChgNCLQlBLO
         l4zW/ElYjfCi8mgZNCn9EszWOUudYGxmzXxoxsnhxIla2KvnwGT1Pu68IoJUkz2Oa713
         8Oci/C64ZfdMJgy9BsUwbXsva/utsWNIVUMMDh25sVHCd9zK5heHTm4IkEPfvXT+j4f5
         jGbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=p3+WMJsX06hz3AZkgUwoaN8ttHZXOzN1uuAd9oTZKXA=;
        b=Oor00mxlm1EJhWxsNkAQzvS8aqzM2XiRNkfN9q+T0AoS7DKhegfvivi1o8n50tkl/X
         03xw1pYixhnSRMtI4ZOvp3O+gJEcsnXhw+WOFUVfoX0XV9OIenlpPlfLv3wa0hTZO5rm
         Ip58lUg0hZzGvqA4v08dsXmQLDX1sl0MVBO2yxF0f/UKwlUc1Q50AyVxqPrfLQ/fWLcj
         bq56B5H45aBJvdRnw7X/wJSuIgH9DTKtb5d36tW59HInyUyKkzGV6k/GKq6P3EK6ctmW
         sV1AFPZvVWrQ8F0cNi9I24NlOC8ry5jrZfC72dMcFIZ8Y8Nn/jXkwgAN5GpoCDnZxmb/
         +jww==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id b12si31087158wrr.19.2019.04.17.02.37.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 17 Apr 2019 02:37:09 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef12d2.dip0.t-ipconnect.de ([217.239.18.210] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hGgzx-0008Us-QF; Wed, 17 Apr 2019 11:36:58 +0200
Date: Wed, 17 Apr 2019 11:36:56 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Qian Cai <cai@lca.pw>
cc: akpm@linux-foundation.org, vbabka@suse.cz, luto@kernel.org, 
    jpoimboe@redhat.com, sean.j.christopherson@intel.com, penberg@kernel.org, 
    rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] slab: remove store_stackinfo()
In-Reply-To: <20190416142258.18694-1-cai@lca.pw>
Message-ID: <alpine.DEB.2.21.1904171136410.1845@nanos.tec.linutronix.de>
References: <20190416142258.18694-1-cai@lca.pw>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Linutronix-Spam-Score: -1.0
X-Linutronix-Spam-Level: -
X-Linutronix-Spam-Status: No , -1.0 points, 5.0 required,  ALL_TRUSTED=-1,SHORTCIRCUIT=-0.0001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Apr 2019, Qian Cai wrote:

> store_stackinfo() does not seem used in actual SLAB debugging.
> Potentially, it could be added to check_poison_obj() to provide more
> information, but this seems like an overkill due to the declining
> popularity of the SLAB, so just remove it instead.
> 
> Signed-off-by: Qian Cai <cai@lca.pw>

Acked-by: Thomas Gleixner <tglx@linutronix.de>

