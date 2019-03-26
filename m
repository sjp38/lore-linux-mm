Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F37E1C10F05
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:28:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3F9420863
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:28:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="aHNWAGSY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3F9420863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F8426B028B; Tue, 26 Mar 2019 12:28:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A8D06B028D; Tue, 26 Mar 2019 12:28:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C0256B028E; Tue, 26 Mar 2019 12:28:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1AD0B6B028B
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 12:28:20 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id n10so14074602qtk.9
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:28:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=L/wpwKdMVG0oTQnXOWcN3I2M9b37/KAz7yPdS4OPMwQ=;
        b=C1hcdXvnD6EWwi7QCXjjE7nBnW4OFpHOO3AJQPwiHdWnu1fzRnji5R9UQxR2781Ot9
         egwbYuzdhTLkhL6fDg1drWwzqFBDoZZeZsyTbbY0pv/29EsHOyCr0Zh1a38XpkTusQgS
         PGXnDZJ+Veib30NeR4OK0nmZxn0qFtkeVBZtWaKOxi4QUeZEHoL5uDsrnkKYDzEEXL3K
         DPB5E6rQa0+MZUp9iT3jUEQFV744g5UPmTBXb171EkGwuoFg5LF00DJxyrjW8xvTGaU7
         qVYsuiEvi4vsHESaWErRuaNonx4AqocYqJBghHL0PETm2z4cgpFj1zNZatVLcML6EMLL
         tgUA==
X-Gm-Message-State: APjAAAUPUIB7TgBF7xMvX6sbhFzC7ZAlS397qHxt9/3cNWg4zGITwVYP
	14kG8t84zdwTxa+o2YW9Q6agy8GrDYPcltcRTaM4+Q8GAbxjT9MvCR89a8nVyQCGAf+YmzdplJG
	ONmY6YXkxYpQmIycw32qTz7Jr9okpmcCml2KInSvdeRNgECnYLwsfwAs8MvJpgg4KwA==
X-Received: by 2002:ac8:3126:: with SMTP id g35mr1938649qtb.244.1553617698407;
        Tue, 26 Mar 2019 09:28:18 -0700 (PDT)
X-Received: by 2002:ac8:3126:: with SMTP id g35mr1938493qtb.244.1553617696496;
        Tue, 26 Mar 2019 09:28:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553617696; cv=none;
        d=google.com; s=arc-20160816;
        b=BaSffVD6onwlTpSQnCHjLCFB8WilpYHjvrxf6sEW8tI7OF/Czj0LbsHRNoFGKIALzL
         HkGO5Klkvvwh4rvUlJ1ySopmL+hW/lscgjC5m9rqTrE6QGkBZr9yVQSOEzq9MuLRfvSF
         u1Z/hWc7PYAyv7w0nMxETXvIFd11rRvjLqSrz5el3xQb1CSohhmnDu9A2KxKMu/4o6mr
         Gm8QGACBLwnUIWSeTWi9D50RZ6QjyPA2mhzsoLoBt85bBNt5vTsf+LFj8oLHEQtk8mrr
         Mmfu6sNb8c9tJ5MWiOm8SsxAr051VezFMgc5dv7nmcOd0G+M5xs+eHFi0oLGx4Q8EMe3
         qu1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=L/wpwKdMVG0oTQnXOWcN3I2M9b37/KAz7yPdS4OPMwQ=;
        b=IMyePgtLZ+FjaGgN1l++R45+57I4Dl08GaKy4UMONGSnuy70UJFg5wP/MzgCRaMBN+
         4J/rEE7yWuzxMyFC8h4R/xzZS1a4Sah9j56QPrMGZwPhaDhf1oG6yEkaBVRLSf1Aq+T0
         AFVCJOajnBDfUwrNOpqEmO+s31gHr1CuEnEKp+p14zqA60OlDTha6OZhGNh9KrYkOXbg
         cbayibajkJnw/eDJQVPjXOSC1Pzd+N6IDS8Eook4KU1XLxUJjZZUdFez5JPZPjBpuxlE
         XcF4mxnbqENd0dbqJukunhvkW1jLDtYZsKIoNS8pxAWoEFvjMe56Rq/otPu5WFon6ovy
         b9dA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=aHNWAGSY;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t68sor13068137qkb.98.2019.03.26.09.28.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Mar 2019 09:28:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=aHNWAGSY;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=L/wpwKdMVG0oTQnXOWcN3I2M9b37/KAz7yPdS4OPMwQ=;
        b=aHNWAGSYHIFWV6wH602bIhuuhWG4H3Mq3O2ilDDUPsupq89kmcH1olHvnSMpKudKk9
         0SABcvyLgydmIATiCY2j6ReJSDWUrQjgmQV4QlX314dsMLp64ZeD/hQorkcs+3rHYFZZ
         7mjuhMM4sKqP7An2PUceO+DbEZ7nnlyLkeQ2Evhlzdw0eaufSAsXKgrfAdbd0Jd8vQxF
         1qt9mD6nNh2diI5WWkCPRKIVqrt+/OiZrkfmykws8GtGFYrxIYB3HqeOHo6QKq//qFY4
         6k9wvk9GWyUu5CwUB6VlbupyUNSn9kHQWpiMjlHsXrXrCwAVLqOGoGZnZK2nvelkRKzx
         4ZQg==
X-Google-Smtp-Source: APXvYqzNTgOCivPxOppSTk1fjSRUx7T9wxl9yba1lIORxq+vt5aG+dicMhJ5K4kqbQ2AjlfcolzCxg==
X-Received: by 2002:ae9:f509:: with SMTP id o9mr25059377qkg.133.1553617696254;
        Tue, 26 Mar 2019 09:28:16 -0700 (PDT)
Received: from ovpn-120-94.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id e4sm855103qkg.6.2019.03.26.09.28.15
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 09:28:15 -0700 (PDT)
Subject: Re: [PATCH v3] kmemleaak: survive in a low-memory situation
To: Christopher Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, mhocko@kernel.org,
 penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190326154338.20594-1-cai@lca.pw>
 <01000169babb99b8-b583bf57-5104-45b7-a4d6-e7677c64ece2-000000@email.amazonses.com>
From: Qian Cai <cai@lca.pw>
Message-ID: <20540be2-5961-ea86-1ad8-50fbb4d15c6e@lca.pw>
Date: Tue, 26 Mar 2019 12:28:14 -0400
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <01000169babb99b8-b583bf57-5104-45b7-a4d6-e7677c64ece2-000000@email.amazonses.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000006, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/26/19 12:00 PM, Christopher Lameter wrote:
>> +		 */
>> +		gfp = (in_atomic() || irqs_disabled()) ? GFP_ATOMIC :
>> +		       gfp_kmemleak_mask(gfp) | __GFP_DIRECT_RECLAIM;
>> +		object = kmem_cache_alloc(object_cache, gfp);
>> +	}
>> +
>>  	if (!object) {
> 
> If the alloc must succeed then this check is no longer necessary.

Well, GFP_ATOMIC could still fail. It looks like the only thing that will never
fail is (__GFP_DIRECT_RECLAIM | __GFP_NOFAIL) as it keeps retrying in
__alloc_pages_slowpath().

