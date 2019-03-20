Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B1D0C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 22:12:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3CD9A2175B
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 22:12:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="SBJeuqyw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3CD9A2175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B1ADC6B0003; Wed, 20 Mar 2019 18:12:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACB736B0006; Wed, 20 Mar 2019 18:12:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BA6A6B0007; Wed, 20 Mar 2019 18:12:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7E18F6B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 18:12:43 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id v18so2424307qtk.5
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 15:12:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=nX5UkKgqpFczb3/+huvIPo48+SpqyuvBQVCHkeMfnt8=;
        b=TNzpSYgl5tRqhVm+U1Lt9BVTSiuqCvHIdpAPyoja6XahuubQ2j9Ts5xUHo5GPkJmjN
         rIwncwsFTANB+svLSqbsP0ikc9mRcn29brwixWnj9Ob+DTBVv4hbs+ll9sR7poNH0Q71
         h7PxxcCnpL98jgd6LfHoRda5uhaL7j+MYFuIOocWbeBLbRYHa15QtO8ozTPXf1exvEAz
         zu4oUdbU4pTQo7l5tu7pFnJv3bkm9ExpVD/AKv9C/Z3unOPNIvijwTjKdvANxV2s2U7t
         aDc2ZPITz1h+/WPaq6LIoh0gYcz+mCMproL+9P4c3tkhi8hmeKPTrfgMBbsgYkCKv4L/
         rWgA==
X-Gm-Message-State: APjAAAUi/oKPD+l/9AErT8ILehKg17VEfDL0zFfOBJte1SA7PKL0SDce
	V8/Rmzh4CiU1xSCMoe7+AFGyo5jLVKfp220/2ToByYoky+U9+QaHpBcNcmcj+NDtmkhJuOG7VM5
	oEIq1y1Or6yYa3vahg/pzrEhJeUu6cfg48HEJ6XzD1icqbfl3x4RDworI/GdTLPUCEw==
X-Received: by 2002:ac8:c44:: with SMTP id l4mr207792qti.72.1553119963278;
        Wed, 20 Mar 2019 15:12:43 -0700 (PDT)
X-Received: by 2002:ac8:c44:: with SMTP id l4mr207754qti.72.1553119962669;
        Wed, 20 Mar 2019 15:12:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553119962; cv=none;
        d=google.com; s=arc-20160816;
        b=gUSBkjUbdTW+1PkAP5BSjVgk+eWXxC5Z2KOsKpYwAl0fh/kkBW0trOMVCCjGTmTWj8
         jrMdVn986L2rOLwaMVBQxEpO786xkMhKpwNlHFH/EA9ldkERztaTnRLvMEI4Nqv7eoCe
         eRJwBYoQ50zOGcU2m37dc5S1umoX8yN1TYx+FUsdGHwYKaoqUtOySbd4Zva3ljqjyF/c
         RVakmVsEmirsX+1BYmWBLBE8jh3jbJH+iSAntM6h5559jqKv9qnPof5jpvnMjQ/1+Jy1
         B2wOhloHUsKPpjMBXJUNFCbmldcyCAWamneyDKDYg2SWNVqvwYnqCfUAS2bc/cac2/Do
         pb4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=nX5UkKgqpFczb3/+huvIPo48+SpqyuvBQVCHkeMfnt8=;
        b=jWAQZWnrMqwtESHwiTPv76oAYHiL/EiW3OUnYkeb4CObjRvjxHQB2ZARq5uOYWdrRa
         N5CbMLeylIKhOz1DZlFcGurkJzu1V9OWlU7+ZTFS+hZbttsxdik80LvbNXXLfHYJaXvK
         qhO9bvsMWS3zMRuOI5xXocfvHrjsm3awihPRCFsLsKpIerQgg0ThthJax52SzR0kv9zp
         InJiThtbZcR9KZap3sP3uIhiTZ93ukDz+CKdMtYal+ZY3RtOcFy7bMUvik71p0HkXAIu
         4uk2dGS83jn7rJ/QvOgpfviPRDzxNyG+M0d+v2+4m+RsEgf5Nks5dMTDBhEbcu//wopw
         6amQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=SBJeuqyw;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 29sor4231713qty.72.2019.03.20.15.12.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 15:12:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=SBJeuqyw;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=nX5UkKgqpFczb3/+huvIPo48+SpqyuvBQVCHkeMfnt8=;
        b=SBJeuqywHpgOVahMOisoAa2/I9E8f2gQd+FLijWp7GI2RoJf5ZaxLc43sjOzJ/zvkG
         hsGzx63zS3AgqvbSCsWh6prJwzpOGqwORiomJ+qA3N4OpnagGzxk0E4c9+MVPT4elTnw
         dKLXo4OaWw2r7ZI6g3GEyRUM+k25eTxVeboELeWKtK27qeYZBX6m0Q0ZzLwHqK2qVHdP
         vle1DkkUd32xbCdUCUmzQrpYvk9K6JPnhG+DrScXCxDKlQJ7R73ULlMDHRDzANM6cUO4
         oFSNFjYtZ+WM/npYHyp7l10Vc9tIDvwGFfQ3dIjpOQfhEsXZG7clk98W4BJ8kDM04YW4
         Ya9A==
X-Google-Smtp-Source: APXvYqw+uT7JrioO/XZkOIfnQXrjn3qFSl531kmhwLmFIuuia9XLfo/TJ7ydD/byQLf6E0mngNQ8Aw==
X-Received: by 2002:ac8:3629:: with SMTP id m38mr144460qtb.369.1553119962395;
        Wed, 20 Mar 2019 15:12:42 -0700 (PDT)
Received: from ovpn-120-94.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id d205sm1775689qkg.66.2019.03.20.15.12.41
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 15:12:41 -0700 (PDT)
Subject: Re: [RESEND#2 PATCH] mm/compaction: fix an undefined behaviour
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mgorman@techsingularity.net, vbabka@suse.cz, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <20190320203338.53367-1-cai@lca.pw>
 <20190320145826.9c647fe53bd999bbd2ee188d@linux-foundation.org>
From: Qian Cai <cai@lca.pw>
Message-ID: <a82bdba4-530a-95fd-8a05-5fd2fd67e4b4@lca.pw>
Date: Wed, 20 Mar 2019 18:12:40 -0400
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
In-Reply-To: <20190320145826.9c647fe53bd999bbd2ee188d@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/20/19 5:58 PM, Andrew Morton wrote:
>> ---
>>  mm/compaction.c | 4 +++-
>>  1 file changed, 3 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index e1a08fc92353..0d1156578114 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -1157,7 +1157,9 @@ static bool suitable_migration_target(struct compact_control *cc,
>>  static inline unsigned int
>>  freelist_scan_limit(struct compact_control *cc)
>>  {
>> -	return (COMPACT_CLUSTER_MAX >> cc->fast_search_fail) + 1;
>> +	return (COMPACT_CLUSTER_MAX >>
>> +		min((unsigned short)(BITS_PER_LONG - 1), cc->fast_search_fail))
>> +		+ 1;
>>  }
> 
> That's rather an eyesore.  How about
> 
> static inline unsigned int
> freelist_scan_limit(struct compact_control *cc)
> {
> 	unsigned short shift = BITS_PER_LONG - 1;
> 
> 	return (COMPACT_CLUSTER_MAX >> min(shift, cc->fast_search_fail)) + 1;
> }

Agree. It looks better.

