Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21412C43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 10:09:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CCC4F2084B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 10:09:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CCC4F2084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 548206B0003; Mon, 29 Apr 2019 06:09:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D5BE6B0006; Mon, 29 Apr 2019 06:09:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FE0F6B0007; Mon, 29 Apr 2019 06:09:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id CF44E6B0003
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 06:09:57 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id z128so9459605wmb.7
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 03:09:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:references:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=LlnFjg7cdPtMY68Qxa9DGaNp90LnLg5WJLNWEjaCUC4=;
        b=UqwCxN255vvLmZyy6rdWFOwRcF5NK954yrUrC+lKQ7DEO7iiKpIG+ANNJo8OLXa9vd
         H/oIs69H7ESvs/d9rc4foEFI/aPfc95Yv/Z6Od6lnU8RU2sqXml7HXg6FciBmlXtoDjs
         Pri/pmD7+YYARxe1sqsEs/R6bhmaihLfqLxgdoIx59Mr20mdUgzbjErxQLA6aKwLE0yb
         6Yfi5m/yE5RWOvFlKoSTE0PVvvjIrC6biTBaL3E/3oob1mokxNOvM26mat2nB+2PTNbO
         nPuDyWAoFmUgbAZCXaiRk34bXXqyVzcTOmqbcwz6D/QVV3I8QkQaocjLXwma7W1VuSCQ
         PcFA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jirislaby@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=jirislaby@gmail.com
X-Gm-Message-State: APjAAAUmde/dSKxcSm/kK/NIJ+41qoG8gwdKeRf1TnP/Coo/rFwChR8o
	G8/Sd3PpdtZPArEc2s+YJcjDo/U/smhvtpZJfAEXDf0zlcLIYpS+u8ElaqJmA+0FhZGJeXqps21
	apBtVuVYtSw1xAYjWCb+nLunKvEpnBbZ8pEBL76df+v9WVKlihA8ud/36DgsFwEo=
X-Received: by 2002:a1c:a914:: with SMTP id s20mr6916146wme.55.1556532597335;
        Mon, 29 Apr 2019 03:09:57 -0700 (PDT)
X-Received: by 2002:a1c:a914:: with SMTP id s20mr6916077wme.55.1556532596188;
        Mon, 29 Apr 2019 03:09:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556532596; cv=none;
        d=google.com; s=arc-20160816;
        b=oG8wf8BLeNNG9i5SQ1/AMsrV3B7MtaS9XiXwSuULPEXrrzp8lqGqOOhkVkRG3wzEHh
         o3YpgfmMVW6v9V7vVvLXgAhmntFtREdfbHYTBQtrB+yiatEFcLlmrIU1u54NgRru+D6j
         4YVsm/auHNFrzHHO5zj5l8u4XzNoB7GGv1G8SSRQ/+l9FaXjebouwwetEuX7ADiSi3Rh
         B8I17rrBHbtF1M3MrzrBLcZb5a0h8DBPKUU2w1ZW4uT2/9zueQLB9eThRQuaFG5lSPie
         t/Qp5QP3w9iwj0nF66QHRCfMyn24HscL2yez23hIwhdzAoyKhXY2z/GRadWWrBJ2shnR
         wi0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:references:to:from
         :subject;
        bh=LlnFjg7cdPtMY68Qxa9DGaNp90LnLg5WJLNWEjaCUC4=;
        b=WaAcPMiWcX40LgRS9svU7Qj+zFcr+WKdBEw+AuHtrJFfr/GFJ6Ssk0/Xd0Xvu+Y+p5
         zZiyqI16w6Fz5JethOlSTKCnGm6v/mgouZkmBGmtGaLZ9eBviAXsTM7fkydLjiURVItn
         s0mCnQSCf1M5/87XJsmZPVCNH0ldHZGMXZ4TsNRBHxsLFN3tRuVExyuEm5PTwYbHSjZS
         zo7tervVFHweZBJCeHo/E2aX9PWwN9hT9spQjEHSGsNHjtIVg2AwC1nFCmH49a7Q+1Uy
         EyNa4Lkr+1+XUY/Wpg930BXToaK04U9gpqtT1GI8MrTBefF/cgWhjvxhlFbHHmcjyYj3
         uF4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jirislaby@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=jirislaby@gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t12sor3797392wrn.28.2019.04.29.03.09.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Apr 2019 03:09:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of jirislaby@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jirislaby@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=jirislaby@gmail.com
X-Google-Smtp-Source: APXvYqyQllye7cYKik/HsHVmOu+rnX3aOFJuOpS91pLvtihzNHOqYA8tSvhUlIwQGmNwi9UD/60WAA==
X-Received: by 2002:a5d:5308:: with SMTP id e8mr9950716wrv.126.1556532595633;
        Mon, 29 Apr 2019 03:09:55 -0700 (PDT)
Received: from ?IPv6:2a0b:e7c0:0:107::49? ([2a0b:e7c0:0:107::49])
        by smtp.gmail.com with ESMTPSA id s124sm13406184wmf.42.2019.04.29.03.09.54
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 03:09:54 -0700 (PDT)
Subject: Re: memcg causes crashes in list_lru_add
From: Jiri Slaby <jslaby@suse.cz>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
 Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org,
 mm <linux-mm@kvack.org>,
 Linux kernel mailing list <linux-kernel@vger.kernel.org>
References: <f0cfcfa7-74d0-8738-1061-05d778155462@suse.cz>
 <2cbfb8dc-31f0-7b95-8a93-954edb859cd8@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=jslaby@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <359d98e6-044a-7686-8522-bdd2489e9456@suse.cz>
Date: Mon, 29 Apr 2019 12:09:53 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <2cbfb8dc-31f0-7b95-8a93-954edb859cd8@suse.cz>
Content-Type: text/plain; charset=iso-8859-2
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 29. 04. 19, 11:25, Jiri Slaby wrote:> memcg_update_all_list_lrus
should take care about resizing the array.

It should, but:
[    0.058362] Number of physical nodes 2
[    0.058366] Skipping disabled node 0

So this should be the real fix:
--- linux-5.0-stable1.orig/mm/list_lru.c
+++ linux-5.0-stable1/mm/list_lru.c
@@ -37,11 +37,12 @@ static int lru_shrinker_id(struct list_l

 static inline bool list_lru_memcg_aware(struct list_lru *lru)
 {
-       /*
-        * This needs node 0 to be always present, even
-        * in the systems supporting sparse numa ids.
-        */
-       return !!lru->node[0].memcg_lrus;
+       int i;
+
+       for_each_online_node(i)
+               return !!lru->node[i].memcg_lrus;
+
+       return false;
 }

 static inline struct list_lru_one *





Opinions?

thanks,
-- 
js
suse labs

