Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D65A8C10F00
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 20:47:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C015218E0
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 20:47:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C015218E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 230B98E0003; Thu, 28 Feb 2019 15:47:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E08B8E0001; Thu, 28 Feb 2019 15:47:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 082248E0003; Thu, 28 Feb 2019 15:47:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A66618E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 15:47:08 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id e46so9161923ede.9
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 12:47:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=jcUumkTZJlj8tpUFNUe63opdiW3QEr6Jh+sXhnd1YOw=;
        b=QvrASllo3ms2W04ij0r+iv8QPUCr2yx2OmN0zdXLOnsqIJGRD36ZaWjUCc3LTBMOTU
         94APBd2gaZq8JXkJixi2fs1Q8GMhf/UNkbBzmwPSRs33s/Okpx74/RXBQgRYKxqtnklr
         lH8yzb70mPKkHnjwPZO2YKPG1DiOfDQc9WoWIIq8ELXW3KHlv7xn8g0RzLsSevunedk/
         fa9QnIn7ADF84pZlT6/amJFg6NrqEMUziQS+6av+iljlUvhdSwiBgNF5StyatiZXrDuH
         kxfPf7KkLsjiLWI1CzPwVXhjs5CuVdNBZTD0BEztyXTZe19fowULwNfC/SDBX4g3WUEP
         lViA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAWx/KnbbYCPCnQSDFHJHEsNerbD1li7uqEA2mtxM7jWzeLL5CQG
	2WYF1VG20zvDiv1yp61VMDv5JbShOuByQIklomV+z+KRrkDPDCQsSxSO31iwIjrKnc/S3IZJy/a
	iaskdq0zBekAOR0qCXh/BeO0tMWEiNyHx8qAae8/71f6WrUv1fzebQFDhGmbiw5Acvw==
X-Received: by 2002:a17:906:6d50:: with SMTP id a16mr536344ejt.170.1551386828181;
        Thu, 28 Feb 2019 12:47:08 -0800 (PST)
X-Google-Smtp-Source: APXvYqzIuMcM0jY2e/2xwdRPyp8Y18lCTjL1wXkvaELYfhEJMX7JZiGahvMa76nY9gWuBBpHjDeJ
X-Received: by 2002:a17:906:6d50:: with SMTP id a16mr536298ejt.170.1551386827151;
        Thu, 28 Feb 2019 12:47:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551386827; cv=none;
        d=google.com; s=arc-20160816;
        b=qynuiccsaonwqzYePApfqv2FcbFlYVl6HPZdRL4IZXhwDvZ/o7GPOTpYDxRlQXOlXe
         G3dFW1iumkl7oPJxI/Cf9f0pwciviEgXM2f02ciWRHC0wJrzVoXTnzG/sBzp4EZFEqno
         UC46fEnz/1n3wRR++Gqgwn/8y5hOYsUX8I7VGdSad8uMdXkg2S0Fs3zJlJIYsNRNWFVP
         GMqEWmL1l1fnYG66T5886g3cr5avJrLakVU9/Njm9aMB9ApKWIplZdjRrcUxXkn6R0/q
         PydqFNMXb9L5SF8dshJtl4EKFRuGwkcgyzixNYw5mSkDb+8kRU70Bi3F++CLAGQ7GqLE
         Ex5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=jcUumkTZJlj8tpUFNUe63opdiW3QEr6Jh+sXhnd1YOw=;
        b=VmaoCEtlc9WGjxNBVlaM59KMM0YZUzriVXAA2RDehqPqVgvC9uqN0RfndR7fvFje1C
         NzxpvgLUMtOZE347bP10bcUQL7TzwaxH+x8MxNAN2GgfO1+sAc1yExUSwHYcScvVsHOE
         nVxkjx8y1ec/A4Z5kgpUSxf7yZzwCo346Fa7vloshywi9/j2ErQDUhQCUv+mn27miU7+
         Uxkhe4PLNdVtCRCTxfzNikJuedI6rFcsSayOyLesKlBE5Jk02mvsBy7hGkd5C4QYukJc
         FmoH1MHZk2BBlEtgWr9otUBjnBYqno8jwT2R8KgvpIkRtL/lGlErmvMk4TmvHgLXeCqJ
         08gQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z54si4783134edb.1.2019.02.28.12.47.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 12:47:06 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7681EB179;
	Thu, 28 Feb 2019 20:47:06 +0000 (UTC)
Subject: Re: [PATCH] numa: Change get_mempolicy() to use nr_node_ids instead
 of MAX_NUMNODES
To: Andrew Morton <akpm@linux-foundation.org>
Cc: rcampbell@nvidia.com, linux-mm@kvack.org, Waiman Long
 <longman@redhat.com>, Linux API <linux-api@vger.kernel.org>,
 Alexander Duyck <alexander.duyck@gmail.com>, Andi Kleen
 <ak@linux.intel.com>, Florian Weimer <fweimer@redhat.com>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 "stable@vger.kernel.org" <stable@vger.kernel.org>
References: <20190211180245.22295-1-rcampbell@nvidia.com>
 <20190211112759.a7441b3486ea0b26dec40786@linux-foundation.org>
 <32575d26-b141-6985-833a-12d48c0dce6a@suse.cz>
 <20190228111110.564d84f62a1b294ca5b1f9df@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <adaf3f9c-ac69-9a0d-962c-a21d6e003fbd@suse.cz>
Date: Thu, 28 Feb 2019 21:43:56 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190228111110.564d84f62a1b294ca5b1f9df@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/28/19 8:11 PM, Andrew Morton wrote:
>>> Secondly, 4fb8e5b89bcbbb ("include/linux/nodemask.h: use nr_node_ids
>>> (not MAX_NUMNODES) in __nodemask_pr_numnodes()") introduced a
>>
>> There's no such commit, that sha was probably from linux-next. The patch is
>> still in mmotm [1]. Luckily, I would say. Maybe Linus or some automation could
>> run some script to check for bogus Fixes tags before accepting patches?
> 
> Ah, that's a relief.
> 
> How about we just drop "include/linux/nodemask.h: use nr_node_ids (not
> MAX_NUMNODES) in __nodemask_pr_numnodes()"
> (https://ozlabs.org/~akpm/mmotm/broken-out/include-linux-nodemaskh-use-nr_node_ids-not-max_numnodes-in-__nodemask_pr_numnodes.patch)?
> It's just a cosmetic thing, really.

Yeah the risk of breaking something is not worth it, IMHO.

