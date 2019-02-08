Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D29AC169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 17:04:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E29120863
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 17:04:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E29120863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A03B68E0096; Fri,  8 Feb 2019 12:04:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B2878E0002; Fri,  8 Feb 2019 12:04:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8CACD8E0096; Fri,  8 Feb 2019 12:04:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4BE408E0002
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 12:04:27 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id y35so2348674edb.5
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 09:04:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=cdlU+VZhcn4Q/Ev8l2zZBv/5sMkw4rptlGoQdChN/0A=;
        b=Ctsa1Sv4DtoqMeWIMourOe4SXCHdXZk1/WjOV26Qw5cpVlP2COxxgU3PW7l14c2Iez
         YiqMz1BB2eHoSTSP62wEz4L5xxPlCQhodUN0woJvkDTjjYBoNFu7ojsIlqq7aUoxOXG8
         xUEDqRjOpZTPh9KjKbB8EvconWY9PFSvswDDCVCXudyaHU2bGDHzPi4XyQSECiHit6av
         YdiuzI7ZMNllnF4NDJBJHx4gZap5B/2eAfomzEfLlhpE+6n0LpF/z8+4GSX7kSqEvO6L
         ldGrx0mZ9FjYXK2QH6UzkwVRej9lFSrv9NNlqPJ6B8lU/XNjMA/wsjdTmk2OB6FKaPVc
         RUeQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AHQUAuYciHaZiQy3fVIZ50Avg4GwqTD9TKyVCk9G90jmTdWulyGRAGad
	I7wvPAq12tQB1d49IgO27DwtX/giYX4Y4GPceGI29ErgGuEWPzDy7TMVf3h/hnXnrZ3h6Jx9ycu
	olQGUx37KryIhNCLb7JrURLrI7hm9EYp+Pd9Qz0J9EGIJnpRGpkHXNIDEABSZmA2yrA==
X-Received: by 2002:a17:906:442:: with SMTP id e2mr4693774eja.234.1549645466884;
        Fri, 08 Feb 2019 09:04:26 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZGYRpHJb/jgbSE0e7trQae9wGMHxdqPhbRP8zcDvfUrMPWIusBDa0ipyM9dIWJfsbyI1CN
X-Received: by 2002:a17:906:442:: with SMTP id e2mr4693719eja.234.1549645465934;
        Fri, 08 Feb 2019 09:04:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549645465; cv=none;
        d=google.com; s=arc-20160816;
        b=GRp3A9WrxaH5l6la+w0vSpYt4Kt00TDnP2bLyNEwWPjQkmh6+sOnnFTlKpdrNH0QGz
         uvXlGNwyw1OLl/2Z1uzR9hSRLkHY86OY0k33t6oXLhq6FEglf2DgZyXBYKfoolN8FCK1
         RB6MlgAy4vZGdVu1CnzLq/GZF1M2rgg/U/+YoQJH9sBnpPYP0jSXENkVAiAlpduRPP8q
         +/y9pZy/fYrWRKHzaFYB71f/0G0OLlM++B/uHKvxNuE5pY4a5I57RZG4VDqE8V5+Sp+b
         DP/WwOyfv6hhbUaq8xz4kNbV1FMjSMsTCpz5At74zY23qrR4bs5w2TVBQQO/D+fBiLqJ
         gEXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=cdlU+VZhcn4Q/Ev8l2zZBv/5sMkw4rptlGoQdChN/0A=;
        b=mELlIcuokTtAYZAr3tsDeeuT+J/x4koYe+kjtBw01JqlL2siGHJefcbY4BMJGguOQb
         An5J7Hsasa4P4R1LfpqzzcKh5hVhOSslUv4Pdu2vx+2Wbz8/NYlsj76UoKKmT4Qf6sjK
         PPxa6HbfpczgWxQ920IxvIaRLDWDwuuqA45XhpV/pA9ZM1UBo3hBiAtLNhG9Yw1In4xD
         yRI8qsWHvwV9AzXy8+7BCnvEtl/rLkEtevnSUtuAaL5QAD9/JsLtdRatRpF6DPEDoukr
         HGrlY+VzhkHiXd0DL6bYntT6nyjJQDmn8p1WRhZf5X42D3kYMtk/6Q4KvD4w0/RHhZNp
         rdIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b2si35287edf.294.2019.02.08.09.04.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Feb 2019 09:04:25 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 222A1AF1B;
	Fri,  8 Feb 2019 17:04:25 +0000 (UTC)
Subject: Re: [PATCH v2] mm: proc: smaps_rollup: Fix pss_locked calculation
To: Sandeep Patil <sspatil@android.com>, adobriyan@gmail.com,
 akpm@linux-foundation.org, avagin@openvz.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, stable@vger.kernel.org,
 kernel-team@android.com, dancol@google.com
References: <20190203065425.14650-1-sspatil@android.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5b8e236d-7c43-6c2b-cb3f-cbb0b8923fe2@suse.cz>
Date: Fri, 8 Feb 2019 18:04:24 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190203065425.14650-1-sspatil@android.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/3/19 7:54 AM, Sandeep Patil wrote:
> The 'pss_locked' field of smaps_rollup was being calculated incorrectly.
> It accumulated the current pss everytime a locked VMA was found.  Fix
> that by adding to 'pss_locked' the same time as that of 'pss' if the vma
> being walked is locked.
> 
> Fixes: 493b0e9d945f ("mm: add /proc/pid/smaps_rollup")
> Cc: stable@vger.kernel.org # 4.14.y 4.19.y
> Signed-off-by: Sandeep Patil <sspatil@android.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks.

> ---
> 
> v1->v2
> ------
> - Move pss_locked accounting into smaps_account() inline with pss

