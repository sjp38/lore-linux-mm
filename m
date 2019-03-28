Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63F02C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:24:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 20EBB206BA
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:24:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="jBLvne+Y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 20EBB206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C45C06B0282; Thu, 28 Mar 2019 11:24:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C1C886B0283; Thu, 28 Mar 2019 11:24:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B339E6B0284; Thu, 28 Mar 2019 11:24:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9210B6B0282
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 11:24:51 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id o135so17807792qke.11
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 08:24:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=isKXPTi8LFmieVU9az7vGWyOVcJN5veMcrXh05ersr4=;
        b=mChKMsh3RE5zoTlDCbcfGLw/rKYtcJNwrBgId8F51UiIvlK8R+IYi0QxuoUgTjm5Aw
         XL4B8lFFUBfKvYiUMEuK1laP5jmYHlpLL/g8rZKxlJ51NyhPYfiLIJu22ENoGBocqbUe
         sNNOdhZes4iSKlUhGHvh3X9r1tDANXLeHGtubBNfM+sHZLA89vRngh65vFU3DUnLrbgB
         v/bCZWtdGJQ38+aNnFikJcWLdjmcbMSoqpsEn9sx1cK8NcI+TM44InmpflDrfhdZkayo
         yeHZzsI78RohiHcJV7IfWTZpXDwasnU97BO33cN6Gfy/XfJjvZA9x6BWnyuubmfEDq56
         R/uw==
X-Gm-Message-State: APjAAAU2eyPAl3FVLahrQjHzFVfzk1JQ0xsnwnaJkuZ+FJCw/14SI3No
	pDgyzk4qaXcxkuUs1z0TYnIIgbqmQZxRkvcbldK11XNWoP3X6wkHTK8b7xjXSNzDYVekU6NOaJf
	Irx9CQv6tpsVtV8gf0zC7MhZDJROtKaxxy+6fVLe8K3k3GY2eGtzF9BA3hX2COT3M+Q==
X-Received: by 2002:a0c:98b3:: with SMTP id f48mr35714117qvd.202.1553786691323;
        Thu, 28 Mar 2019 08:24:51 -0700 (PDT)
X-Received: by 2002:a0c:98b3:: with SMTP id f48mr35714048qvd.202.1553786690463;
        Thu, 28 Mar 2019 08:24:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553786690; cv=none;
        d=google.com; s=arc-20160816;
        b=nR9FFdAzFJ2YodGmhF88Cun62cuySr4xvL7FcVHAuPblMQMIUFtPYNd+yQoVRCoNT4
         0c0SwX6I9xczNXl2wL+dqTmup+755M/Y7wkN/21L7j+l+ay/bGp8yrkllkDS49dOh3uv
         a3VVUGvncQjWYsszqcaBWb7gxnEpdJyI6Y/18py1MuPxVJRWvKamcfNvcaLkIykJtlEB
         q3ZlLLHYTmZaSZsN/lwK2ka686oi13/1zD6SlLW3Di6lI1bJwqk1nxY4HiktKEyc1ykv
         MuLM6gccRBTR9cqYkhA8j2N7i2xwnN7wwf5cmBTTa9oS79DrIGpYLiHpONLTQW7R0t9L
         gUiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=isKXPTi8LFmieVU9az7vGWyOVcJN5veMcrXh05ersr4=;
        b=EECdGRoCB008H2JE5zV8S/26bExEzvVR3H7isjux4f+KNkJmcyLc5m4V/YVh3hOGkU
         rGNaGZP284Q+1gTGVL2UI8ukDYOtIDmhu3MxaCTE3u7m3OPrRLnCb4vEaYN/H70sae+e
         gRtxWTyDZKiK5UKh250kWFwoMdRuiD6EzwGrCRvuhI4dffndG82qKSyDW0DK/kPNjCeO
         6X2Klhr2Yuxuw7re2qVXME0ZbbknrOapf8q5eGdVqJUuXzT4AUuPfVPe9MT1j6FBdq27
         wy+HaSRQ4Tho9p5A0P+4FJwIOz/qbZHNhXGT5n3g7KrClSEkDjqAqkwvTm4/UC3T1jv2
         qcsA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=jBLvne+Y;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m38sor26133990qvm.58.2019.03.28.08.24.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Mar 2019 08:24:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=jBLvne+Y;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=isKXPTi8LFmieVU9az7vGWyOVcJN5veMcrXh05ersr4=;
        b=jBLvne+Y5fUraduT/VckpbPVKTob1kJZoDxd9KIjZfV7U+A806jqSPp/3QykQO3IOL
         fyiBYokAsKRGPXyKm9dUIYpXQjenxKIR799LfwrYU80WZCiMf7RkKCJ0xMgXRCY3xARP
         IHclH8z4Gz3yeTTYZNYpg7mhCT38xCQg+18K/v5Jtb2s/1svWH6+lM84nFnGOi8VvPOt
         mIWCvs7RJ35Tx/39vtbXtYmwM1G3xfqHBpV3TJF6f+i613mkgc4W6X9aY861AMQrrBgB
         Z5Ks5QqGIv+9dqQTPzarnv6W7YWpxaLDKmEcsbklI/SHB/y/ebAtD0cE0jNhNTD1BUao
         IMsA==
X-Google-Smtp-Source: APXvYqzeVsoiYbOK4d1VbCnhthXv63Uaa1JU9I1KDKpO6mOK9lOyKBYREjeg0vBsAw56x/2RTtLzGA==
X-Received: by 2002:a0c:afd4:: with SMTP id t20mr21676186qvc.128.1553786689804;
        Thu, 28 Mar 2019 08:24:49 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id s43sm14189589qth.47.2019.03.28.08.24.48
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 08:24:49 -0700 (PDT)
Message-ID: <1553786687.26196.26.camel@lca.pw>
Subject: Re: [PATCH v4] kmemleak: survive in a low-memory situation
From: Qian Cai <cai@lca.pw>
To: Catalin Marinas <catalin.marinas@arm.com>, Matthew Wilcox
	 <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org,
 cl@linux.com,  penberg@kernel.org, rientjes@google.com,
 iamjoonsoo.kim@lge.com,  linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Thu, 28 Mar 2019 11:24:47 -0400
In-Reply-To: <20190328145917.GC10283@arrakis.emea.arm.com>
References: <20190327005948.24263-1-cai@lca.pw>
	 <20190327084432.GA11927@dhcp22.suse.cz>
	 <20190327172955.GB17247@arrakis.emea.arm.com>
	 <20190327182158.GS10344@bombadil.infradead.org>
	 <20190328145917.GC10283@arrakis.emea.arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000007, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-03-28 at 14:59 +0000, Catalin Marinas wrote:		2
> +/* minimum memory pool sizes */
> +#define MIN_OBJECT_POOL		(NR_CPUS * 4)
> +#define MIN_SCAN_AREA_POOL	(NR_CPUS * 1)

I am thinking about making those are tunable, so people could have a big pool
depends on their workloads.

Also, I would like to see a way to refill this emergency pool. For example, once
OOM kiler freed up more memory. Maybe at the time of kmemleak_scan kthread
kicked in and then monitor and refill the pool whenever possible.

