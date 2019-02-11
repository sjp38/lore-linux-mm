Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88617C282D7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:05:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1EB22218A4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:05:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="SMudvtII"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EB22218A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 52A198E0178; Mon, 11 Feb 2019 17:05:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D8308E0176; Mon, 11 Feb 2019 17:05:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 39FFA8E0178; Mon, 11 Feb 2019 17:05:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id E9B5C8E0176
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 17:05:35 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id 71so363723plf.19
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:05:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=r6d4Iq9ZUdFc3NnIATpKPSjP46QbD6fBw5BoX8ZKlj4=;
        b=CIa3iXiUdGWDhPqLN8jfWSMO949HuxR4cOgKOOvHOTzlKhOvbhCLqf/ohzn/OUx9eQ
         kNRWS5zFai3j0sQL0MWvoU8M0Mv9f7iCCiJxy6SzLLIr2tJB2P3fXfeePiT3eHa2O6Yw
         iKyEHjW6PM64u5Xdmad+KT00K8+dTB0fte7/+zGjb9zamjd7K/iMxlSJINYAMZfxPwoD
         P7C59YsfwI0JN5ROa33TjF6mXjUyJdeau2HK0GN3yVI/1vLVcOL2SnPoC1i5ds17BJyh
         h9vDs+bHYu6ukTyw9o93uPy6uXK1+x3j2TEKfu2gMseHHeSVTrR4QC0V66jAUJZTcitj
         IhDg==
X-Gm-Message-State: AHQUAuZ5+pbrYqRM2Yz6rHRdOeJ/H7WGb3jTamF2lRM0R8/MP+Jzj/Od
	Q9eWS24QZgTIkF9YVEAZc/xm9fODZIDmiJvQWuf1iEVlDz9Ggz0nIZEIyxz8mvO1xL24XZj3Dvz
	opeN7f8q0Mi6K5PN3CNKvFUsXwGrMCF7os+MVEDZSp3KVFqNJZwNlXVEet2x5YeRR7UmImlbuXb
	OA3siFiCed5MNIdjrX1ygBuZ+zz6Zn2F0LJak5+GD2Up+sL5eHZm+M+cGcAhK4tPgXGoBEKV6Ee
	kRJNldlC/++RgBZREpNR/eoB6d7K0hE6uunCdgBVvKDmCBWkulZr7y7Z8sIvzev/s+ZOKz0pp6Q
	OlIFWb/HNqEnF+LqEMkTUaoviBUVDSr4JzPsl1wusG0YrZhYG1pBOCfDHjqG70r7bx/H57kHhPX
	U
X-Received: by 2002:a65:4104:: with SMTP id w4mr444055pgp.158.1549922735576;
        Mon, 11 Feb 2019 14:05:35 -0800 (PST)
X-Received: by 2002:a65:4104:: with SMTP id w4mr444010pgp.158.1549922734868;
        Mon, 11 Feb 2019 14:05:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549922734; cv=none;
        d=google.com; s=arc-20160816;
        b=V0RzLmPnp612okXMAcYK8hkA0XkVQnQ1lho1XdklLSYlMlP0TWUrNw+OgdaM7lEscc
         FRDn/CAMaylhs0qKZ4J6L2XSIUxTNIDhNkyZ0IDuXsck+ZhQL9Ui38e3mI0aXKZEW56S
         BJs+EPDGZCqOzJSbltzVXraZBi8A1wOYq7EVZZXUFQ1MV0uUFVHhBDJz5sn/vDeufxQZ
         RX4RqxqP/l5ass5vkZi/UP89rNLO9wmRgKYuTh6/RUWPThpffIT7EkpL0cnvduu69OPS
         PXEDieb1RdCFnCzJud7/f+f2tLALDH/Nt+DhHIj/at+NweRRD/jBeZj7b38pHDP7OV5J
         oMrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=r6d4Iq9ZUdFc3NnIATpKPSjP46QbD6fBw5BoX8ZKlj4=;
        b=ppjnKmU5AEAHZYiXKie/W7Qb30zb01DTNY3P7Lm/jv2NVWrPYnGp0or8CnznFKOC9E
         Ph4KC8Ntrh1I0hbon7V+ZAtGX8fDwOxZk3kd3IrW6L8FHKkLrflPfo2TJsN5xS0BOYFM
         vTvNxJ0cXuAugurIGW0iG5XMRumW8PIRfpZ9ggqITxeVXK5ly+m1c2aOx/TQVRa1v7Y7
         sLR6MTFVsPRxYCo4G0To92WQyUBQB2PmoRLWibb+TsUwDux//BlCwz2n86+YhPCYg14/
         WWtWqy4JziwtAq29jp9m/Yyx1eXolXDORTODX/oW4tXGqQOR7+yAJS6vrdXVC0krTsHD
         GoHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=SMudvtII;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g3sor16320225plp.57.2019.02.11.14.05.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 14:05:34 -0800 (PST)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=SMudvtII;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=r6d4Iq9ZUdFc3NnIATpKPSjP46QbD6fBw5BoX8ZKlj4=;
        b=SMudvtIIQZ2Qjf6A07EdIekS09Zz49tEvLEVj8Mp6+9XPQ+LRq6CtgkisQpNWKVn95
         Qnud8+l30hgiFqlVnp3ItCdPnuoV4VhoumGfpGxY4wtnclGfFx2MguWDI/O10GWVV7lX
         GZhrTf4XNngRHjnEwjlXnBul/nzn4IX4h5bWtkBtDwlSEH2wG5ejY1+J60lge46YXqz7
         As3lNpHaJFFS7fFjwHrpDQEBc9GZREsY/804z6q2lacooGXN9yVbxqGFm3igMnsuQ2W5
         W3xmFMbUvgInNA/kUGo1/eadq/RcWQf+Mb0Pk1VzT6lCCc4nxLhX5VpW+6nbJRBgHIGr
         l5pQ==
X-Google-Smtp-Source: AHgI3IY6AjfibVCuaERGdyQt8cPCcy3Jn1o+yMfVdWNVIhIMqQBt5rK2GYdelC+meQ8+Xacm/ocOkA==
X-Received: by 2002:a17:902:8b88:: with SMTP id ay8mr470925plb.55.1549922734389;
        Mon, 11 Feb 2019 14:05:34 -0800 (PST)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id 64sm4006159pfl.83.2019.02.11.14.05.33
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 14:05:33 -0800 (PST)
Date: Mon, 11 Feb 2019 14:05:33 -0800 (PST)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Qian Cai <cai@lca.pw>
cc: akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, 
    iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org
Subject: Re: [PATCH] slub: remove an unused addr argument
In-Reply-To: <20190211123214.35592-1-cai@lca.pw>
Message-ID: <alpine.DEB.2.21.1902111405210.177387@chino.kir.corp.google.com>
References: <20190211123214.35592-1-cai@lca.pw>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000132, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Feb 2019, Qian Cai wrote:

> "addr" function argument is not used in alloc_consistency_checks() at
> all, so remove it.
> 
> Fixes: becfda68abca ("slub: convert SLAB_DEBUG_FREE to SLAB_CONSISTENCY_CHECKS")
> Signed-off-by: Qian Cai <cai@lca.pw>

Acked-by: David Rientjes <rientjes@google.com>

