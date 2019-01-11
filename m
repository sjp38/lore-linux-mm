Return-Path: <SRS0=ysF+=PT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD063C43387
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 13:59:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 92EC520872
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 13:59:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 92EC520872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A2D98E0005; Fri, 11 Jan 2019 08:59:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 250738E0001; Fri, 11 Jan 2019 08:59:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 13F788E0005; Fri, 11 Jan 2019 08:59:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C3DAF8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 08:59:40 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id v4so5827854edm.18
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 05:59:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=scQOQr5VyuCplYCyJzpxw6CYki9aI3FbmFmYdCzZ+K4=;
        b=LyIy6ng8ceG8jp45aMsvrOPC13aB/jGhUPQcYmA2jsKOQ07zbmRAdwhPTYHzVB3I3S
         t2yPyDNBl5CcEIL4HA7jPsHv0VkI0RFNqnsKIXdmenmMcbZ46dKhW1AgiX6Zd0O4rjeN
         TY39DWjwdzutiPcstnWmE2zXPTRDIjvTx6OQsgKo8PQWjX9Vj6r2M3FQ5uBaLirhPCmQ
         ZzWiQIUB745ESC9luQDFHD6CxFQbJzdPsl3ZAfiqv5k2E7DNzXekdnGsS0NFtHJ9XEpN
         BD+mbGW1DkvE7vLDbLG0yyZN7HSeCv5exUSra63+MsHZQtR74zDZPrtNzlzhEctU46Tf
         NXGQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukcGE51kMZHawKd+nUv+pFG6RHqjWGzqp9Gattg6/XneqESi5Gnm
	EReXaFitOg+BCs690ZNCgBQ1AYdy+iz5dDPNqpuv95w4SawlQ4H/v33tnBgdfQOtJbDEoxZEkNo
	rIpoWr2+XMUDjQnHmb8NfSo9WxGKXN795L76wtPgOshB8alon6DOILCuz+QBYeEI=
X-Received: by 2002:a17:906:754e:: with SMTP id a14-v6mr12046708ejn.145.1547215180331;
        Fri, 11 Jan 2019 05:59:40 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5E/kgEtgeQ5zw+/NPqWLorxGar0I433aeOvOjHW7Z5/rI/l2UUzVvqnCT9cyLDJFHcJP1V
X-Received: by 2002:a17:906:754e:: with SMTP id a14-v6mr12046671ejn.145.1547215179527;
        Fri, 11 Jan 2019 05:59:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547215179; cv=none;
        d=google.com; s=arc-20160816;
        b=o553VZM6dXGxlv9XDfT3B2tQZJBtxjm6SXZLiyYLqyl8hi8FYsy42cdjB4/g3TRSyi
         T2yyz4xSVuiiRzpdS85CYejNWOLatOIbjsqQTOx0vn9VfzmES5VjcDjAnlITPuTwHYQy
         0cn2etJorAb+u77WXhV7lhDQ+D2pg7ARwC5WJzcPhDzWoBG/jfODdwkxSNDg24iDmZpI
         uw3ekoEyFt/VUMuMxJo6mjeG1z4k88C8YXJUnBhu67R4pjqYwTnEYiSzwnmVjgjRLmWe
         51/dvP212dIWyxDHQ2k6zjxzhX4o1HnhbyeOsJ1yJ6xBi4XIAWPoawv2Ps/79JCPM65F
         9CpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=scQOQr5VyuCplYCyJzpxw6CYki9aI3FbmFmYdCzZ+K4=;
        b=FDpXoVZ8Yse94sobNvCbACY865s0HhqWiMJLbNN2cifLHBojSAJ8ghrFhMxC4I/xWx
         xkKbK6X1TIMekKBa04NijTABfpW5t8tLglcuFJMAs3sqr8O+jFzP/X8plQLTwr647vGs
         H/s3qf/UcSfiWV4w074nkbKb4MzUailYwx6my8c1fMj1qjCABMuWuaZubo/ksXjWEmpO
         YqYvfWLr9BAUfA0sXCRvfmXzRzND17lWQC+dm2gdEu626w30ZHBbvm4o2YVnmKYvixmY
         1ZsEzqb80yzNejWzEQDXfeoFIGRzCIR517QRg65bO2G6CMXmHp0J6dENNTFaNK6GXPZ8
         GNJg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b15-v6si1961853eja.157.2019.01.11.05.59.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 05:59:39 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A8165AC4E;
	Fri, 11 Jan 2019 13:59:38 +0000 (UTC)
Date: Fri, 11 Jan 2019 14:59:38 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Baptiste Lepers <baptiste.lepers@gmail.com>
Cc: mgorman@techsingularity.net, akpm@linux-foundation.org,
	dhowells@redhat.com, linux-mm@kvack.org, hannes@cmpxchg.org
Subject: Re: Lock overhead in shrink_inactive_list / Slow page reclamation
Message-ID: <20190111135938.GG14956@dhcp22.suse.cz>
References: <CABdVr8R2y9B+2zzSAT_Ve=BQCa+F+E9_kVH+C28DGpkeQitiog@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CABdVr8R2y9B+2zzSAT_Ve=BQCa+F+E9_kVH+C28DGpkeQitiog@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 11-01-19 16:52:17, Baptiste Lepers wrote:
> Hello,
> 
> We have a performance issue with the page cache. One of our workload
> spends more than 50% of it's time in the lru_locks called by
> shrink_inactive_list in mm/vmscan.c.

Who does contend on the lock? Are there direct reclaimers or is it
solely kswapd with paths that are faulting the new page cache in?

-- 
Michal Hocko
SUSE Labs

