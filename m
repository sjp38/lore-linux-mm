Return-Path: <SRS0=z6ed=UP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63122C31E49
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 10:37:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 18E342133D
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 10:37:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="kgrOCNDV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 18E342133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A32C16B0007; Sun, 16 Jun 2019 06:37:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E3B08E0002; Sun, 16 Jun 2019 06:37:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8AA6D8E0001; Sun, 16 Jun 2019 06:37:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5172B6B0007
	for <linux-mm@kvack.org>; Sun, 16 Jun 2019 06:37:50 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id x3so5486911pgp.8
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 03:37:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=D66IwRD66+bBr49h113lbcClZo8OrbEzuxhoETswyAA=;
        b=S2M7gBFiWXYFI0h1T6sEQ+MLoNAwQJ299c63t03a5oRH0bFW05QpBsZa14nKfhMLLW
         d5VtZUU+1Oup0iOUJLunFjnAb0xwpyh6xpTapDXGQb60Yvhmkc1PmBeRuS8Y6W6CTmNB
         q2nTyhPHyXWGAzyWf+FYofh3WQx/G0VOF0S4022BQ4ASwoCVzIDYxwRcQpWVcBqDjpth
         x/hDxmXeE1ZG9U3pK71B+YNsWuyZ7/pR95+eX8vFL3F5Jv+OFSx51p1IiXfjUIqUpwdm
         wFP7VnIsH9/R6d8+BS10VoHN+JWuRubPhLDWZONjgLm2TqqBNpf2/ripwvhoB4EOF3wE
         gbAw==
X-Gm-Message-State: APjAAAWplyhSjcEGp5y/hIFhoXJMnhF3Urx7iyQQRsE8NIiHhcZwEjdC
	8/p6fi+wIjf9l/09ULTVNXckUUHQ42GVwzZH2/4ymz/UZWBv+0MinRp62YCddHZSWPncteNWuwJ
	+KWFgkoAJTJGdJ0SetE0656IxwVKR4aBFRCluioIgzRyDmxtogv3B95RA4CqZiaPC0w==
X-Received: by 2002:a17:902:ba8b:: with SMTP id k11mr1001682pls.107.1560681469926;
        Sun, 16 Jun 2019 03:37:49 -0700 (PDT)
X-Received: by 2002:a17:902:ba8b:: with SMTP id k11mr1001645pls.107.1560681469032;
        Sun, 16 Jun 2019 03:37:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560681469; cv=none;
        d=google.com; s=arc-20160816;
        b=sbh3eeh6WlRdkDhuz0K4Y7XrNQXBnih2yzXC79KLoO69l+pS01duFMtEX6W/ME1F8D
         k8rTOzi/Gqa0rFjnHeyLsXhLH4yaodSopeotx3+OB+L0cLA5JiFyqsGBZERPQwj/Bu2c
         zTWOcfB1SCqpanfcSDetnNLKTioe+koQNmbtLVk3TL43HK8ML4lxwuoZh0QMqhyBqhq9
         1tZTUx9+Qp25XbxTHOnQy2CspwufeVD6uXUuS2y+ZkpZHJqU0k1JDCsN3KpPOR4zml+B
         LFio4oJvMIgES1I0o3T9lp3Tn6ZW5SwpbsQw4ZJG22cI/Cy6VWEzCWkD4v1XQKWVD+AQ
         d1LA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=D66IwRD66+bBr49h113lbcClZo8OrbEzuxhoETswyAA=;
        b=Z5Cp3t0CDTEEhzqH9cnH7iyfJsX0UTH9tdoGvcDRcB9OYIj5Z0b+K23jzN8Mhb0mDw
         NuUjZKX8HrqI3LI1saV2dSNplqDIuPeeWJDngeh0tXzN2LAoNZ7xiCMhG615fmiFCx3Q
         6g80g07PHFiLBpoy5+h9iof9RYSf2EVzP4I3EKNpY5mapghkRSWnYfKxd74K5oK1i0hO
         dmw2QY7CneDDCQoMI/6Va3EuJGEXErCuaZMyyZjswg/SdFtITKM+Lz8MO3Peqk2s87cg
         2KWAW/n+3PNL6+F70BjYMyh0YJMbj+IB2+fhBjBnr1Dhvudcf1pj7B4z6w5aokSpO81G
         +9aQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=kgrOCNDV;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t1sor9573801pjo.17.2019.06.16.03.37.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 16 Jun 2019 03:37:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=kgrOCNDV;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=D66IwRD66+bBr49h113lbcClZo8OrbEzuxhoETswyAA=;
        b=kgrOCNDV3slPKYPtT/XUkerWgc9N6kmRSVG8nhJbBPj7PsOQxHbX7sRVeKyB4adSbG
         X7fAr8BFsvhhdJFjJQq8cqqa1pm7ssLdmRZi0Pjeq1tdaHh5DNhEfm/KHevQMnlnek9+
         wFq8e/uowrLJk81/22wplVkQzIPQqnvvx6Aes=
X-Google-Smtp-Source: APXvYqzuJgQl+102uUA83U5N3hshdRoQSBwu1PZlD2FrUikMytjIFjhKAz6HFlQnXa6TUYRoI/Xy6A==
X-Received: by 2002:a17:90a:7f93:: with SMTP id m19mr21160942pjl.73.1560681468335;
        Sun, 16 Jun 2019 03:37:48 -0700 (PDT)
Received: from localhost ([61.6.140.222])
        by smtp.gmail.com with ESMTPSA id h11sm8294436pfn.170.2019.06.16.03.37.46
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 16 Jun 2019 03:37:47 -0700 (PDT)
Date: Sun, 16 Jun 2019 18:37:45 +0800
From: Chris Down <chris@chrisdown.name>
To: Xunlei Pang <xlpang@linux.alibaba.com>
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH] memcg: Ignore unprotected parent in
 mem_cgroup_protected()
Message-ID: <20190616103745.GA2117@chrisdown.name>
References: <20190615111704.63901-1-xlpang@linux.alibaba.com>
 <20190615160820.GB1307@chrisdown.name>
 <711f086e-a2e5-bccd-72b6-b314c4461686@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <711f086e-a2e5-bccd-72b6-b314c4461686@linux.alibaba.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Xunlei,

Xunlei Pang writes:
>docker and various types(different memory capacity) of containers
>are managed by k8s, it's a burden for k8s to maintain those dynamic
>figures, simply set "max" to key containers is always welcome.

Right, setting "max" is generally a fine way of going about it.

>Set "max" to docker also protects docker cgroup memory(as docker
>itself has tasks) unnecessarily.

That's not correct -- leaf memcgs have to _explicitly_ request memory 
protection. From the documentation:

    memory.low

    [...]

    Best-effort memory protection.  If the memory usages of a
    cgroup and all its ancestors are below their low boundaries,
    the cgroup's memory won't be reclaimed unless memory can be
    reclaimed from unprotected cgroups.

Note the part that the cgroup itself also must be within its low boundary, 
which is not implied simply by having ancestors that would permit propagation 
of protections.

In this case, Docker just shouldn't request it for those Docker-related tasks, 
and they won't get any. That seems a lot simpler and more intuitive than 
special casing "0" in ancestors.

>This patch doesn't take effect on any intermediate layer with
>positive memory.min set, it requires all the ancestors having
>0 memory.min to work.
>
>Nothing special change, but more flexible to business deployment...

Not so, this change is extremely "special". It violates the basic expectation 
that 0 means no possibility of propagation of protection, and I still don't see 
a compelling argument why Docker can't just set "max" in the intermediate 
cgroup and not accept any protection in leaf memcgs that it doesn't want 
protection for.

